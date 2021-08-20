type address = {
  street: string,
  suite: string,
  city: string,
  state: string,
  zip: string,
}

type customer = {
  name: string,
  address: address,
}

type invoice = {id: string, photos: array<string>}
