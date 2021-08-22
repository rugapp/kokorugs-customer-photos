let getPath = invoiceId => {
  open Firebase.Firestore

  collectionGroup(db, "invoices")
  ->query([where("id", "==", invoiceId->Js.String2.toUpperCase)])
  ->getDocs
  ->Promise.then(querySnapshot => {
    let docs = []
    querySnapshot->forEach(Js.Array2.push(docs))
    Promise.resolve(docs[0].ref["path"])
  })
}

let getRefsFromPath = path => {
  switch path
  ->Js.String2.replaceByRe(Js.Re.fromString("customers\/(.*?)\/invoices\/(.*?)"), "$1|$2")
  ->Js.String2.split("|") {
  | [customerRef, invoiceRef] => Some((customerRef, invoiceRef))
  | _ => None
  }
}
