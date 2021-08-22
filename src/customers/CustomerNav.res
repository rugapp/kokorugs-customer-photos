@react.component
let make = (~customerRef) => {
  <Styled.Nav>
    <Link isNavLink=true href={`/customers/${customerRef}/add`}>
      {React.string("Add Invoice")}
    </Link>
    <Link isNavLink=true href={`/customers/${customerRef}/view`}>
      {React.string("View Invoices")}
    </Link>
    <Link isNavLink=true href={`/customers/${customerRef}/edit`}>
      {React.string("Edit Customer")}
    </Link>
  </Styled.Nav>
}
