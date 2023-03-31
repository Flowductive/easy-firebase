//
//  QueryDocumentsView.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 11/25/22.
//

import SwiftUI
import EasyFirebase

struct QueryDocumentsView: View {
  
  @State var foods: [FoodItem] = []
  
  @State var categoryField: String = ""
  @State var limitField: String = ""
  @State var descending: Bool = false
  @State var error: String = ""
  @State var loading: Bool = false
  
  var body: some View {
    ScrollView {
      VStack {
        HStack {
          TextField("Category", text: $categoryField)
          TextField("Limit", text: $limitField).frame(width: 50.0)
          Toggle("Descending", isOn: $descending)
          Button("Query", action: query)
        }
        .padding()
        .border(.gray)
        if !error.isEmpty {
          Text(error).foregroundColor(.red)
        } else if loading {
          Text("Loading...")
        }
        ForEach(foods) { food in
          FoodItemView(food: food)
        }
      }
      .padding()
    }
  }
  
  func query() {
    foods = []
    loading = true
    let path: PartialKeyPath<FoodItem> = \.$category
    Document.query(FoodItem.self)
      .where(path, .equals, categoryField)
      .order(by: path)
      .limit(to: Int(limitField) ?? 10)
      .execute { result in
        self.loading = false
        switch result {
        case .success(let success):
          self.foods.append(contentsOf: success)
        case .failure(let failure):
          self.error = failure.localizedDescription
        }
      }
  }
}

struct QueryDocumentsView_Previews: PreviewProvider {
  static var previews: some View {
    QueryDocumentsView()
  }
}
