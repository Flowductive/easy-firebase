//
//  EasyAuth.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation
import Firebase
import FirebaseAuth

@available(iOS 13.0, *)
public struct EasyAuth {
  
  // MARK: - Public Static Properties
  
  public private(set) static var emailVerified: Bool = false
  public private(set) static var accountProvider: Provider = .unknown
  
  // MARK: - Internal Static Properties
  
  internal static let auth = Auth.auth()
  
  // MARK: - Public Static Methods
  
  public static func createAccount<T>(email: String, password: String, completion: @escaping (T?, Error?) -> Void) where T: EasyUser {
    auth.createUser(withEmail: email, password: password) { authResult, error in
      handleSignedIn(result: authResult, error: error, completion: completion)
    }
  }
  
  public static func signIn<T>(email: String, password: String, completion: @escaping (T?, Error?) -> Void) where T: EasyUser {
    auth.signIn(withEmail: email, password: password) { authResult, error in
      handleSignedIn(result: authResult, error: error, completion: completion)
    }
  }
  
  public static func signIn<T>(with credential: AuthCredential, completion: @escaping (T?, Error?) -> Void) where T: EasyUser {
    auth.signIn(with: credential) { authResult, error in
      handleSignedIn(result: authResult, error: error, completion: completion)
    }
  }
  
  public static func signOut() {
    do {
      try auth.signOut()
    } catch let error {
      print(error)
    }
  }
  
  // MARK: - Private Static Methods
  
  private static func handleSignedIn<T>(result authResult: AuthDataResult?, error: Error?, completion: @escaping (T?, Error?) -> Void) where T: EasyUser {
    guard let authResult = authResult else {
      EasyFirebase.log(error: error)
      completion(nil, error)
      return
    }
    let authUser = authResult.user
    emailVerified = authUser.isEmailVerified
    let newUser = T(from: authUser)
    accountProvider = Provider(rawValue: authResult.credential?.provider ?? "Unknown") ?? .unknown
    completion(newUser, nil)
  }
  
  // MARK: - Enumerations
  
  public enum Provider: String, Codable {
    case unknown = "Unknown"
    case apple = "Apple"
    case google = "Google"
    case email = "Email"
  }
}
