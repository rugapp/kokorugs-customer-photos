@react.component
let make = () => {
  let (invoiceId, setInvoiceId) = React.useState(() => "")

  <form
    onSubmit={event => {
      ReactEvent.Form.preventDefault(event)
      Invoice.getPath(invoiceId)
      ->Promise.then(path =>
        switch Invoice.getRefsFromPath(path) {
        | None => Promise.resolve()
        | Some((customerRef, invoiceRef)) =>
          Utils.location["href"] = `/customers/${customerRef}/view#${invoiceRef}`
          Promise.resolve()
        }
      )
      ->ignore
    }}>
    <Styled.Form.Label>
      <strong> {React.string("Enter the invoice number")} </strong>
      <input
        type_="text"
        placeholder="Invoice number"
        value=invoiceId
        onChange={event => setInvoiceId(_ => ReactEvent.Form.target(event)["value"])}
      />
    </Styled.Form.Label>
    <Styled.Form.Button variation=Styled.Form.Primary>
      {React.string("Submit")}
    </Styled.Form.Button>
  </form>
}
