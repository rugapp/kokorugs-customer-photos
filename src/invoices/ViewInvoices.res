@react.component
let make = (~customerRef) => {
  let (invoices, setInvoices) = React.useState(() => [])
  let (customers, _) = React.useContext(Context.Customers.context)
  let customer = customers->Js.Array2.find(((ref, _)) => customerRef === ref)

  React.useEffect1(() => {
    open Firebase.Firestore

    let unsubscribe = onQuerySnapshot(
      query(collection(db, `customers/${customerRef}/invoices`), [orderBy("date", "desc")]),
      (querySnapshot: iterable<invoiceData<'a>>) => {
        let invoices = []
        querySnapshot->forEach(doc => {
          switch doc.ref["path"]->Invoice.getRefsFromPath {
          | None => ()
          | Some((_, invoiceRef)) => invoices->Js.Array2.push((invoiceRef, doc.data(.)))->ignore
          }
        })
        setInvoices(_ => invoices)
      },
    )

    Some(unsubscribe)
  }, [])

  React.useEffect1(() => {
    let hash = Utils.location["hash"]

    Utils.window["requestAnimationFrame"](.(. ()) => {
      Utils.window["requestAnimationFrame"](.(. ()) => {
        Utils.window["requestAnimationFrame"](.(. ()) => {
          if hash && Utils.document["querySelector"](. hash) {
            Utils.document["querySelector"](. hash)["scrollIntoView"](.)
          }
        })
      })
    })->ignore

    None
  }, [invoices])

  switch customer {
  | None => <p> {React.string("Invalid customer ID.")} </p>
  | Some((_customerRef, customer)) => <>
      <h2> {React.string(`Customer: ${customer.name}`)} </h2>
      <CustomerNav customerRef />
      {if invoices->Js.Array2.length > 0 {
        invoices
        ->Js.Array2.map(((ref, invoice)) => <>
          <Styled.Invoice id=ref>
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
          </Styled.Invoice>
          <hr />
        </>)
        ->React.array
      } else {
        <p> {React.string("This customer doesn't have any invoices yet.")} </p>
      }}
    </>
  }
}
