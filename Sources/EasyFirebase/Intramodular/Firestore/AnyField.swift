//
//  AnyField.swift
//  
//
//  Created by Ben Myers on 9/11/22.
//

import Combine
import Foundation

public class AnyField: Codable {
  
  var valueAsAny: Any { fatalError() }
  var documentAsAny: Any? { get { fatalError() } set { fatalError() }}
  
  internal final var key: String?
  
  public init(key: String?) {
    self.key = key
  }
  
  public func inject(document: Firestore.Document?, key: String) {
    self.documentAsAny = document
    self.key = key
  }
  
  public func encode(to encoder: Encoder) throws {
    fatalError()
  }
  
  internal func decodeValue(from container: KeyedDecodingContainer<Firestore.Document.CodingKeys>, key propertyName: String) {
    fatalError()
  }
  
  public required init(from decoder: Decoder) throws {
    fatalError()
  }
}
