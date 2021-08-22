let useCustomer = (~customerRef) => {
  let (customer, setCustomer) = React.useContext(Context.Customer.context)

  React.useEffect1(() => {
    open Firebase.Firestore

    if Belt.Option.isNone(customer) {
      let unsubscribe = onSnapshot(doc(db, ["customers", customerRef]), (doc: customerData<'a>) => {
        setCustomer(_ => Some((doc.ref["path"], doc.data(.))))
      })

      Some(unsubscribe)
    } else {
      None
    }
  }, [])

  customer
}
