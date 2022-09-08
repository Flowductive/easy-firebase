//
//  File.swift
//  
//
//  Created by Ben Myers on 9/6/22.
//

import Foundation

@propertyWrapper
public struct Field<V>: Codable where V: Codable {
  
  public var wrappedValue: V {
    return _value
  }
  
  private var propertyName: String? = nil
  private var _value: V
  
  public init(wrappedValue: V) {
    self._value = wrappedValue
  }
  
  internal func injectPropertyName(_ name: String) {
    self.propertyName = name
  }
}
