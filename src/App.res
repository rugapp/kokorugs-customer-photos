@react.component
let make = (~user) => {
  let (isLoading, setIsLoading) = React.useState(() => false)
  let (customers, setCustomers) = React.useState(() => [])
  let (snackbar, setSnackbar) = React.useState((): option<React.element> => None)
  let url = RescriptReactRouter.useUrl()

  React.useEffect1(() => {
    open Firebase.Firestore
    setIsLoading(_ => true)
    let unsubscribe = onQuerySnapshot(query(collection(db, "customers"), []), (
      querySnapshot: iterable<customerData<'a>>,
    ) => {
      let customers = []
      querySnapshot->forEach(doc => {
        customers->Js.Array2.push((doc.id, doc.data(.)))
      })
      setCustomers(_ => customers)
      setIsLoading(_ => false)
    })

    Some(
      () => {
        setIsLoading(_ => false)
        unsubscribe()
      },
    )
  }, [])

  React.useEffect1(() => {
    let timeoutId = Js.Global.setTimeout(() => setSnackbar(_ => None), 8000)

    Some(
      () => {
        Js.Global.clearTimeout(timeoutId)
      },
    )
  }, [snackbar])

  React.useEffect1(() => {
    if isLoading {
      Utils.document["querySelector"](. "#root")["classList"]["add"](. "spinner")
    } else {
      Utils.document["querySelector"](. "#root")["classList"]["remove"](. "spinner")
    }
  }, [isLoading])

  <Context.Customers.Provider value=(customers, setCustomers)>
    <Context.Snackbar.Provider value={setSnackbar}>
      <Context.Loading.Provider value={setIsLoading}>
        <Context.User.Provider value={user}>
          <header>
            <h1> {React.string("Customer Photos")} </h1>
            <Styled.Nav>
              <Link isNavLink=true href="/customers/search">
                {React.string("Search Customers")}
              </Link>
              <Link isNavLink=true href="/invoices/search">
                {React.string("Search Invoices")}
              </Link>
              <Link isNavLink=true href="/recent-activity">
                {React.string("Recent Activity")}
              </Link>
              <button onClick={_event => Firebase.Auth.signOut(Firebase.Auth.auth)->ignore}>
                {React.string("Sign Out")}
              </button>
            </Styled.Nav>
            <p className=%cx("margin-top: 0.5rem;")>
              <em> {React.string(`Logged in as ${user["displayName"]}`)} </em>
            </p>
          </header>
          <hr />
          <main>
            {switch url.path {
            | list{} => <Redirect to_="/customers/search" />
            | list{"customers", "search"} => <SearchCustomers />
            | list{"customers", "add"} => <Customer name="" />
            | list{"customers", "add", name} => <Customer name />
            | list{"customers", customerRef} => <Redirect to_={`/customers/${customerRef}/view`} />
            | list{"customers", customerRef, "add"} => <AddInvoice customerRef />
            | list{"customers", customerRef, "edit"} => <Customer mode=Customer.Edit(customerRef) />
            | list{"customers", customerRef, "view"} => <ViewInvoices customerRef />
            | list{"invoices", "search"} => <SearchInvoices />
            | list{"recent-activity"} => <RecentActivity />
            | _ => <Redirect to_="/" />
            }}
          </main>
          <Snackbar isOpen={snackbar->Belt.Option.isSome}>
            {switch snackbar {
            | None => React.null
            | Some(snackbar) => snackbar
            }}
          </Snackbar>
          {isLoading ? <i className="spinner" /> : React.null}
        </Context.User.Provider>
      </Context.Loading.Provider>
    </Context.Snackbar.Provider>
  </Context.Customers.Provider>
}
