@react.component
let make = (~to_) => {
  React.useEffect1(() => {
    RescriptReactRouter.replace(to_)

    None
  }, [])

  React.null
}
