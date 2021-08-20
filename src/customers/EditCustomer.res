type state = {id: string}

@react.component
let make = (~customerId) => {
  let customer = Hooks.useCustomer(~customerId)

  switch customer {
  | None => <p> {React.string("Invalid customer ID.")} </p>
  | Some(customer) => <>
      <h2> {React.string(`Customer: ${customer.name}`)} </h2>
      <CustomerNav customerId />
      <p> {React.string("TODO")} </p>
    </>
  }
}
