//
//  EasyFirebaseExampleApp.swift
//  EasyFirebaseExample
//
//  Created by Ben Myers on 10/8/22.
//

import SwiftUI
import Firebase

@main
struct EasyFirebaseExampleApp: App {
  
  var body: some Scene {
    WindowGroup {
      ContentView().onAppear {
        FirebaseApp.configure()
      }
    }
  }
}
