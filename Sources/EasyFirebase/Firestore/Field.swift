//
//  File.swift
//  
//
//  Created by Ben Myers on 9/6/22.
//

import Foundation

@propertyWrapper
public class Field<Value>: Codable where Value: Codable {
  
  public var wrappedValue: Value { get { return _value } set { _value = newValue }}
  
  private var name: String
  private var _value: Value
  
  public init(wrappedValue defaultValue: Value, _ name: String) {
    self.name = name
    self._value = defaultValue
  }
  
  public var field: Field<Value> {
    self
  }
  
  public func inject(name: String) {
    self.name = name
  }
}
