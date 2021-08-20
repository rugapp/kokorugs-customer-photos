@val external location: {..} = "location"

@react.component
let make = (~customerId) => {
  let initialState: Types.invoice = {
    id: "",
    photos: [],
  }

  let (invoice, setInvoice) = React.useState(() => initialState)
  let customer = Hooks.useCustomer(~customerId)

  let handleChange = event => {
    let value = ReactEvent.Form.target(event)["value"]

    setInvoice(invoice =>
      switch ReactEvent.Form.target(event)["name"] {
      | "id" => {...invoice, id: value}
      | _ => invoice
      }
    )
  }

  React.useEffect1(() => {
    open Firebase.Storage

    getDownloadURL(storageRef(storage, ["69a0d608-217b-42a1-847a-634a41c0c55e"]))
    ->Promise.then(url => {
      Js.log(url)
      Promise.resolve()
    })
    ->Promise.catch(error => {
      Js.log(error)
      Promise.resolve()
    })
    ->ignore

    None
  }, [])

  switch customer {
  | None => <p> {React.string("Invalid customer ID.")} </p>
  | Some(customer) => <>
      <h2> {React.string(`Customer: ${customer.name}`)} </h2>
      <CustomerNav customerId />
      <form
        autoComplete="off"
        onSubmit={event => {
          open Firebase.Firestore
          ReactEvent.Form.preventDefault(event)
          addDoc(collection(db, `customers/${customerId}/invoices`), invoice)
          ->Promise.then(response => {
            location["href"] = `/customers/${customerId}/view`
            Js.log(response)
            Promise.resolve()
          })
          ->Promise.catch(error => {
            Js.log(error)
            %raw("alert('Permission denied.')")->ignore
            Promise.resolve()
          })
          ->ignore
        }}>
        <Styled.Form.Label>
          <strong> {React.string("Invoice Number")} </strong>
          <input type_="text" name="id" onChange=handleChange value=invoice.id required=true />
        </Styled.Form.Label>
        <input
          type_="file"
          multiple=true
          onChange={event => {
            open Firebase.Storage

            ReactEvent.Form.target(event)["files"]
            ->Js.Array2.from
            ->Js.Array2.map(storageRef(storage, [Utils.uuid()])->uploadBytes)
            ->Promise.all
            ->Promise.then(snapshot => {
              Js.log(snapshot)
              Promise.resolve()
            })
            ->Promise.catch(error => {
              Js.log(error)
              Promise.resolve()
            })
            ->ignore
          }}
        />
        <Styled.Form.SubmitButton> {React.string("Submit")} </Styled.Form.SubmitButton>
      </form>
    </>
  }
}
