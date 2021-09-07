@new @scope("google.maps.places")
external initAutocomplete: (Dom.element, {..}) => {..} = "Autocomplete"
@val @scope("google.maps.event")
external removeListener: {..} => unit = "removeListener"
@val @scope("document") external querySelector: string => Js.Nullable.t<'a> = "querySelector"
@send external focus: Dom.element => unit = "focus"

type mode = Create | Edit(string)

let find = (~customers, ~customerRef) =>
  customers->Js.Array2.find(((ref, _)) => customerRef === ref)

let diff = (~old: Types.customer, ~new: Types.customer) => {
  let updates = []

  let updates =
    old.name !== new.name
      ? updates->Js.Array2.concat([`Name changed from ${old.name} to ${new.name}`])
      : updates

  let updates =
    old.address.billing.street !== new.address.billing.street
      ? updates->Js.Array2.concat([
          `Street address changed from ${old.address.billing.street} to ${new.address.billing.street}`,
        ])
      : updates

  let updates =
    old.address.billing.suite !== new.address.billing.suite
      ? updates->Js.Array2.concat([
          `Suite changed from ${old.address.billing.suite} to ${new.address.billing.suite}`,
        ])
      : updates

  let updates =
    old.address.billing.city !== new.address.billing.city
      ? updates->Js.Array2.concat([
          `City changed from ${old.address.billing.city} to ${new.address.billing.city}`,
        ])
      : updates

  let updates =
    old.address.billing.state !== new.address.billing.state
      ? updates->Js.Array2.concat([
          `State changed from ${old.address.billing.state} to ${new.address.billing.state}`,
        ])
      : updates

  old.address.billing.zip !== new.address.billing.zip
    ? updates->Js.Array2.concat([
        `Zip changed from ${old.address.billing.zip} to ${new.address.billing.zip}`,
      ])
    : updates
}

