switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<p> {React.string("Howdy")} </p>, root)
| None => ()
}
