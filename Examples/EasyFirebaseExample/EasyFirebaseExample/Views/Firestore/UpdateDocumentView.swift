//
//  UpdateDocumentView.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/23/22.
//

import SwiftUI
import EasyFirebase

struct UpdateDocumentView: View {
  
  @State var food: FoodItem?
  
  @State var idField: String = ""
  @State var nameField: String = ""
  @State var emojiField: String = ""
  @State var categoryField: String = ""
  
  @State var error: String = ""
  
  var body: some View {
    ScrollView {
      VStack {
        VStack {
          HStack {
            TextField("Document ID", text: $idField)
            Button("Get") {
              Document.read(FoodItem.self, id: idField) { result in
                food = try? result.get()
              }
            }
          }
          Group {
            HStack {
              TextField("New food name", text: $nameField)
              Button("Update name") {
                food?.$name.set(nameField, completion: { error in
                  self.error = error?.localizedDescription ?? ""
                })
              }
            }
            HStack {
              TextField("New food emoji", text: $emojiField)
              Button("Update emoji") {
                food?.$emoji.set(emojiField, completion: { error in
                  self.error = error?.localizedDescription ?? ""
                })
              }
              Button("Remove emoji") {
                food?.$emoji.remove(completion: { error in
                  self.error = error?.localizedDescription ?? ""
                })
              }
            }
            HStack {
              TextField("New food category", text: $categoryField)
              Button("Update category") {
                food?.$name.set(categoryField, completion: { error in
                  self.error = error?.localizedDescription ?? ""
                })
              }
            }
            HStack {
              Button("Decrease price by 1") {
                food?.price.$amount.increment(by: -1, completion: { error in
                  self.error = error?.localizedDescription ?? ""
                })
              }
              Button("Increase price by 1") {
                food?.price.$amount.increment(by: 1, completion: { error in
                  self.error = error?.localizedDescription ?? ""
                })
              }
            }
          }
          .disabled(food == nil)
        }
        .padding()
        .border(.gray)
        Text(error).foregroundColor(.red)
        if let food {
          FoodItemView(food: food)
        }
      }
      .padding()
    }
  }
}

struct UpdateDocumentView_Previews: PreviewProvider {
  static var previews: some View {
    UpdateDocumentView()
  }
}
