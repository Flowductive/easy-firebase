//
//  EasyAuth.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation
import Firebase
import FirebaseAuth

/**
 `EasyAuth` is a service manager for various functions related to FirebaseAuth.
 
 Use `EasyAuth` to sign in and out with ease:
 
 - Use ``createAccount(email:password:completion:)`` to quickly create an account with an email and password.
 - Use ``signIn(email:password:completion:)`` to quickly sign in with an email and password.
 - Use ``signIn(with:completion:)`` to quickly sign in with any credential.
 - Use ``signInWithGoogle(clientID:completion:)`` to quickly Sign In with Google on an iOS device.
 - Use ``signInWithGoogle(clientID:secret:completion:)`` to quickly Sign In with Google on a macOS device.
 - Use ``signInWithApple()`` to quickly Sign In with Apple on an iOS or macOS device.
 
 You can also use `EasyAuth`'s ``Manage`` sub-struct to manage your user's account, including email, password, profile image and more.
 */
@available(iOS 13.0, *)
public class EasyAuth: NSObject {
  
  // MARK: - Public Static Properties
  
  /// Whether the user's email has been verified.
  ///
  /// This value will always be `true` when a user signs in with Apple or Google.
  public private(set) static var emailVerified: Bool = false
  
  /// The user's account provider.
  ///
  /// This value automatically updates to `.email`, `.apple`, or `.google` when signing in.
  ///
  /// ⚠️ **Note:** If the provider is unknown, the value will be set to `.unknown`.
  public private(set) static var accountProvider: Provider = .unknown
  
  /// The user's auth handle.
  ///
  /// When the auth state changes, this handle is called.
  public private(set) static var authHandle: AuthStateDidChangeListenerHandle?
  
  /// Whether the user is currently signed in.
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
        EasyFirebase.log(error: error)
      }
    }
  }
  
  // MARK: - Private Properties
  
  private var currentNonce: String?
  
  // MARK: - Public Static Methods
  
  /**
   Creates a new account via email.
   
   ⚠️ **Note:** You will need to check the strength of the password, and validate a confirm password, yourself.
   
   - parameter email: The email to associate with the account.
   - parameter password: The password for the account.
   - parameter completion: The completion handler.
   */
  public static func createAccount(email: String, password: String, completion: @escaping (Error?) -> Void) {
    auth.createUser(withEmail: email, password: password) { authResult, error in
      handleSignedIn(result: authResult, error: error, completion: completion)
    }
  }
  
  /**
   Signs in the user via email.
   
   - parameter email: The account email.
   - parameter password: The account password.
   - parameter completion: The completion handler.
   */
  public static func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
    accountProvider = .email
    auth.signIn(withEmail: email, password: password) { authResult, error in
      handleSignedIn(result: authResult, error: error, completion: completion)
    }
  }
  
  /**
   Signs in the user via credential.
   
   ⚠️ **Note:** If you are using Sign In with Google on iOS, use ``signInWithGoogle(clientID:completion:)`` instead.
   
   ⚠️ **Note:** If you are using Sign In with Google on macOS, use ``signInWithGoogle(clientID:secret:completion:)`` instead.
   
   ⚠️ **Note:** If you are using Sign In with Apple, use ``signInWithApple()`` instead.
   */
  public static func signIn(with credential: AuthCredential, completion: @escaping (Error?) -> Void) {
    auth.signIn(with: credential) { authResult, error in
      handleSignedIn(result: authResult, error: error, completion: completion)
    }
  }
  
  /**
   Signs out the user.
   */
  public static func signOut() {
    do {
      try auth.signOut()
    } catch let error {
      EasyFirebase.log(error: error)
    }
  }
  
  /**
   Allows you to set a handler for when the user is updated.
   
   - parameter action: The action to perform when the user is updated.
   */
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
  
  // MARK: - Internal Static Methods
  
  internal static func prepare() {
    GAppAuth.shared.appendAuthorizationRealm(OIDScopeEmail)
    GAppAuth.shared.retrieveExistingAuthorizationState()
  }
  
  // MARK: - Private Static Methods
  
  private static func onAuthChange<T>(perform action: @escaping (T?) -> Void) where T: EasyUser {
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
  
  private static func handleSignedIn(result authResult: AuthDataResult?, error: Error?, completion: @escaping (Error?) -> Void) {
    guard let authResult = authResult else {
      EasyFirebase.log(error: error)
      completion(error)
      return
    }
    let authUser = authResult.user
    emailVerified = authUser.isEmailVerified
    if let provider = Provider(rawValue: authResult.credential?.provider ?? "Unknown") {
      accountProvider = provider
    }
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
  
  /**
   Signs in with Google on iOS.
   
   To get your Client ID, go to the [Google Cloud Deveeloper Console](https://console.cloud.google.com/apis/dashboard) > Credentials > Create Credentials > OAuth Client ID and create an OAuth Client ID for the iOS application type.
   
   ⚠️ **Note:** When passing the `clientID`, ensure it is in the form xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx where `apps.googleusercontent.com` is *not* included. The `clientID` is alphanumeric and should *not* include any punctuation.
   
   - parameter clientID: The project's client ID.
   - parameter completion: The completion handler.
   */
  public static func signInWithGoogle(clientID: String, completion: @escaping (Error?) -> Void = { _ in }) {
    let _clientID = "\(clientID).apps.googleusercontent.com"
    let redirectURI = "com.googleusercontent.apps.\(clientID):/oauthredirect"
    accountProvider = .google
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
      EasyFirebase.log(error: error)
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
  
  /**
   Signs in with Google on macOS.
   
   To get your Client ID, go to the [Google Cloud Deveeloper Console](https://console.cloud.google.com/apis/dashboard) > Credentials > Create Credentials > OAuth Client ID and create an OAuth Client ID for the Web application type. You can leave the other fields blank.
   
   ⚠️ **Note:** When passing the `clientID`, ensure it is in the form xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx where `apps.googleusercontent.com` is *not* included. The `clientID` is alphanumeric and should *not* include any punctuation.
   
   - parameter clientID: The project's client ID.
   - parameter completion: The completion handler.
   */
  public static func signInWithGoogle(clientID: String, secret: String, completion: @escaping (Error?) -> Void = { _ in }) {
    let _clientID = "\(clientID).apps.googleusercontent.com"
    let redirectURI = "com.googleusercontent.apps.\(clientID):/oauthredirect"
    accountProvider = .google
    getCredential(clientID: _clientID, redirectUri: redirectURI, secret: secret, completion: googleSignInCredentialHandler)
  }
  
  /**
   Handle a completed sign-in from the user's browser.
   
   When Google Sign-In is complete, your web browser will ask if it can open your redirect URI in your app. This method will handle such.
   
   In your macOS's `AppDelegate.swift`, implement `applicationDidFinishLaunching(_:)`:
   
   ```swift
   func applicationDidFinishLaunching(_ aNotification: Notification) {
     NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
   }
   ```
   
   ℹ️ *Using the SwiftUI lifecycle? You can create an `AppDelegate` by viewing* [this discussion](https://developer.apple.com/forums/thread/659537#answer-title) *on the Developer Forums.*
   
   In `AppDelegate.swift`, add an Objective-C exposed method `handleEvent(event:replyEvent:)`:
   
   ```swift
   @objc private func handleEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
     EasyAuth.handle(event: event)
   }
   ```
   
   `EasyAuth` will handle the rest when ``handle(event:)`` is called.
   */
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
      EasyFirebase.log(error: error)
      completion(nil)
    }
  }
}

