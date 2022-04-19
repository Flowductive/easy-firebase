//
//  FirestoreView.swift
//  EasyFirebaseExample_iOS
//
//  Created by Ben Myers on 4/18/22.
//

import SwiftUI
import EasyFirebase

/**
 This view assists with learning `EasyFirestore`.
 */
struct FirestoreView: View {
  
  // MARK: - Wrapped Properties
  
  /// The Global `EnvironmentObject`.
  @EnvironmentObject var global: Global
  
  @State var favFoodField: String = ""
  @State var ageField: Int = 0
  @State var hasJobField: Bool = false
  @State var newFoodField: String = ""
  
  @State var foodsEaten: [ExampleDocument] = []
  
  // MARK: - Body View
  
  var body: some View {
    VStack(spacing: 8.0) {
      VStack {
        Text("Fav Food: \(global.user.favoriteFood)").bold()
        TextField("New value", text: $favFoodField)
        Text("Age: \(global.user.age)").bold()
        TextField(value: $ageField, formatter: NumberFormatter()) { Text("New value") }
        Text("Has Job: \(String(global.user.hasJob))").bold()
        Toggle("Has Job: ", isOn: $hasJobField)
      }
      VStack {
        Button(action: pushDataMethod1) { Text("Push Data (Method 1)") }
        Button(action: pushDataMethod2) { Text("Push Data (Method 2)") }
        Button(action: justUpdateLocally) { Text("Locally Update Object") }
        Button(action: fetchData) { Text("Manually Fetch Data") }
      }
      Divider()
      Text("Total foods eaten: \(global.user.foodsEaten.count)")
      ForEach(foodsEaten, id: \.foodName) { foodEaten in
        HStack {
          Text("Item: \(foodEaten.foodName) (\(foodEaten.calories) cal)")
          Spacer()
          Button(action: {
            EasyFirestore.Removal.removeUnassign(foodEaten, from: \.foodsEaten, in: global.user)
          }) {
            Text("Delete")
          }
        }
      }
      HStack {
        TextField("Add new food", text: $newFoodField)
        Button(action: addFood) {
          Text("Add")
        }
      }
      Button(action: {
        EasyFirestore.Retrieval.get(ids: global.user.foodsEaten, ofType: ExampleDocument.self, useCache: false) { docs in
          foodsEaten = docs
        }
      }) {
        Text("Fetch all foods")
      }
    }.padding()
  }
  
  // MARK: - Methods
  
  /**
   Pushes the data the user added to Firestore.
   
   Method 1 pushes the data by updating the object locally, then pushing the updated object to Firestore.
   */
  func pushDataMethod1() {
    justUpdateLocally()
    global.user.set()
  }
  
  /**
   Pushes the data the user added to Firestore.
   
   Method 2 pushes the data directly to Firestore. This also automatically updates the properties of the local object.
   */
  func pushDataMethod2() {
    global.user.set(favFoodField, to: \.favoriteFood)
    global.user.set(ageField, to: \.age)
    global.user.set(hasJobField, to: \.hasJob)
  }
  
  /**
   This just updates the local `global.user` object.
   */
  func justUpdateLocally() {
    global.user.favoriteFood = favFoodField
    global.user.age = ageField
    global.user.hasJob = hasJobField
  }
  
  /**
   This method adds the food object to the user's foods eaten list.
   */
  func addFood() {
    let food = ExampleDocument(name: newFoodField)
    // Add the food locally:
    self.foodsEaten.append(food)
    // Then set it in Firestore and link to the user object:
    EasyFirestore.Storage.setAssign(food, to: \.foodsEaten, in: global.user)
    // Or, equivalently...
    // food.setAssign(to: \.foodsEaten, in: global.user)
  }
  
  /**
   Fetches the data from Firestore.
   
   ⚠️ **Note:** Calling `onUserUpdate` (in ``EasyFirebaseExample_iOSApp``) automatically updates the user object when data is updated remotely, so this method has no purpose. However, it can still be useful for fetching other object types!
   */
  func fetchData() {
    EasyFirestore.Retrieval.get(id: global.user.id, ofType: ExampleUser.self) { user in
      guard let user = user else { return }
      global.user = user
    }
  }
}

struct FirestoreView_Previews: PreviewProvider {
  static var previews: some View {
    FirestoreView()
  }
}
