type address = {
  street: string,
  suite: string,
  city: string,
  state: string,
  zip: string,
}

type addresses = {
  billing: address,
  shipping: address,
}

type customer = {
  name: string,
  address: addresses,
  phone: string,
  mobile: string,
  email: string,
  syncToken: string,
}

type invoice = {id: string, photos: array<string>, date: string}

type event = [#CustomerCreated | #CustomerUpdated | #InvoiceCreated]
type activity = {
  date: string,
  user: string,
  event: event,
  link: string,
  meta: array<string>,
}
