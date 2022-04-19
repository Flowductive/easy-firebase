//
//  Document.swift
//  
//
//  Created by Ben Myers on 10/28/21.
//

import Foundation

/// The ID of a document.
public typealias DocumentID = String

/**
 An object that can be sent to and recieved from Firestore.
 
 Extend your own classes from the `Document` protocol to send your own custom data objects.
 
 All documents must have `id`, `dateCreated` properties, as well as a way to check for equality:
 
 ```swift
 class MealItem: Document {
   
   var id: String
   var dateCreated: Date = Date()
   
   var name: String
   var calories: Int
   
   static func == (lhs: MealItem, rhs: MealItem) -> Bool {
     return lhs.id == rhs.id
   }
   
   init(id: String, name: String, calories: Int) {
     self.id = id
     self.name = name
     self.calories = calories
   }
 }
 ```
 
 Once you've instantiated documents, you can perform various related database operations.
 
 ```swift
 // Create applesauce and bagel meal items
 var applesauce = MealItem(id: "0", name: "Applesauce", calories: 250)
 var bagel = MealItem(id: "1", name: "Bagel", calories: 150)

 // Update the calorie count of the bagel to 160 in the database
 bagel.set(160, to: \.calories)
 
 // Get the most up-to-date calorie count for applesauce
 applesauce.get(\.calories) { cal in
   print("Applesauce is \(cal ?? 0) calories!")
 }
 ```
 */
@available(iOS 13.0, *)
public protocol Document: Model, Equatable, Identifiable {
  
  // MARK: - Properties
  
  /// The document's unique identifier.
  ///
  /// It's important to note that documents with identical IDs will be merged when sent to Firestore.
  ///
  /// To avoid this, it's advisable to assign `UUID().uuidString` to new documents.
  var id: String { get set }
  
  /// The date the document was created.
  ///
  /// This field is assigned manually. It's recommended to assign a new `Date()` instance.
  var dateCreated: Date { get }
}

@available(iOS 13.0, *)
extension Document {
  
  // MARK: - Public Static Methods
  
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
}

@available(iOS 13.0, *)
extension Document {
  
  // MARK: - Public Methods
  
  /**
   Sets the document in Firestore.
   
   - parameter completion: The completion handler.
   
   Documents are automatically stored in collections based on their type.
   
   If the pushed document has the same ID as an existing document in a collection, the old document will be replaced.
   */
  public func set(completion: @escaping (Error?) -> Void = { _ in }) {
    EasyFirestore.Storage.set(self, completion: completion)
  }
  
  /**
   Updates a specific field remotely in Firestore.
   
   - parameter path: The path to the field to update remotely.
   - parameter completion: The completion handler.
   */
  public func set<T, U>(field: FieldName, using path: KeyPath<T, U>, ofUserType: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Codable {
    EasyFirestore.Storage.set(field: field, using: path, in: self as! T, completion: completion)
  }
  
  /**
   Updates a specific field with a new value both locally and remotely in Firestore.
   
   - parameter value: The new value.
   - parameter path: The path to the field to update.
   - parameter completion: The completion handler.
   */
  public mutating func set<T>(field: FieldName, with value: T, using path: WritableKeyPath<Self, T>, completion: @escaping (Error?) -> Void = { _ in }) where T: Codable {
    self[keyPath: path] = value
    EasyFirestore.Storage.set(field: field, with: value, using: path, in: self, completion: completion)
  }
  
  /**
   Increments a specific field remotely in Firestore.
   
   - parameter path: The path to the field to update.
   - parameter increment: The amount to increment by.
   - parameter completion: The completion handler.
   */
  public mutating func increment<T>(_ path: WritableKeyPath<Self, T>, by increment: T, completion: @escaping (Error?) -> Void = { _ in }) where T: AdditiveArithmetic {
    var val = self[keyPath: path]
    if let intIncrement = increment as? Int {
      EasyFirestore.Updating.increment(path, by: intIncrement, in: self, completion: completion)
      val.add(increment)
      self[keyPath: path] = val
    } else {
      fatalError("[EasyFirebase] You can't increment mismatching values! Check the types of values you are providing to increment.")
    }
  }
  
  /**
   Gets the most up-to-date value from a specified path.
   
   - parameter path: The path to the field to retrieve.
   - parameter completion: The completion handler.
   
   If you don't want to update the entire object, and instead you just want to fetch a particular value, this method may be helpful.
   */
  public func get<T>(_ path: KeyPath<Self, T>, completion: @escaping (T?) -> Void) where T: Codable {
    EasyFirestore.Retrieval.get(id: id, ofType: Self.self) { document in
      guard let document = document else {
        completion(nil)
        return
      }
      completion(document[keyPath: path])
    }
  }
  
  /**
   Assigns the document's ID to a related list of IDs elsewhere remotely in Firestore.
   
   - parameter path: The path to the field of IDs in the parent document.
   - parameter parent: The parent document containing the field of IDs.
   - parameter completion: The completion handler.
   
   A **parent document** in this case is a document with some field containing a list of other document IDs.
   
   For instance, if `relatedFoodItems` is a property of `MealItem` of type `[DocumentID]` (which is an alias for `[String]`), calling
   
   ```swift
   bagel.assign(to: \.relatedMealItems, in: toast)
   ```
   
   will add `bagel`'s ID to `toast`'s `relatedMealItems`.
   
   ⚠️ **Note:** Fields will not be updated locally using this method.
   */
  public func assign<T>(toField field: FieldName, using path: KeyPath<T, [DocumentID]>, in parent: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
    EasyFirestore.Linking.assign(self, toField: field, using: path, in: parent, completion: completion)
  }
  
  /**
   Sets the document in Firestore, then assigns it to a field list of `DocumentID`s to a parent document.
   */
  public func setAssign<T>(toField field: FieldName, using path: KeyPath<T, [DocumentID]>, in parent: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
    EasyFirestore.Storage.setAssign(self, toField: field, using: path, in: parent, completion: completion)
  }
  
  /**
   Unassigns the document's ID from a related list of IDs elsewhere remotely in Firestore.
   */
  public func unassign<T>(fromField field: FieldName, using path: KeyPath<T, [DocumentID]>, in parent: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
    EasyFirestore.Linking.unassign(self, fromField: field, using: path, in: parent, completion: completion)
  }
}

