//
//  SetDocumentView.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/8/22.
//

import SwiftUI

struct SetDocumentView: View {
  
  var body: some View {
    ScrollView {
      VStack {
        Text("Set Document").font(.title2)
        Divider()
        VStack {
          Text("New document")
          HStack {
//            TextField("")
          }
        }
        .padding()
        .border(Color.gray)
      }
    }
  }
}

struct SetDocumentView_Previews: PreviewProvider {
  static var previews: some View {
    SetDocumentView()
  }
}
