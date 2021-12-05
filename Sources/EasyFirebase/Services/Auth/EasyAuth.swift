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
  
  public static var signedIn: Bool {
    return Auth.auth().currentUser != nil
  }
  
  // MARK: - Internal Static Properties
  
  internal static let auth = Auth.auth()
  
  // MARK: - Private Static Properties
  
  private static let listenerKey: EasyFirestore.ListenerKey = "EASY_USER_UPDATE"
  
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
    if let authHandle = authHandle {
      auth.removeStateDidChangeListener(authHandle)
    }
    authHandle = auth.addStateDidChangeListener { _, user in
      guard let user = user, let newUser = T(from: user) else { return }
      EasyFirestore.Retrieval.get(id: newUser.id, ofType: T.self) { document in
        guard let document = document else {
          action(newUser)
          newUser.set()
          return
        }
        action(document)
      }
    }
  }
  
  public static func onUserUpdate<T>(perform action: @escaping (T?) -> Void) where T: EasyUser {
    if let authHandle = authHandle {
      auth.removeStateDidChangeListener(authHandle)
    }
    authHandle = auth.addStateDidChangeListener { _, user in
      guard let user = user, let newUser = T(from: user) else { return }
      EasyFirestore.Listening.stop(listenerKey)
      EasyFirestore.Listening.listen(to: newUser.id, ofType: T.self, key: listenerKey) { document in
        guard let document = document else {
          action(newUser)
          newUser.set()
          return
        }
        action(document)
      }
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
