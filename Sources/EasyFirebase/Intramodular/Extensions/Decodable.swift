//
//  File.swift
//  
//
//  Created by Ben Myers on 11/25/22.
//

import Foundation

extension Decodable {
  
  init(dictionary: [String: Any]) throws {
    self = try JSONDecoder().decode(Self.self, from: JSONSerialization.data(withJSONObject: dictionary))
  }
}
