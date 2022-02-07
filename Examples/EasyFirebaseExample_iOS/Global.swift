//
//  Global.swift
//  EasyFirebaseExample_iOS
//
//  Created by Ben Myers on 2/6/22.
//

import SwiftUI

/**
 A global environment object, passed from view to view via the SwiftUI environment.
 */
class Global: ObservableObject {
  
  // MARK: - Wrapped Properties
  
  /// The current user.
  @Published var user: ExampleUser
  
  // MARK: - Initalizers
  
  init() {
    user = ExampleUser()
  }
}
