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
  
  private static let googleSignInCredentialHandler: (AuthCredential?) -> Void = { credential in
    guard let credential = credential else { return }
    EasyAuth.signIn(with: credential) { error in
      if let error = error {
        print(error.localizedDescription)
      }
    }
  }
  
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
  
  // MARK: - Internal Static Methods
  
  internal static func prepare() {
    GAppAuth.shared.appendAuthorizationRealm(OIDScopeEmail)
    GAppAuth.shared.retrieveExistingAuthorizationState()
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

#if os(iOS)
import GAppAuth_iOS

@available(iOS 13.0, *)
extension EasyAuth {
  
  // MARK: - Public Static Methods
  
  public static func signInWithGoogle(clientID: String, completion: @escaping (Error?) -> Void = { _ in }) {
    let _clientID = "\(clientID).apps.googleusercontent.com"
    let redirectURI = "com.googleusercontent.apps.\(clientID):/oauthredirect"
    getCredential(clientID: _clientID, redirectUri: redirectURI, completion: googleSignInCredentialHandler)
  }
  
  // MARK: - Private Static Methods
  
  private static func getCredential(clientID: String, redirectUri: String, completion: @escaping (AuthCredential?) -> Void) {
    do {
      try GAppAuth.shared.authorize(in: UIApplication.shared.windows.first!.rootViewController!, clientID: clientID, redirectUri: redirectUri) { _ in
        guard
          GAppAuth.shared.isAuthorized(),
          let authorization = GAppAuth.shared.getCurrentAuthorization(),
          let accessToken = authorization.authState.lastTokenResponse?.accessToken,
          let idToken = authorization.authState.lastTokenResponse?.idToken
        else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        completion(credential)
      }
    } catch let error {
      print(error.localizedDescription)
      completion(nil)
    }
  }
}

#elseif os(macOS)
import Cocoa
import AppKit
import GAppAuth_macOS

extension EasyAuth {
  
  // MARK: - Public Static Methods
  
  public static func signInWithGoogle(clientID: String, secret: String, completion: @escaping (Error?) -> Void = { _ in }) {
    let _clientID = "\(clientID).apps.googleusercontent.com"
    let redirectURI = "com.googleusercontent.apps.\(clientID):/oauthredirect"
    getCredential(clientID: _clientID, redirectUri: redirectURI, secret: secret, completion: googleSignInCredentialHandler)
  }
  
  public static func handle(event: NSAppleEventDescriptor) {
    let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue ?? ""
    let url = URL(string: urlString)!
    _ = GAppAuth.shared.continueAuthorization(with: url, callback: nil)
  }
  
  // MARK: - Private Static Methods
  
  private static func getCredential(clientID: String, redirectUri: String, secret: String, completion: @escaping (AuthCredential?) -> Void) {
    do {
      try GAppAuth.shared.authorize(clientID: clientID, clientSecret: secret, redirectUri: redirectUri) { _ in
        guard
          GAppAuth.shared.isAuthorized(),
          let authorization = GAppAuth.shared.getCurrentAuthorization(),
          let accessToken = authorization.authState.lastTokenResponse?.accessToken,
          let idToken = authorization.authState.lastTokenResponse?.idToken
        else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        completion(credential)
      }
    } catch let error {
      print(error.localizedDescription)
      completion(nil)
    }
  }
}

#endif
