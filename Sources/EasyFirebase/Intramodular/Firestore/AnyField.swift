//
//  AnyField.swift
//  
//
//  Created by Ben Myers on 9/11/22.
//

import Combine
import Foundation

public class AnyField<Parent>: Codable where Parent: FieldObject {
  
  var valueAsAny: Any { fatalError() }
  
  public internal(set) unowned var parent: Parent?
  
  internal final var key: String?
  
  internal final var keyPath: String? {
    guard let key = key else { return nil }
    var arr: [String] = [key]
    unowned var object: FieldObject? = self.parent
    repeat {
      guard let key = object?._fieldKey else { break }
      arr.insert(key, at: 0)
      object = object?.parent
    } while object != nil
    return arr.joined(separator: ".")
  }
  
  public init(key: String?) {
    self.key = key
  }
  
  public func inject(parent: Parent?, key: String) {
    self.parent = parent
    self.key = key
  }
  
  public func encode(to encoder: Encoder) throws {
    fatalError()
  }
  
  internal func decodeValue(from container: KeyedDecodingContainer<Document.CodingKeys>) {
    fatalError()
  }
  
  public required init(from decoder: Decoder) throws {
    fatalError()
  }
}