#endif

import AuthenticationServices

@available(iOS 13, *)
extension EasyAuth: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  
  // MARK: - Private Static Properties
  
  private static var shared = EasyAuth()
  
  // MARK: - Public Static Methods
  
  /**
   Signs in with Apple.
   
   In order for this sign-in method to work on your target, you'll need to configure Sign In with Apple to work on your Xcode project.
   
   1. Join the [Apple Developer Program](https://developer.apple.com/programs/).
   2. Enable Sign In with Apple on your app on the [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources) page of Apple's developer site by going to More > Configure > Add Email Source. Add your website domain under **Domains and Subdomains**, and add `noreply@YOUR_FIREBASE_PROJECT_ID.firebaseapp.co` under **Email Addressess**.
   3. Add the **Sign In with Apple** capability to your project.
   
   In SwiftUI, create the Sign In with Apple button. Call ``signInWithApple()`` within the `onRequest` block:
   
   ```swift
   import AuthenticationServices
   
   // ...
   
   SignInWithAppleButton(onRequest: { _ in
     EasyAuth.signInWithApple()
   }, onCompletion: { _ in })
   ```
   */
  public static func signInWithApple() {
    let nonce = String.nonce()
    shared.currentNonce = nonce
    accountProvider = .apple
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = nonce.sha256()
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = shared
    authorizationController.presentationContextProvider = shared
    authorizationController.performRequests()
  }
  
  // MARK: - Implementation
  
  /**
   The presentation anchor implementation for `ASAuthorizationControllerDelegate`.
   
   ⚠️ You do not need to call this method. You can override it to customize the view controller for which Sign In with Apple appears, if you'd like.
   */
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    #if os(iOS)
    return ASPresentationAnchor()
    #elseif os(macOS)
    return NSApplication.shared.windows.first!
    #endif
  }
  
  /**
   Handles a finished Sign In with Apple state.
   
   ⚠️ You do not need to call this method. You can override it to handle a success state, if you'd like.
   
   - parameter controller: The authorization controller that just completed
   - parameter authorization: The Sign In with Apple authorization
   */
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        EasyFirebase.log(error: "Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        EasyFirebase.log(error: "Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      EasyAuth.signIn(with: credential, completion: { _ in })
    }
  }
  
  /**
   Handles a failed Sign In with Apple state.
   
   ⚠️ You do not need to call this method. You can override it to handle a failed state, if you'd like.
   
   - parameter controller: The authorization controller that just completed
   - parameter error: The error that occured during the process
   */
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    EasyFirebase.log(error: "Sign in with Apple errored: \(error)")
  }
}
