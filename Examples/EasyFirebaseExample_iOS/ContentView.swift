//
//  ContentView.swift
//  EasyFirebaseExample_iOS
//
//  Created by Ben Myers on 2/4/22.
//

import SwiftUI

struct ContentView: View {
  
  // MARK: - Body View
  
  var body: some View {
    TabView {
      AuthView().tabItem {
        Image(systemName: "person.fill")
        Text("Auth")
      }
      FirestoreView().tabItem {
        Image(systemName: "flame.fill")
        Text("Firestore")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
