module ResultsList = %styled.ul(`
  list-style: none;

  li {
    font-size: 1rem;
    line-height: 1.5rem;
    width: 80%;
    box-sizing: border-box;

    &:last-of-type {

      a {
        border: none;
      }
    }

    a {
      display: block;
      padding: 0.5rem;
      border-bottom: 1px solid rgba(0, 0, 0, 0.3);
      background-color: rgba(0, 0, 0, 0.05);
      text-decoration: none;
      color: blue;

      &:hover {
        background-color: rgba(0, 0, 0, 0.025);
      }
    }
  }
`)

let stringifyCustomer = (customer: Types.customer) =>
  `${customer.name}|${customer.address.street}|${customer.address.suite}|${customer.address.city}|${customer.address.state}|${customer.address.zip}`

@react.component
let make = () => {
  let (customers, _setCustomers) = React.useContext(Context.Customers.context)
  let (searchText, setSearchText) = React.useState(() => "")

  <>
    <Styled.Form.Label>
      <strong> {React.string("Search customers (by name and/or address)")} </strong>
      <input
        type_="text"
        placeholder="Name or address"
        value=searchText
        onChange={event => setSearchText(_ => ReactEvent.Form.target(event)["value"])}
      />
    </Styled.Form.Label>
    <p>
      <em>
        {React.string("Note: use commas for multiple search terms (e.g. Smith, Beacon Street)")}
      </em>
    </p>
    {if searchText->Js.String2.length > 2 {
      <ResultsList>
        {customers
        ->Js.Array2.filter(((_id, customer)) => {
          let stringifiedCustomer = stringifyCustomer(customer)

          searchText
          ->Js.String2.split(",")
          ->Js.Array2.map(Js.String2.trim)
          ->Js.Array2.every(token =>
            Js.Re.fromStringWithFlags(token, ~flags="i")->Js.Re.test_(stringifiedCustomer)
          )
        })
        ->Js.Array2.slice(~start=0, ~end_=10)
        ->Js.Array2.map(((id, customer)) =>
          <li>
            <Link href={`/customers/${id}`}>
              <em>
                {React.string(customer.name)}
                <br />
                {React.string(customer.address.street)}
                {if Js.String2.length(customer.address.suite) > 0 {
                  <> <br /> {React.string(customer.address.suite)} </>
                } else {
                  React.null
                }}
                <br />
                {React.string(
                  `${customer.address.city}, ${customer.address.state} ${customer.address.zip}`,
                )}
              </em>
            </Link>
          </li>
        )
        ->React.array}
        <li>
          <Link href={`/customers/add/${searchText}`}> {React.string("Add customer")} </Link>
        </li>
      </ResultsList>
    } else {
      React.null
    }}
  </>
}
