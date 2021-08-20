module Customer = {
  let customer: option<Types.customer> = None
  let setCustomer: (option<Types.customer> => option<Types.customer>) => unit = _ => ()
  let context = React.createContext((customer, setCustomer))

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}
