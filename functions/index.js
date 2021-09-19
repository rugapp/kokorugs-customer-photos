const https = require("https");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const COMPANY_ID = functions.config().qbo.companyid;
const CLIENT_ID = functions.config().qbo.clientid;
const SECRET = functions.config().qbo.secret;

async function initializeFirestore() {
  console.log("Initializing Firestore...");

  if (!(await admin.firestore().doc("auth/tokens").get()).data()) {
    throw new Error("Please create the auth/tokens doc.");
  }

  console.log("Fetching customers...");
  const customers = await getCustomers();

  console.log("Adding customers to Firestore...");
  for (const customer of customers) {
    admin.firestore().doc(`customers/${customer.id}`).set(customer);
  }

  console.log("Initialized Firestore!");
}

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

          console.warn("Please update the refresh token in production!");
          console.log(refreshToken);

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

  return customers.map(formatCustomer);
}

async function getCustomer(id) {
  const { Customer } = await qboRequest({
    path: `/v3/company/${COMPANY_ID}/customer/${id}?minorversion=62`,
  });

  return Customer;
}

function formatCustomer(customer) {
  return {
    id: customer.Id,
    name: customer.DisplayName ?? "",
    address: {
      billing: {
        street: customer.BillAddr?.Line1 ?? "",
        suite: customer.BillAddr?.Line2 ?? "",
        city: customer.BillAddr?.City ?? "",
        state: customer.BillAddr?.CountrySubDivisionCode ?? "",
        zip: customer.BillAddr?.PostalCode ?? "",
      },
      shipping: {
        street: customer.ShipAddr?.Line1 ?? "",
        suite: customer.ShipAddr?.Line2 ?? "",
        city: customer.ShipAddr?.City ?? "",
        state: customer.ShipAddr?.CountrySubDivisionCode ?? "",
        zip: customer.ShipAddr?.PostalCode ?? "",
      },
    },
    phone: customer.PrimaryPhone?.FreeFormNumber ?? "",
    mobile: customer.Mobile?.FreeFormNumber ?? "",
    email: customer.PrimaryEmailAddr?.Address ?? "",
    syncToken: customer.SyncToken,
  };
}

/**
 * Endpoint for updating Quickbooks Online customers.
 */
exports.updateQuickbooksCustomer = functions.https.onRequest(
  async (request, response) => {
    const payload = JSON.parse(request.body);
    console.log(payload);
    response.set("Access-Control-Allow-Origin", "*");
    response.set("Access-Control-Allow-Methods", "OPTIONS, POST");
    try {
      await qboRequest({
        path: `/v3/company/${COMPANY_ID}/customer/?minorversion=62`,
        data: JSON.stringify({
          sparse: true,
          Id: payload.id,
          SyncToken: payload.syncToken,
          DisplayName: payload.name,
          PrintOnCheckName: payload.name,
          Mobile: { FreeFormNumber: payload.mobile },
          PrimaryPhone: { FreeFormNumber: payload.phone },
          BillAddr: {
            Line1: payload.address.billing.street,
            Line2: payload.address.billing.suite,
            City: payload.address.billing.city,
            CountrySubDivisionCode: payload.address.billing.state,
            PostalCode: payload.address.billing.zip,
          },
        }),
      });

      response.sendStatus(200);
    } catch (error) {
      console.log(error);
      functions.logger.log("Error updating customer:", request.body);
      response.sendStatus(500);
    }
  }
);

/**
 * Webhook for handling updates to Firestore when QuickBooks Online is updated.
 */
exports.handleCustomerUpdate = functions.https.onRequest(
  async (request, response) => {
    functions.logger.log("Webhook triggered:", request.body);

    for (const notification of request.body.eventNotifications) {
      for (const customer of notification.dataChangeEvent.entities) {
        if (customer.id) {
          const updatedCustomer = await getCustomer(customer.id);
          await admin
            .firestore()
            .doc(`customers/${customer.id}`)
            .set(formatCustomer(updatedCustomer));
        }

        if (customer.deletedId) {
          await admin
            .firestore()
            .doc(`customers/${customer.deletedId}`)
            .delete();
        }
      }
    }

    response.sendStatus(200);
  }
);
