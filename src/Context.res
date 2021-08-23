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

module Snackbar = {
  let setSnackbar: (option<React.element> => option<React.element>) => unit = _ => ()
  let context = React.createContext(setSnackbar)

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}

module User = {
  let context = React.createContext({"displayName": ""})

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}
