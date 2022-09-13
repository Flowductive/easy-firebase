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
  
  public var wrappedValue: Value
  public var document: DocumentType?
  
  public override var valueAsAny: Any { wrappedValue as Any }
  public override var documentAsAny: Any? { get {
    document as Any
  } set {
    guard let newValue = newValue, let newDoc = newValue as? DocumentType else { return }
    document = newDoc
  }}
  
  public init(wrappedValue defaultValue: Value, _ key: String? = nil) {
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
}

public extension Field {
  
  func `set`(completion: (Firestore.Error?) -> Void) {
    
    //Firestore.firestore().docu.setValue(wrappedValue, forKey: key)
  }
}
