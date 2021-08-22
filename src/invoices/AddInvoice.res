@val external location: {..} = "location"

let duplicateTag = "#duplicate"

@react.component
let make = (~customerRef) => {
  let initialState: Types.invoice = {
    id: "",
    photos: [],
    date: "",
  }

  let (invoice, setInvoice) = React.useState(() => initialState)
  let (customers, _) = React.useContext(Context.Customers.context)
  let setSnackbar = React.useContext(Context.Snackbar.context)
  let customer = customers->Js.Array2.find(((ref, _)) => customerRef === ref)
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

  switch customer {
  | None => <p> {React.string("Invalid customer ID.")} </p>
  | Some((_customerRef, customer)) => <>
      <h2> {React.string(`Customer: ${customer.name}`)} </h2>
      <CustomerNav customerRef />
      <form
        autoComplete="off"
        onSubmit={event => {
          open Firebase.Firestore
          ReactEvent.Form.preventDefault(event)

          let photos =
            invoice.photos->Js.Array2.filter(url => !(url->Js.String2.includes(duplicateTag)))

          if photos->Js.Array2.length === 0 {
            setSnackbar(_ => Some(<>
              <p> {React.string("Invoices require photos")} </p>
              <button type_="button" onClick={_event => setSnackbar(_ => None)}>
                {React.string("Dismiss")}
              </button>
            </>))
          } else {
            addDoc(
              collection(db, `customers/${customerRef}/invoices`),
              (
                {
                  id: invoice.id->Js.String2.toUpperCase,
                  date: Js.Date.make()->Js.Date.toISOString,
                  photos: photos,
                }: Types.invoice
              ),
            )
            ->Promise.then(_response => {
              location["href"] = `/customers/${customerRef}/view`
              Promise.resolve()
            })
            ->Promise.catch(error => {
              Js.log(error)
              setSnackbar(_ => Some(<>
                <p> {React.string("Permission denied")} </p>
                <button type_="button" onClick={_event => setSnackbar(_ => None)}>
                  {React.string("Dismiss")}
                </button>
              </>))
              Promise.resolve()
            })
            ->ignore
          }
        }}>
        <Styled.Form.Label>
          <strong> {React.string("Invoice Number")} </strong>
          <input type_="text" name="id" onChange=handleChange value=invoice.id required=true />
        </Styled.Form.Label>
        <Styled.Invoice>
          <section>
            {invoice.photos
            ->Js.Array2.map(url => {
              <a href=url target="_blank">
                <img
                  className={url->Js.String2.includes(duplicateTag) ? "duplicate" : ""}
                  src=url
                  key=url
                />
                <p className="error">
                  <em>
                    {React.string(
                      "This image has already been uploaded before and will not be included on this invoice.",
                    )}
                  </em>
                </p>
              </a>
            })
            ->React.array}
          </section>
        </Styled.Invoice>
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

            ReactEvent.Form.target(event)["files"]
            ->Js.Array2.from
            ->Js.Array2.map(file => {
              file
              ->Utils.resizeAndHashImageFromFile
              ->Promise.then(((blob, hash)) => {
                let ref = storageRef(storage, [hash])

                // prevent the same file from being uploaded twice
                getDownloadURL(ref)
                ->Promise.then(url => Promise.resolve(`${url}${duplicateTag}`))
                ->Promise.catch(_error => {
                  ref
                  ->uploadBytes(blob)
                  ->Promise.then(snapshot =>
                    getDownloadURL(
                      storageRef(storage, [snapshot["metadata"]["fullPath"]]),
                    )->Promise.then(Promise.resolve)
                  )
                })
              })
            })
            ->Promise.all
            ->Promise.thenResolve(urls =>
              setInvoice(invoice => {
                ...invoice,
                photos: invoice.photos->Js.Array2.concat(urls),
              })
            )
            ->Promise.finally(() =>
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
