//
//  FoodItem.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/8/22.
//

import Foundation
import EasyFirebase

class FoodItem: Firestore.Document {
  
  @Field var name: String = ""
}
