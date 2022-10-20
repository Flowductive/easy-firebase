//
//  FoodItemView.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/10/22.
//

import SwiftUI

struct FoodItemView: View {
  
  @ObservedObject var food: FoodItem
  
  var body: some View {
    VStack {
      HStack {
        Text(food.emoji)
        Text(food.name).bold()
      }
      Text(food.category)
      Text("Costs \(Int(food.price.amount)) \(food.price.currency.rawValue)").foregroundColor(.green)
    }
    .padding()
    .background(Color.primary.opacity(0.1))
    .cornerRadius(8.0)
    .shadow(radius: 5.0)
    .frame(maxWidth: .infinity)
  }
}

struct FoodItemView_Previews: PreviewProvider {
  static var previews: some View {
    FoodItemView(food: .init())
  }
}
