//
//  File.swift
//  
//
//  Created by Ben Myers on 9/6/22.
//

import Foundation
import Firebase
import FirebaseFirestore

@propertyWrapper
public class Field<DocumentType, Value>: AnyField, Codable where Value: Codable, DocumentType: Firestore.Document {
  
  public typealias Key = String
  
  public internal(set) var wrappedValue: Value
  public var document: DocumentType?
  
  public override var valueAsAny: Any { wrappedValue as Any }
  public override var documentAsAny: Any? { get {
    document as Any
  } set {
    guard let newValue = newValue, let newDoc = newValue as? DocumentType else { return }
    document = newDoc
  }}
  
  private var oldWrappedValue: Value?
  
  public init(wrappedValue defaultValue: Value, _ key: Key? = nil) {
    self.wrappedValue = defaultValue
    super.init(key: key)
  }
  
  public func encode(to encoder: Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
  
  public required init(from decoder: Decoder) throws {
    self.wrappedValue = try Value(from: decoder)
    super.init(key: decoder.codingPath.map { $0.stringValue }.joined(separator: "."))
  }
  
  public var projectedValue: Field<DocumentType, Value> {
    self
  }
  
  public enum SetOption: Equatable {
    
    /// Perform this write immediately, updating only the relevant key-value pair in Firestore.
    ///
    /// By default, writes are passed to the batch, where `document.write(...)` will set all the updated fields in Firestore.
    case writeNow
    
    /// Perform this write locally, updating `wrappedValue` with the passed value.
    ///
    /// By default, writes are written locally immediately.
    ///
    /// - parameter wait: Whether to wait for the set to fully complete before updating locally.
    case locally(wait: Bool)
    
    /// Revert the old local `wrappedValue` if an error occurs during the batch write.
    case revertIfFailed
  }
}

internal extension Field {
  
  func forceLocalUpdate(_ newValue: Value) {
    oldWrappedValue = nil
    wrappedValue = newValue
  }
  
  func attemptLocalUpdate(_ newValue: Value) {
    oldWrappedValue = wrappedValue
    wrappedValue = newValue
  }
  
  func revertLocalUpdate() {
    guard let oldWrappedValue = oldWrappedValue else { return }
    wrappedValue = oldWrappedValue
    self.oldWrappedValue = nil
  }
  
  func acceptLocalUpdate() {
    oldWrappedValue = nil
  }
}

public extension Field {
  
  func `set`(_ value: Value, options: [SetOption] = [.locally(wait: false)], completion: @escaping (Firestore.Error?) -> Void) {
    guard let key = key else { completion(.noKey); return }
    if options.contains(.locally(wait: false)) { attemptLocalUpdate(value) }
    if options.contains(.writeNow) {
      document?.write([key: value]) { [weak self] error in
        if let error = error {
          if options.contains(.revertIfFailed) { self?.revertLocalUpdate() }
          completion(error)
          return
        } else {
          if options.contains(.locally(wait: true)) {
            self?.forceLocalUpdate(value)
          } else {
            self?.acceptLocalUpdate()
          }
          completion(nil)
          return
        }
      }
    } else {
      document?.writeBatch(to: <#T##Firestore.Document.Location#>, completion: <#T##(Firestore.Error?) -> Void#>)
    }
  }
}
