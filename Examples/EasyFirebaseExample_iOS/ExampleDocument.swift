//
//  ExampleDocument.swift
//  EasyFirebaseExample_iOS
//
//  Created by Ben Myers on 4/18/22.
//

import Foundation
import EasyFirebase

/**
 An example of a document that can be linked to another document. For instance, an ``ExampleUser`` object has an array of ``ExampleDocument`` documents.
 
 ⚠️ **Note:** For non-user documents, you don't need to worry about adding any `encode(to:)` or `init(from:)` methods.
 */
class ExampleDocument: Document {
  
  // These properties are required by the Document protocol.
  var id: String
  var dateCreated: Date
  
  // These properties are custom.
  var foodName: String = ""
  var calories: Int = 0
  
  // You don't need an initializer, this is used in FirestoreView.swift to add new food items to the user.
  init(name: String) {
    self.id = UUID().uuidString
    self.dateCreated = Date()
    self.foodName = name
    self.calories = Int.random(in: 50...1000)
  }
}
