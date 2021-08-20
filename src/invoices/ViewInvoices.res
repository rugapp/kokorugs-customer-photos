@react.component
let make = (~customerId) => {
  let (invoices, setInvoices) = React.useState(() => [])
  let customer = Hooks.useCustomer(~customerId)

  React.useEffect1(() => {
    open Firebase.Firestore

    let unsubscribe = onQuerySnapshot(query(collection(db, `customers/${customerId}/invoices`)), (
      querySnapshot: iterable<invoiceData>,
    ) => {
      let invoices = []
      querySnapshot->forEach(doc => invoices->Js.Array2.push(doc.data(.)))
      setInvoices(_ => invoices)
    })

    Some(unsubscribe)
  }, [])

  Js.log(invoices)

  switch customer {
  | None => <p> {React.string("Invalid customer ID.")} </p>
  | Some(customer) => <>
      <h2> {React.string(`Customer: ${customer.name}`)} </h2>
      <CustomerNav customerId />
      {if invoices->Js.Array2.length > 0 {
        <p> {React.string("invoices")} </p>
      } else {
        <p> {React.string("no invoices")} </p>
      }}
    </>
  }
}
