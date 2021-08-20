@new @scope("google.maps.places")
external initAutocomplete: (Dom.element, {..}) => {..} = "Autocomplete"
@val @scope("google.maps.event")
external removeListener: {..} => unit = "removeListener"
@val @scope("document") external querySelector: string => Js.Nullable.t<'a> = "querySelector"
@send external focus: Dom.element => unit = "focus"
@val external location: {..} = "location"

@react.component
let make = (~name) => {
  let initialState: Types.customer = {
    name: name->Js.Global.decodeURI,
    address: {
      street: "",
      suite: "",
      city: "",
      state: "",
      zip: "",
    },
  }

  let inputRef = React.useRef(Js.Nullable.null)
  let (state, setState) = React.useState(() => initialState)

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
                street: component["short_name"],
              },
            })
          | "route" =>
            setState(state => {
              ...state,
              address: {
                ...state.address,
                street: `${state.address.street} ${component["short_name"]}`,
              },
            })
          | "postal_code" =>
            setState(state => {
              ...state,
              address: {
                ...state.address,
                zip: component["short_name"],
              },
            })
          | "locality" =>
            setState(state => {
              ...state,
              address: {
                ...state.address,
                city: component["long_name"],
              },
            })
          | "administrative_area_level_1" =>
            setState(state => {
              ...state,
              address: {
                ...state.address,
                state: component["short_name"],
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
      | "street" => {...state, address: {...state.address, street: value}}
      | "suite" => {...state, address: {...state.address, suite: value}}
      | "city" => {...state, address: {...state.address, city: value}}
      | "state" => {...state, address: {...state.address, state: value}}
      | "zip" => {...state, address: {...state.address, zip: value}}
      | _ => state
      }
    )
  }

  <form
    autoComplete="off"
    onSubmit={event => {
      open Firebase.Firestore
      ReactEvent.Form.preventDefault(event)
      addDoc(collection(db, "customers"), state)
      ->Promise.then(response => {
        location["href"] = `/customers/${response["id"]}/view`
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
      <strong> {React.string("Name")} </strong>
      <input type_="text" name="name" onChange=handleChange value=state.name required=true />
    </Styled.Form.Label>
    <Styled.Form.Label>
      <strong> {React.string("Address")} </strong>
      <input
        type_="text"
        name="street"
        onChange=handleChange
        value=state.address.street
        required=true
        ref={ReactDOM.Ref.domRef(inputRef)}
      />
    </Styled.Form.Label>
    <Styled.Form.Label>
      <strong> {React.string("Suite")} </strong>
      <input type_="text" name="suite" onChange=handleChange value=state.address.suite />
    </Styled.Form.Label>
    <Styled.Form.Label>
      <strong> {React.string("City")} </strong>
      <input
        type_="text" name="city" onChange=handleChange value=state.address.city required=true
      />
    </Styled.Form.Label>
    <Styled.Form.Label>
      <strong> {React.string("State")} </strong>
      <input
        type_="text" name="state" onChange=handleChange value=state.address.state required=true
      />
    </Styled.Form.Label>
    <Styled.Form.Label>
      <strong> {React.string("Zip Code")} </strong>
      <input type_="text" name="zip" onChange=handleChange value=state.address.zip required=true />
    </Styled.Form.Label>
    <Styled.Form.SubmitButton> {React.string("Submit")} </Styled.Form.SubmitButton>
  </form>
}