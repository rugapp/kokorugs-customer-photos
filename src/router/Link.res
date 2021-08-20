@val @scope("location") external pathname: string = "pathname"

@react.component
let make = (~id=?, ~href, ~children, ~disabled=false, ~isNavLink=false, ~onClick=_ => ()) => {
  <a
    id={id->Belt.Option.getWithDefault("")}
    href
    className={isNavLink && Js.String.startsWith(href, pathname) ? "active" : ""}
    disabled
    onClick={event => {
      onClick(event)
      ReactEvent.Mouse.preventDefault(event)
      RescriptReactRouter.push(href)
    }}>
    children
  </a>
}
