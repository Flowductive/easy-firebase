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
  public private(set) static var authHandle: AuthStateDidChangeListenerHandle?
  
  // MARK: - Internal Static Properties
  
  internal static let auth = Auth.auth()
  
  // MARK: - Public Static Methods
  
  public static func createAccount(email: String, password: String, completion: @escaping (Error?) -> Void) {
    auth.createUser(withEmail: email, password: password) { authResult, error in
      handleSignedIn(result: authResult, error: error, completion: completion)
    }
  }
  
  public static func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
    auth.signIn(withEmail: email, password: password) { authResult, error in
      handleSignedIn(result: authResult, error: error, completion: completion)
    }
  }
  
  public static func signIn(with credential: AuthCredential, completion: @escaping (Error?) -> Void) {
    auth.signIn(with: credential) { authResult, error in
      handleSignedIn(result: authResult, error: error, completion: completion)
    }
  }
  
  public static func onAuthChange<T>(perform action: @escaping (T?) -> Void) where T: EasyUser {
    authHandle = auth.addStateDidChangeListener { _, user in
      guard let user = user, let easyUser = T(from: user) else { return }
      action(easyUser)
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
  
  private static func handleSignedIn(result authResult: AuthDataResult?, error: Error?, completion: @escaping (Error?) -> Void) {
    guard let authResult = authResult else {
      EasyFirebase.log(error: error)
      completion(error)
      return
    }
    let authUser = authResult.user
    emailVerified = authUser.isEmailVerified
    accountProvider = Provider(rawValue: authResult.credential?.provider ?? "Unknown") ?? .unknown
    completion(nil)
  }
  
  // MARK: - Enumerations
  
  public enum Provider: String, Codable {
    case unknown = "Unknown"
    case apple = "Apple"
    case google = "Google"
    case email = "Email"
  }
}
