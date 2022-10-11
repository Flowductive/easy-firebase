//
//  ContentView.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/8/22.
//

import SwiftUI

struct ContentView: View {
  
  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Firestore")) {
          NavigationLink("Set document", destination: { SetDocumentView() })
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
