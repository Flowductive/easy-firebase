//
//  SetDocumentView.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/8/22.
//

import SwiftUI

struct SetDocumentView: View {
  
  @StateObject var food: FoodItem = FoodItem()
  
  @State var nameField: String = "" { didSet { food.name = nameField }}
  @State var emojiField: String = "" { didSet { food.emoji = emojiField }}
  @State var categoryField: String = "" { didSet { food.category = categoryField }}
  
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
        TextField("Food name", text: $nameField)
        TextField("Food emoji", text: $emojiField)
        TextField("Food category", text: $categoryField)
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
