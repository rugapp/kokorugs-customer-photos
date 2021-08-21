@react.component
let make = (~user) => {
  let (customer, setCustomer) = React.useState(() => None)
  let url = RescriptReactRouter.useUrl()

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
    | list{"customers", "add"} => <AddCustomer name="" />
    | list{"customers", "add", name} => <AddCustomer name />
    | list{"customers", customerId} => <Redirect to_={`/customers/${customerId}/view`} />
    | list{"customers", customerId, "add"} => <AddInvoice customerId />
    | list{"customers", customerId, "edit"} => <EditCustomer customerId />
    | list{"customers", customerId, "view"} => <ViewInvoices customerId />
    | list{"recent-activity"} => <RecentActivity />
    | _ => <Redirect to_="/" />
    }}
  </Context.Customer.Provider>
}
