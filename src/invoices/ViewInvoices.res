module Invoice = %styled.div(`
  margin-top: 2rem;

  header {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    justify-content: space-between;
  }

  section {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;

    a {
      flex: 0 0 49%;
      margin-bottom: 2rem;

      img {
        width: 100%;
      }
    } 
  }
`)

@react.component
let make = (~customerId) => {
  let (invoices, setInvoices) = React.useState(() => [])
  let customer = Hooks.useCustomer(~customerId)

  React.useEffect1(() => {
    open Firebase.Firestore

    let unsubscribe = onQuerySnapshot(
      query(collection(db, `customers/${customerId}/invoices`), [orderBy("date", "desc")]),
      (querySnapshot: iterable<invoiceData>) => {
        let invoices = []
        querySnapshot->forEach(doc => invoices->Js.Array2.push(doc.data(.)))
        setInvoices(_ => invoices)
      },
    )

    Some(unsubscribe)
  }, [])

  Js.log(invoices)

  switch customer {
  | None => <p> {React.string("Invalid customer ID.")} </p>
  | Some(customer) => <>
      <h2> {React.string(`Customer: ${customer.name}`)} </h2>
      <CustomerNav customerId />
      {if invoices->Js.Array2.length > 0 {
        invoices
        ->Js.Array2.map(invoice => <>
          <Invoice>
            <header>
              <h2> {React.string(invoice.id)} </h2>
              <h3>
                {React.string(invoice.date->Js.Date.fromString->Js.Date.toLocaleDateString)}
              </h3>
            </header>
            <section>
              {invoice.photos
              ->Js.Array2.map(url => {
                <a href=url target="_blank"> <img src=url key=url /> </a>
              })
              ->React.array}
            </section>
          </Invoice>
          <hr />
        </>)
        ->React.array
      } else {
        <p> {React.string("no invoices")} </p>
      }}
    </>
  }
}
