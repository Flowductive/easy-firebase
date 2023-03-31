//
//  ListenDocumentView.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/23/22.
//

import SwiftUI
import EasyFirebase

struct ListenDocumentView: View {
  
  @State var food: FoodItem?
  
  @State var idField: String = ""
  @State var error: String = ""
  @State var loading: Bool = false
  
  @State var listening: Bool = false
  
  var body: some View {
    ScrollView {
      VStack {
        HStack {
          TextField("Document ID", text: $idField)
          Button("Start listening", action: listen)
        }
        .padding()
        .border(.gray)
        if !error.isEmpty {
          Text(error).foregroundColor(.red)
        } else if loading {
          Text("Loading...")
        }
        if let food {
          FoodItemView(food: food)
          Text("Listening: \(listening ? "YES" : "NO")")
          Button("Stop listening", action: stop)
        }
      }
      .padding()
    }
  }
  
  func listen() {
    stop()
    error = ""
    loading = true
    Document.listen(FoodItem.self, id: idField, bindTo: $food) { error in
      self.loading = false
      self.listening = true
      self.error = error?.localizedDescription ?? ""
    }
  }
  
  func stop() {
    food?.listener?.remove()
    listening = false
  }
}

struct ListenDocumentView_Previews: PreviewProvider {
  static var previews: some View {
    ListenDocumentView()
  }
}
