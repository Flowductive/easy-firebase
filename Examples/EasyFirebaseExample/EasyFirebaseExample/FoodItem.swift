//
//  FoodItem.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/8/22.
//

import EasyFirebase

class FoodItem: Document {
  
  @Field var name: String = "None"
  @Field var emoji: String? = nil
  @Field var category: String = "None"
  @Field var price: Price = Price()
}
