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
  var parentAsAny: Any? { get { fatalError() } set { fatalError() }}
  
  internal final var key: String?
  
  internal final var keyPath: String? {
    guard let key = key else { return nil }
    var arr: [String] = [key]
    unowned var field: AnyField? = self
    repeat {
      guard let key = field?.key else { break }
      arr.insert(key, at: 0)
      field = field?.parentAsAny as? AnyField
    } while field != nil
    return arr.joined(separator: ".")
  }
  
  public init(key: String?) {
    self.key = key
  }
  
  public func inject(parent: FieldObject?, key: String) {
    self.parentAsAny = parent
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
