//
//  File.swift
//  
//
//  Created by Ben Myers on 9/11/22.
//

import Foundation

@propertyWrapper
internal struct CodableIgnored<T>: Codable {
  
  public var wrappedValue: T?
  
  public init(wrappedValue: T?) {
    self.wrappedValue = wrappedValue
  }
  
  public init(from decoder: Decoder) throws {
    self.wrappedValue = nil
  }
  
  public func encode(to encoder: Encoder) throws {
    return
  }
}

extension KeyedDecodingContainer {
  func decode<T>(
    _ type: CodableIgnored<T>.Type,
    forKey key: Self.Key) throws -> CodableIgnored<T>
  {
    return CodableIgnored(wrappedValue: nil)
  }
}

extension KeyedEncodingContainer {
  mutating func encode<T>(
    _ value: CodableIgnored<T>,
    forKey key: KeyedEncodingContainer<K>.Key) throws
  {
    // Do nothing
  }
}
