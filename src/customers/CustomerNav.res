@react.component
let make = (~customerId) => {
  <Styled.Nav>
    <Link isNavLink=true href={`/customers/${customerId}/add`}>
      {React.string("Add Invoice")}
    </Link>
    <Link isNavLink=true href={`/customers/${customerId}/view`}>
      {React.string("View Invoices")}
    </Link>
    <Link isNavLink=true href={`/customers/${customerId}/edit`}>
      {React.string("Edit Customer")}
    </Link>
  </Styled.Nav>
}
