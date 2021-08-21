@val @scope("location") external origin: string = "origin"

module App = {
  @module("firebase/app") external initializeApp: {..} => {..} = "initializeApp"

  let app = initializeApp({
    "apiKey": "AIzaSyDh313C0D6DL82Gz0blHDn3x_2CU2Oa_Hk",
    "authDomain": "kokorugs-customer-photos.firebaseapp.com",
    "projectId": "kokorugs-customer-photos",
    "storageBucket": "kokorugs-customer-photos.appspot.com",
    "messagingSenderId": "907040994162",
    "appId": "1:907040994162:web:f86dcdf6a73cc7d7c923eb",
    "measurementId": "G-LXC6K8NNTM",
  })
}

module Firestore = {
  type db
  type collection
  type doc
  type query
  type iterable<'a>

  type clause

  type customerData = {id: string, data: (. unit) => Types.customer}
  type invoiceData = {id: string, data: (. unit) => Types.invoice}

  @send external forEach: (iterable<'a>, 'a => 'b) => unit = "forEach"

  @module("firebase/firestore") external getFirestore: unit => db = "getFirestore"
  @module("firebase/firestore")
  external connectFirestoreEmulator: (db, string, int) => unit = "connectFirestoreEmulator"
  @module("firebase/firestore") external collection: (db, string) => collection = "collection"
  @module("firebase/firestore") external addDoc: (collection, 'a) => Promise.t<'b> = "addDoc"
  @module("firebase/firestore") @variadic external doc: (db, array<string>) => doc = "doc"
  @module("firebase/firestore") @variadic
  external query: (collection, array<clause>) => query = "query"
  @module("firebase/firestore") external where: (string, string, string) => clause = "where"
  @module("firebase/firestore") external orderBy: (string, string) => clause = "orderBy"
  @module("firebase/firestore") external onSnapshot: (doc, 'a => unit) => 'b = "onSnapshot"
  @module("firebase/firestore")
  external onQuerySnapshot: (query, iterable<'a> => unit) => 'b = "onSnapshot"

  let db = getFirestore()
  if origin->Js.String2.includes("localhost") {
    connectFirestoreEmulator(db, "localhost", 8081)
  }
}

module Storage = {
  type storage
  type storageRef
  type file

  @module("firebase/storage") external getStorage: unit => storage = "getStorage"
  @module("firebase/storage")
  external connectStorageEmulator: (storage, string, int) => unit = "connectStorageEmulator"
  @module("firebase/storage") @variadic
  external storageRef: (storage, array<string>) => storageRef = "ref"
  @module("firebase/storage")
  external uploadBytes: (storageRef, file) => Promise.t<'a> = "uploadBytes"
  @module("firebase/storage")
  external getDownloadURL: storageRef => Promise.t<'a> = "getDownloadURL"

  let storage = getStorage()
  if origin->Js.String2.includes("localhost") {
    connectStorageEmulator(storage, "localhost", 8082)
  }
}

module Auth = {
  type auth

  @module("firebase/auth") external getAuth: unit => auth = "getAuth"
  @module("firebase/auth")
  external connectAuthEmulator: (auth, string) => unit = "connectAuthEmulator"
  @module("firebase/auth")
  external onAuthStateChanged: (auth, Js.Nullable.t<{..}> => unit) => unit = "onAuthStateChanged"
  @module("firebase/auth") @new
  external googleAuthProvider: unit => {..} = "GoogleAuthProvider"
  @module("firebase/auth")
  external signInWithRedirect: (auth, {..}) => unit = "signInWithRedirect"
  @module("firebase/auth") external signOut: auth => Promise.t<'a> = "signOut"

  let provider = googleAuthProvider()
  provider["setCustomParameters"](. {
    "prompt": "select_account",
  })

  let auth = getAuth()
  if origin->Js.String2.includes("localhost") {
    connectAuthEmulator(auth, "http://localhost:8083")
  }
}
