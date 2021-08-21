@val external location: {..} = "location"

@react.component
let make = (~customerId) => {
  let initialState: Types.invoice = {
    id: "",
    photos: [],
    date: "",
  }

  let (invoice, setInvoice) = React.useState(() => initialState)
  let customer = Hooks.useCustomer(~customerId)
  let fileInputRef = React.useRef(Js.Nullable.null)

  let handleChange = event => {
    let value = ReactEvent.Form.target(event)["value"]

    setInvoice(invoice =>
      switch ReactEvent.Form.target(event)["name"] {
      | "id" => {...invoice, id: value}
      | _ => invoice
      }
    )
  }

  Js.log(invoice)

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
          addDoc(
            collection(db, `customers/${customerId}/invoices`),
            {...invoice, date: Js.Date.make()->Js.Date.toISOString},
          )
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
        {if Js.Array2.length(invoice.photos) > 0 {
          invoice.photos
          ->Js.Array2.map(url => {
            <img src=url />
          })
          ->React.array
        } else {
          <p> {React.string("No photos added.")} </p>
        }}
        <Styled.Form.Button
          variation=Styled.Form.Secondary
          onClick={event => {
            ReactEvent.Mouse.preventDefault(event)
            switch fileInputRef.current->Js.Nullable.toOption {
            | None => ()
            | Some(node) => ReactDOM.domElementToObj(node)["click"](.)
            }
          }}>
          {React.string("Add Photos")}
        </Styled.Form.Button>
        <input
          className=%cx("visibility: hidden; width: 0; height: 0; overflow: hidden;")
          ref={ReactDOM.Ref.domRef(fileInputRef)}
          type_="file"
          multiple=true
          onChange={event => {
            open Firebase.Storage
            open Promise

            ReactEvent.Form.target(event)["files"]
            ->Js.Array2.from
            ->Js.Array2.map(file => {
              storageRef(storage, [Utils.uuid()])->uploadBytes(file)
            })
            ->all
            ->then(snapshots =>
              snapshots
              ->Js.Array2.map(snapshot =>
                getDownloadURL(storageRef(storage, [snapshot["metadata"]["fullPath"]]))
              )
              ->all
            )
            ->thenResolve(urls =>
              setInvoice(invoice => {...invoice, photos: invoice.photos->Js.Array2.concat(urls)})
            )
            ->finally(() =>
              switch fileInputRef.current->Js.Nullable.toOption {
              | None => ()
              | Some(node) => ReactDOM.domElementToObj(node)["value"] = ""
              }
            )
            ->ignore
          }}
        />
        <Styled.Form.Button variation=Styled.Form.Primary>
          {React.string("Submit")}
        </Styled.Form.Button>
      </form>
    </>
  }
}
