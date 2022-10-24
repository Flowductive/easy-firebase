//
//  FieldObject.swift
//  
//
//  Created by Ben Myers on 10/20/22.
//

import Foundation

open class FieldObject: Codable, ObservableObject {
  
  internal var fields: [Field.Key]? = .some([])
  
  internal var parent: FieldObject?
  internal var enclosingKey: Field.Key?
  
  internal var rootDocument: Document? {
    unowned var object: FieldObject = self
    while true {
      if let parent = object.parent {
        if !(parent is Document) {
          break
        }
        object = parent
        continue
      } else {
        break
      }
    }
    return object as? Document
  }
  
  public init() {
    for (label, value) in Mirror(reflecting: self).children {
      if let field = value as? AnyField, let label = label?.underscorePrefixRemoved() {
        fields?.append(label)
        field.inject(parent: self, key: label)
      }
    }
  }
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var mirror: Mirror? = Mirror(reflecting: self)
    var isFieldObject: Bool = true
    repeat {
      isFieldObject = false
      guard let children = mirror?.children else { break }
      for child in children {
        if let field = child.value as? AnyField,
           let label = child.label?.underscorePrefixRemoved()
        {
          fields?.append(label)
          field.inject(parent: self, key: label)
          field.decodeValue(from: container)
          // TODO: Improve code support
          if label == "_fieldKey" { isFieldObject = true }
          if let object = field.valueAsAny as? FieldObject {
            object.parent = self
            object.enclosingKey = label
          }
        }
      }
      mirror = mirror?.superclassMirror
    } while mirror != nil && isFieldObject
  }
  
  public struct CodingKeys: CodingKey {
    
    private static var allKeys: [Int: String] = [:]
    
    public var stringValue: String
    
    public init?(stringValue: String) {
      self.stringValue = stringValue
      if let key: Int = Self.allKeys.first(where: { pair in pair.value == stringValue })?.key {
        self.intValue = key
      } else {
        let index = Self.allKeys.count
        Self.allKeys.updateValue(stringValue, forKey: index)
      }
    }
    
    public var intValue: Int?
    
    public init?(intValue: Int) {
      guard let str = Self.allKeys[intValue] else { return nil }
      self.stringValue = str
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container: KeyedEncodingContainer = encoder.container(keyedBy: CodingKeys.self)
    var mirror: Mirror? = Mirror(reflecting: self)
    repeat {
      guard let children = mirror?.children else { break }
      for child in children {
        guard let value = child.value as? Encodable else { continue }
        guard value is AnyField else { continue }
        let propertyName = child.label?.underscorePrefixRemoved() ?? ""
        if let key = CodingKeys(stringValue: propertyName) {
          try? container.encode(value, forKey: key)
        }
      }
      mirror = mirror?.superclassMirror
    } while mirror != nil
  }
}
