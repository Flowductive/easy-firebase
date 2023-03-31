//
//  GetDocumentView.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/23/22.
//

import SwiftUI
import EasyFirebase

struct GetDocumentView: View {
  
  @State var food: FoodItem? = nil
  
  @State var idField: String = ""
  @State var error: String = ""
  @State var loading: Bool = false
  
  var body: some View {
    ScrollView {
      VStack {
        HStack {
          TextField("Document ID", text: $idField)
          Button("Get", action: read)
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
        }
      }
      .padding()
    }
  }
  
  func read() {
    loading = true
    Document.read(FoodItem.self, id: idField) { result in
      loading = false
      switch result {
      case .success(let success):
        self.food = success
      case .failure(let failure):
        self.error = failure.localizedDescription
      }
    }
  }
}

struct GetDocumentView_Previews: PreviewProvider {
  static var previews: some View {
    GetDocumentView()
  }
}
