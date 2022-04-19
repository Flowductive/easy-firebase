//
//  EasyFirebaseExample_iOSApp.swift
//  EasyFirebaseExample_iOS
//
//  Created by Ben Myers on 2/4/22.
//

import SwiftUI
import EasyFirebase

@main
struct EasyFirebaseExample_iOSApp: App {
  
  /// The Global `EnvironmentObject`.
  var global = Global()
  
  // MARK: - Body Scene
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(global)
        .onAppear {
          EasyFirebase.configure()
          EasyAuth.onUserUpdate(ofType: ExampleUser.self) { user in
            // Check to make sure the `user` object passed in the closure is the right type, and is not `nil`
            guard let user = user else { return }
            // Set your global `user` instance used across the app
            global.user = user
          }
        }
    }
  }
}
