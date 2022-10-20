//
//  SetDocumentView.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/8/22.
//

import SwiftUI

struct SetDocumentView: View {
  
  @StateObject var food: FoodItem = FoodItem()
  
  @State var nameField: String = ""
  @State var emojiField: String = ""
  @State var categoryField: String = ""
  @State var priceField: Int = 10
  @State var currencyField: Price.Currency = .usd

  @State var loading: Bool = false
  @State var error: String = ""
  @State var success: Bool = false
  
  var body: some View {
    ScrollView {
      VStack {
        entryView
        Divider()
        Text("Preview").font(.title2)
        FoodItemView(food: food)
        Divider()
        Button("Set in Firestore", action: {
          loading = true
          food.write { error in
            self.loading = false
            self.error = error?.localizedDescription ?? ""
          }
        })
        Button("Test", action: {
          print(nameField)
        })
        if loading {
          Text("")
        } else if !error.isEmpty {
          Text("Error: \(error)").foregroundColor(.red)
        } else if success {
          Text("Success").foregroundColor(.green)
        }
      }
      .padding()
    }
  }
  
  var entryView: some View {
    Group {
      Text("Food Details").font(.title2)
      VStack {
        Text("New document")
        TextField("Food name", text: $nameField, onCommit: { food.name = nameField })
        TextField("Food emoji", text: $emojiField, onCommit: { food.emoji = emojiField })
        TextField("Food category", text: $categoryField, onCommit: { food.category = categoryField })
        HStack {
          Stepper("Price: \(priceField)", value: $priceField, step: 5) { _ in food.price = Price(priceField, currency: currencyField) }
          Spacer()
          Picker("Currency", selection: $currencyField) {
            ForEach(Price.Currency.allCases, id: \.self) { currency in
              Text(currency.rawValue)
            }
          }
          .onChange(of: currencyField) { _ in food.price = Price(priceField, currency: currencyField) }
        }
      }
      .padding()
      .border(Color.gray)
    }
  }
}

struct SetDocumentView_Previews: PreviewProvider {
  static var previews: some View {
    SetDocumentView()
  }
}
