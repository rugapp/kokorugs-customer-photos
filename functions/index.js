require("dotenv").config();

const https = require("https");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const COMPANY_ID = process.env.COMPANY_ID;
const CLIENT_ID = process.env.CLIENT_ID;
const SECRET = process.env.SECRET;

async function getAccessToken() {
  const { accessToken, refreshToken, expiresIn } = await admin
    .firestore()
    .doc("auth/tokens")
    .get()
    .then((snapshot) => {
      if (snapshot.exists) {
        return snapshot.data();
      }

      throw Error("No refresh_token found.");
    });

  if (
    new Date().setMinutes(new Date().getMinutes() + 1) < new Date(expiresIn)
  ) {
    return accessToken;
  }

  return await new Promise((resolve, reject) => {
    const qboRequest = https.request(
      {
        hostname: "oauth.platform.intuit.com",
        port: 443,
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          Authorization: `Basic ${Buffer.from(
            `${CLIENT_ID}:${SECRET}`
          ).toString("base64")}`,
        },
        path: "/oauth2/v1/tokens/bearer",
      },
      (qboResponse) => {
        qboResponse.setEncoding("utf8");
        let body = "";
        qboResponse.on("data", (chunk) => {
          body += chunk;
        });
        qboResponse.on("end", async () => {
          const { access_token: accessToken, refresh_token: refreshToken } =
            JSON.parse(body);

          await admin
            .firestore()
            .doc("auth/tokens")
            .set({
              accessToken,
              refreshToken,
              expiresIn: new Date(
                new Date().setHours(new Date().getHours() + 1)
              ).toISOString(),
            });

          resolve(accessToken);
        });
      }
    );

    qboRequest.on("error", reject);
    qboRequest.write(`grant_type=refresh_token&refresh_token=${refreshToken}`);
    qboRequest.end();
  });
}

async function qboRequest({ data = "", path }) {
  return await new Promise(async (resolve, reject) => {
    const qboRequest = https.request(
      {
        hostname: "quickbooks.api.intuit.com",
        port: 443,
        method: data ? "POST" : "GET",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          Authorization: `Bearer ${await getAccessToken()}`,
        },
        path,
      },
      (qboResponse) => {
        qboResponse.setEncoding("utf8");
        let body = "";
        qboResponse.on("data", (chunk) => {
          body += chunk;
        });
        qboResponse.on("end", async () => {
          resolve(JSON.parse(body));
        });
      }
    );

    qboRequest.on("error", reject);
    qboRequest.write(data);
    qboRequest.end();
  });
}

async function getCustomers() {
  const {
    QueryResponse: { totalCount },
  } = await qboRequest({
    path: `/v3/company/${COMPANY_ID}/query?query=${encodeURI(
      "SELECT COUNT(*) FROM Customer"
    )}&minorversion=62`,
  });

  async function helper(customers = [], startPosition = 1) {
    const {
      QueryResponse: { Customer },
    } = await qboRequest({
      path: `/v3/company/${COMPANY_ID}/query?query=${encodeURI(
        `SELECT * FROM Customer STARTPOSITION ${startPosition} MAXRESULTS 1000`
      )}&minorversion=62`,
    });

    const customersSoFar = customers.concat(Customer);

    if (customersSoFar.length < totalCount) {
      return helper(customersSoFar, startPosition + 1000);
    }

    return customersSoFar;
  }

  let customers = await helper();

  return customers.map((customer) => ({
    id: customer.Id,
    name: customer.DisplayName || "",
    address: {
      billing: {
        street: customer.BillAddr?.Line1 || "",
        suite: customer.BillAddr?.Line2 || "",
        city: customer.BillAddr?.City || "",
        state: customer.BillAddr?.CountrySubDivisionCode || "",
        zip: customer.BillAddr?.PostalCode || "",
      },
      shipping: {
        street: customer.ShipAddr?.Line1 || "",
        suite: customer.ShipAddr?.Line2 || "",
        city: customer.ShipAddr?.City || "",
        state: customer.ShipAddr?.CountrySubDivisionCode || "",
        zip: customer.ShipAddr?.PostalCode || "",
      },
    },
    phone: customer.PrimaryPhone?.FreeFormNumber || "",
  }));
}

exports.handleCustomerUpdate = functions.https.onRequest(
  async (request, response) => {
    functions.logger.log("Webhook triggered:", request.body);
    response.sendStatus(200);
  }
);
