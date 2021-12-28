![Social Preview](./Assets/Social%20Preview%20(640).png)

<h2 align="center">Firebase for iOS and macOS made easy.</h2>

<p align="center">🍏 Third-party authentication done in a single line of code</p>
<p align="center">✉️ Send and receive Firestore documents in a snap</p>
<p align="center">😀 Predefined user protocols with built-in features</p>
<p align="center">🔥 Firebase solutions in one native Swift package</p>

## What is EasyFirebase?

EasyFirebase is a Swift wrapper for all things Firebase. Save hours from implementing the Firebase code in your projects repeatedly. EasyFirebase makes document storage and retrieval easier by providing **intuitive protocols** for Firestore. EasyFirebase makes **authentication easier** with the EasyUser protocol and simple one-line sign-in with Google and Apple. EasyFirebase is cross-platform and works with both iOS and macOS.

## Completed Features

- Firestore Support
  - Built-in Document protocol
  - Document storage
  - Document removal
  - Document retrieval
  - Update listeners
  - Built-in cacheing
  - Automatic linking
- Authentication Support
  - Email auth
  - Sign In with Google
  - Sign In with Apple

All the above features are **cross-platform** and are supported on both iOS and macOS.

⭐️ This means EasyFirebase is the quickest way to implement Sign In with Google on macOS! ⭐️

### Built-in Document protocol

Save time writing model classes with the Document protocol:

```swift
class Car: Document {
  
  // These properties are inherited from Document
  var id: String = UUID().uuidString
  var dateCreated: Date = Date()
  
  // Define your own custom properties
  var make: String
  var model: String
  var year: Int
  
  init(make: String, model: String, year: Int) {
    // ...
  }
}
```

### Document storage

Store documents anywhere in your code:

```swift
var myCar = Car(make: "Toyota", model: "Corolla", year: 2017)

// Store the car instance in the 'car' collection in Firestore
myCar.set()

// Static method that does the same as above
EasyFirestore.Storage.set(myCar)
```

### Document Retrieval

Grab documents easily without needing to specify a collection name:

```swift
EasyFirestore.Retrieval.get(id: myCarID, ofType: Car.self) { car in
  guard let car = car else { return }
  self.myOtherCar = car
}
```

### Update Listeners

Grab documents and update the local instance when changed in Firestore:

```swift
EasyFirestore.Listening.listen(to: otherCarID, ofType: Car.self, key: "myCarListenerKey") { car in
  // Updates when changed in Firestore
  guard let car = car else { return }
  self.myOtherCar = car
}
```

### Built-In Cacheing

EasyFirestore will automatically cache fetched documents locally and will use the cached doucments when retrieving to reduce your Firestore read count.

```swift
// EasyFirebase will automatically cache fetched objects for you, here is a manual example
EasyFirestore.Cacheing.register(myCar)

// Get locally cached objects instantly. Retrieving objects using EasyFirestore.Retrieval will grab cached objects if they exist
var cachedCar = EasyFirestore.Cacheing.grab(myCarID, fromType: Car.self)
```