@react.component
let make = (~name="", ~mode=Create) => {
  let initialState: Types.customer = {
    name: name->Js.Global.decodeURI,
    address: {
      billing: {
        street: "",
        suite: "",
        city: "",
        state: "",
        zip: "",
      },
      shipping: {
        street: "",
        suite: "",
        city: "",
        state: "",
        zip: "",
      },
    },
    phone: "",
  }

  let inputRef = React.useRef(Js.Nullable.null)
  let (customers, _setCustomers) = React.useContext(Context.Customers.context)
  let setSnackbar = React.useContext(Context.Snackbar.context)
  let user = React.useContext(Context.User.context)
  let (state, setState) = React.useState(() => initialState)

  React.useEffect1(() => {
    switch mode {
    | Create => ()
    | Edit(customerRef) =>
      setState(state =>
        switch find(~customers, ~customerRef) {
        | None => state
        | Some((_ref, customer)) => customer
        }
      )
    }

    None
  }, [customers])

  React.useEffect1(() => {
    let listener = switch Js.Nullable.toOption(inputRef.current) {
    | None => Js.Obj.empty()
    | Some(node) =>
      let autocomplete = initAutocomplete(
        node,
        {
          "componentRestrictions": {"country": ["us"]},
          "fields": ["address_components"],
          "types": ["address"],
        },
      )

      node->focus

      autocomplete["addListener"](."place_changed", () => {
        let place = autocomplete["getPlace"](.)

        switch querySelector(".pac-container")->Js.Nullable.toOption {
        | None => ()
        | Some(container) =>
          let container = ReactDOM.domElementToObj(container)
          let node = ReactDOM.domElementToObj(node)
          container["style"]["width"] = `${node["clientWidth"]}px`
        }

        setState(state => {...state, address: initialState.address})

        place["address_components"]->Js.Array2.forEach(component => {
          switch component["types"][0] {
          | "street_number" =>
            setState(state => {
              ...state,
              address: {
                ...state.address,
                billing: {
                  ...state.address.billing,
                  street: component["short_name"],
                },
              },
            })
          | "route" =>
            setState(state => {
              ...state,
              address: {
                ...state.address,
                billing: {
                  ...state.address.billing,
                  street: `${state.address.billing.street} ${component["short_name"]}`,
                },
              },
            })
          | "postal_code" =>
            setState(state => {
              ...state,
              address: {
                ...state.address,
                billing: {
                  ...state.address.billing,
                  zip: component["short_name"],
                },
              },
            })
          | "locality" =>
            setState(state => {
              ...state,
              address: {
                ...state.address,
                billing: {
                  ...state.address.billing,
                  city: component["long_name"],
                },
              },
            })
          | "administrative_area_level_1" =>
            setState(state => {
              ...state,
              address: {
                ...state.address,
                billing: {
                  ...state.address.billing,
                  state: component["short_name"],
                },
              },
            })
          | _ => ()
          }
        })
      })
    }

    Some(() => removeListener(listener))
  }, [])

  let handleChange = event => {
    let value = ReactEvent.Form.target(event)["value"]

    setState(state =>
      switch ReactEvent.Form.target(event)["name"] {
      | "name" => {...state, name: value}
      | "street" => {
          ...state,
          address: {...state.address, billing: {...state.address.billing, street: value}},
        }
      | "suite" => {
          ...state,
          address: {...state.address, billing: {...state.address.billing, suite: value}},
        }
      | "city" => {
          ...state,
          address: {...state.address, billing: {...state.address.billing, city: value}},
        }
      | "state" => {
          ...state,
          address: {...state.address, billing: {...state.address.billing, state: value}},
        }
      | "zip" => {
          ...state,
          address: {...state.address, billing: {...state.address.billing, zip: value}},
        }
      | _ => state
      }
    )
  }

  <>
    {switch mode {
    | Create => React.null
    | Edit(customerRef) => <>
        <h2> {React.string(`Customer: ${state.name}`)} </h2> <CustomerNav customerRef />
      </>
    }}
    <form
      autoComplete="off"
      onSubmit={event => {
        open Firebase.Firestore
        ReactEvent.Form.preventDefault(event)

        switch mode {
        | Create => %raw(`alert("This feature is coming soon")`)
        // addDoc(collection(db, "customers"), state)
        // ->Promise.then(response => {
        //   addDoc(
        //     collection(db, "activity"),
        //     (
        //       {
        //         date: Js.Date.make()->Js.Date.toISOString,
        //         user: user["displayName"],
        //         event: #CustomerCreated,
        //         link: `/customers/${response["id"]}/view`,
        //         meta: [],
        //       }: Types.activity
        //     ),
        //   )->Promise.then(_ => {
        //     Utils.location["href"] = `/customers/${response["id"]}/view`
        //     Promise.resolve()
        //   })
        // })
        // ->Promise.catch(error => {
        //   Js.log(error)
        //   setSnackbar(_ => Some(<>
        //     <p> {React.string("Permission denied")} </p>
        //     <button type_="button" onClick={_event => setSnackbar(_ => None)}>
        //       {React.string("Dismiss")}
        //     </button>
        //   </>))
        //   Promise.resolve()
        // })
        | Edit(customerRef) =>
          setDoc(doc(db, ["customers", customerRef]), state)
          ->Promise.then(_response => {
            setSnackbar(_ => Some(<>
              <p> {React.string("Customer updated successfully")} </p>
              <button type_="button" onClick={_event => setSnackbar(_ => None)}>
                {React.string("Dismiss")}
              </button>
            </>))

            let (_, oldCustomer) = find(~customers, ~customerRef)->Belt.Option.getExn

            addDoc(
              collection(db, "activity"),
              (
                {
                  date: Js.Date.make()->Js.Date.toISOString,
                  user: user["displayName"],
                  event: #CustomerUpdated,
                  link: `customers/${customerRef}/view`,
                  meta: diff(~old=oldCustomer, ~new=state),
                }: Types.activity
              ),
            )->Promise.then(Promise.resolve)
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
        }->ignore
      }}>
      <Styled.Form.Label>
        <strong> {React.string("Name")} </strong>
        <input type_="text" name="name" onChange=handleChange value=state.name required=true />
      </Styled.Form.Label>
      <Styled.Form.Label>
        <strong> {React.string("Address")} </strong>
        <input
          type_="text"
          name="street"
          onChange=handleChange
          value=state.address.billing.street
          required=true
          ref={ReactDOM.Ref.domRef(inputRef)}
        />
      </Styled.Form.Label>
      <Styled.Form.Label>
        <strong> {React.string("Suite")} </strong>
        <input type_="text" name="suite" onChange=handleChange value=state.address.billing.suite />
      </Styled.Form.Label>
      <Styled.Form.Label>
        <strong> {React.string("City")} </strong>
        <input
          type_="text"
          name="city"
          onChange=handleChange
          value=state.address.billing.city
          required=true
        />
      </Styled.Form.Label>
      <Styled.Form.Label>
        <strong> {React.string("State")} </strong>
        <input
          type_="text"
          name="state"
          onChange=handleChange
          value=state.address.billing.state
          required=true
        />
      </Styled.Form.Label>
      <Styled.Form.Label>
        <strong> {React.string("Zip Code")} </strong>
        <input
          type_="text"
          name="zip"
          onChange=handleChange
          value=state.address.billing.zip
          required=true
        />
      </Styled.Form.Label>
      <Styled.Form.Button variation=Styled.Form.Primary>
        {React.string("Submit")}
      </Styled.Form.Button>
    </form>
  </>
}
