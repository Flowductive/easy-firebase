//
//  ExampleUser.swift
//  EasyFirebaseExample_iOS
//
//  Created by Ben Myers on 2/6/22.
//

// ExampleUser.swift

import EasyFirebase

class ExampleUser: EasyUser {
  
  var favoriteFood: String = ""
  var age: Int = -1
  var hasJob: Bool = false
  
  // Implementation
  
  enum CodingKeys: String, CodingKey {
    case favoriteFood, age, hasJob
  }
  
  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(favoriteFood, forKey: .favoriteFood)
    try container.encode(age, forKey: .age)
    try container.encode(hasJob, forKey: .hasJob)
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
    let values = try decoder.container(keyedBy: CodingKeys.self)
    favoriteFood = try values.decode(String.self, forKey: .favoriteFood)
    age = try values.decode(Int.self, forKey: .age)
    hasJob = try values.decode(Bool.self, forKey: .hasJob)
  }
  
  required init() {
    super.init()
  }
}
