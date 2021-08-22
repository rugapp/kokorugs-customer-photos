@react.component
let make = (~user) => {
  let (customers, setCustomers) = React.useState(() => [])
  let (customer, setCustomer) = React.useState(() => None)
  let url = RescriptReactRouter.useUrl()

  React.useEffect1(() => {
    open Firebase.Firestore

    let unsubscribe = onQuerySnapshot(query(collection(db, "customers"), []), (
      querySnapshot: iterable<customerData<'a>>,
    ) => {
      let customers = []
      querySnapshot->forEach(doc => {
        customers->Js.Array2.push((doc.id, doc.data(.)))
      })
      setCustomers(_ => customers)
    })

    Some(unsubscribe)
  }, [])

  <Context.Customers.Provider value=(customers, setCustomers)>
    <Context.Customer.Provider value=(customer, setCustomer)>
      <header>
        <h1> {React.string("Customer Photos")} </h1>
        <Styled.Nav>
          <Link isNavLink=true href="/customers/search"> {React.string("Search Customers")} </Link>
          <Link isNavLink=true href="/invoices/search"> {React.string("Search Invoices")} </Link>
          <Link isNavLink=true href="/recent-activity"> {React.string("Recent Activity")} </Link>
          <button onClick={_event => Firebase.Auth.signOut(Firebase.Auth.auth)->ignore}>
            {React.string("Sign Out")}
          </button>
        </Styled.Nav>
        <p className=%cx("margin-top: 0.5rem;")>
          <em> {React.string(`Logged in as ${user["displayName"]}`)} </em>
        </p>
      </header>
      <hr />
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
    </Context.Customer.Provider>
  </Context.Customers.Provider>
}
