open Firebase.Auth

onAuthStateChanged(auth, user => {
  switch user->Js.Nullable.toOption {
  | None => signInWithRedirect(auth, provider)
  | Some(user) =>
    switch ReactDOM.querySelector("#root") {
    | Some(root) => ReactDOM.render(<App user />, root)
    | None => ()
    }
  }
})
