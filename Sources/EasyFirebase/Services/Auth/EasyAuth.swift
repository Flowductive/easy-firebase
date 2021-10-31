//
//  EasyAuth.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation
import Firebase
import FirebaseAuth

public struct EasyAuth {
  
  // MARK: - Internal Static Properties
  
  internal static let auth = Auth.auth()
  
  // MARK: - Public Static Methods
  
  public static func createAccount(email: String, password: String, completion: @escaping (EasyUser?, Error?) -> Void) {
    auth.createUser(withEmail: email, password: password) { authResult, error in
      guard let authResult = authResult else {
        EasyFirebase.log(error: error)
        completion(nil, error)
        return
      }
      let newUser = EasyUser(from: authResult.user)
      completion(newUser, nil)
    }
  }
  
  public static func signIn(email: String, password: String, completion: @escaping (EasyUser?, Error?) -> Void) {
    
  }
}
