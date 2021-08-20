let useCustomer = (~customerId) => {
  let (customer, setCustomer) = React.useContext(Context.Customer.context)

  React.useEffect1(() => {
    open Firebase.Firestore

    if Belt.Option.isNone(customer) {
      let unsubscribe = onSnapshot(doc(db, ["customers", customerId]), (doc: customerData) => {
        setCustomer(_ => Some(doc.data(.)))
      })

      Some(unsubscribe)
    } else {
      None
    }
  }, [])

  customer
}
