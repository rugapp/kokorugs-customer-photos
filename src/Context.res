module Customer = {
  let customer: option<(string, Types.customer)> = None
  let setCustomer: (
    option<(string, Types.customer)> => option<(string, Types.customer)>
  ) => unit = _ => ()
  let context = React.createContext((customer, setCustomer))

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}

module Customers = {
  let customers: array<(string, Types.customer)> = []
  let setCustomers: (
    array<(string, Types.customer)> => array<(string, Types.customer)>
  ) => unit = _ => ()
  let context = React.createContext((customers, setCustomers))

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}
