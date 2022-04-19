//
//  ExampleUser.swift
//  EasyFirebaseExample_iOS
//
//  Created by Ben Myers on 2/6/22.
//

// ExampleUser.swift

import EasyFirebase

/**
 The user class.
 
 User classes must extend the `EasyUser` class. When adding your own properties, be sure to encode/decode the properties to/from containers in the ``encode(to:)`` and ``init(from:)`` methods!
 */
class ExampleUser: EasyUser {
  
  var favoriteFood: String = ""
  var age: Int = -1
  var hasJob: Bool = false
  
  var foodsEaten: [DocumentID] = []
  
  // Implementation
  
  enum CodingKeys: String, CodingKey {
    case favoriteFood, age, hasJob, foodsEaten
  }
  
  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(favoriteFood, forKey: .favoriteFood)
    try container.encode(age, forKey: .age)
    try container.encode(hasJob, forKey: .hasJob)
    try container.encode(foodsEaten, forKey: .foodsEaten)
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
    let values = try decoder.container(keyedBy: CodingKeys.self)
    favoriteFood = try values.decode(String.self, forKey: .favoriteFood)
    age = try values.decode(Int.self, forKey: .age)
    hasJob = try values.decode(Bool.self, forKey: .hasJob)
    foodsEaten = try values.decode([DocumentID].self, forKey: .foodsEaten)
  }
  
  required init() {
    super.init()
  }
}
