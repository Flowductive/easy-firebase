//
//  EasyUser.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseFirestore
import FirebaseFirestoreSwift

/**
 A fundamental user object.
 
 Extend your own user class from the `EasyUser` protocol to quickly create user objects that are compatabile with `EasyAuth`.
 
 All user objects come with `lastSignon`, `displayName`, `username`, `email`, `appVersion`, `deviceToken`, and `progress` support.
 
 ```swift
 class MyUser: EasyUser {
   
   var lastSignon: Date
   var displayName: String
   var username: String
   var email: String
   var appVersion: String
   var deviceToken: String?
   var id: String
   var dateCreated: Date
   var progress: Int
 
   var balance: Int = 0
      
   func addBalance() {
     balance += 1
   }
 }
 ```
 */
@available(iOS 13.0, *)
open class EasyUser: IndexedDocument {
  
  // MARK: - Public Properties
  
  /// The user's notifications.
  ///
  /// Send notifications to a user using ``EasyMessaging``.
  public var notifications: [MessagingNotification] = []
  
  /// The user's disabled notification categories.
  ///
  /// Any messages with a ``MessageCategory`` that is in this array will not be send to the recipient.
  public var disabledMessageCategories: [MessageCategory] = []
  
  /// The user's app progression.
  ///
  /// This is a utility variable that you can use to keep track of tutorial progress, user progression, etc.
  ///
  /// There are a few preset values:
  ///
  /// - `-1` means the user has just been initalized.
  /// - `0` means the user data has been pushed to Firestore.
  /// - `1` and above are values you can customize.
  public var progress: Int = -1
  
  // MARK: - Mixed Properties
  
  /// The user's FCM device token.
  ///
  /// This value is automatically updated.
  public internal(set) var deviceToken: String?
  
  /// The user's last logged-in app version.
  ///
  /// This value is automatically updated when the user logs in.
  public internal(set) var appVersion: String
  
  /// The user's last signon date.
  ///
  /// This value is automatically updated each time the user logs into your application.
  public internal(set) var lastSignon: Date
  
  /// The user's email address.
  public internal(set) var email: String
  
  /// The user's profile image.
  ///
  /// If the user uses a third-party authentication service like Google, this image will automatically update.
  /// You can specify a default profile image by setting `EasyAuth.defaultProfileImageURLs`.
  public var profileImageURL: String?
  
  // MARK: - Objective-C Exposed Mixed Properties
  
  /// The user's username.
  ///
  /// This value is automatically generated based on the user's email upon account creation.
  @objc public internal(set) var username: String
  
  /// The user's display name.
  ///
  /// This value is automatically updated to a suggested display name when an account is created.
  @objc public internal(set) var displayName: String
  
  // MARK: - Inherited Properties
  
  public var index: Int?
  public var id: String
  public var dateCreated: Date
  
  // MARK: - Public Initalizers
  
  public required init() {
    id = "Guest"
    dateCreated = Date()
    deviceToken = "-"
    appVersion = Bundle.versionString
    lastSignon = Date()
    email = "guest@easy-firebase.com"
    username = "guest-user"
    displayName = "Guest"
    profileImageURL = EasyAuth.defaultProfileImageURLs.randomElement()!.absoluteString
  }
}

@available(iOS 13.0, *)
public extension EasyUser {
  
  // MARK: - Public Static Properties
  
  /// The default random username suggestion generator.
  static var defaultSuggestionGenerator: (String) -> String {{ username in
    let randomInt = Int.random(in: 0...99)
    return "\(username)\(randomInt)"
  }}
  
  // MARK: - Public Static Methods
  
  /**
   Gets an `EasyUser` from a `FirebaseAuth` user.
   
   - parameter user: The `FirebaseAuth` user to transform.
   - returns: An `EasyUser` instance.
   */
  static func get(from user: User) -> Self? {
    let newUser = Self()
    newUser.id = user.uid
    newUser.dateCreated = Date()
    guard let email = user.email else { return nil }
    newUser.deviceToken = EasyMessaging.deviceToken
    newUser.appVersion = Bundle.versionString
    newUser.lastSignon = Date()
    newUser.email = email
    newUser.username = email.removeDomainFromEmail()
    if newUser.username.count < 6 {
      newUser.username += String.random(length: 6 - newUser.username.count)
    }
    newUser.displayName = user.displayName ?? newUser.email.removeDomainFromEmail()
    newUser.profileImageURL = user.photoURL?.absoluteString ?? EasyAuth.defaultProfileImageURLs.randomElement()!.absoluteString
    newUser.updateAnalyticsUserProperties()
    newUser.refreshEmailVerifcationStatus()
    return newUser
  }
  
  // MARK: - Public Properties
  
  /// Returns whether the user is a guest (not signed in).
  var isGuest: Bool {
    return id == "Guest"
  }
  
  // MARK: - Public Methods
  
  /**
   Updates the current user's email address.
   
   - parameter newEmail: The new email to update with.
   - parameter type: The type of the user.
   - parameter completion: The completion handler.
   */
  func updateEmail<T>(to newEmail: String, ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { return }
    authUser?.updateEmail(to: newEmail) { [self] error in
      if error == nil {
        email = newEmail
        set(field: "email", using: \.email, ofUserType: T.self, completion: completion)
      }
      completion(error)
    }
  }
  
  /**
   Updates the user's username.
   
   This method is *safe*, meaning that it won't update the username if another user has an existing, matching username.
   
   If you wish to update the user's username regardless of whether it is unique, use ``unsafelyUpdateUsername(to:ofUserType:completion:)``.
   
   📌 **Important!** The completion block has two arguments. If the second `String?` value is `nil`, that means the username was successfully updated. Otherwise, if a non-`nil` value is passed, that means the username was *not* updated (and instead a suggested username is provided as the value).
   
   The `suggestionGenerator` parameter allows you to customize a random username to *suggest* based on the new username provided. For instance, if the username `myUsername` is unavailable, the generator can be customized to procure a new username `myUsername123`. If a random username is generated and is *still* taken, the generator will re-apply to the username previously generated (recursively).
   
   If no generator is provided, the default generator will append a random integer `0-99` to the end of the attempted username.
   
   ⚠️ **Note:** The suggested username returned in the completion block is not updated to be the user's new username when this method is called. Rather, it allows you to provide the user with the suggestion such that they can change it if they like.
   
   The completion handler has two arguments, an `Error?` and a `String?`. The first is the error that occurs while updating the username, if any. The second is the suggested username, created by the provided generator.
   
   # Example
   
   ```
   user.safelyUpdateUsername(to: "myNewUsername", ofUserType: MyUser.self,
                                    suggesting: { "\($0)\(Int.random(in: 0...999))" }
   ) { error, suggestion in
     if let error = error {
       // ...
     } else if let suggestion = suggestion {
       // Username taken, provide the user with this suggestion.
     } else {
       // Success! Username changed.
     }
   }
   ```
   
   - parameter newUsername: The username to update to.
   - parameter type: The type of the user.
   - parameter suggestionGenerator: A function that takes in a username and provides a new username (hopefully unique). See **Discussion** for more information.
   - parameter completion: The completion handler. See **Discussion** for more information.
   */
  func safelyUpdateUsername<T>(to newUsername: String,
                               ofType type: T.Type,
                               suggesting suggestionGenerator: @escaping (String) -> String = defaultSuggestionGenerator,
                               completion: @escaping (Error?, String?) -> Void) where T: EasyUser {
    EasyAuth.checkUsernameAvailable(newUsername, forUserType: T.self) { available in
      if available {
        self.unsafelyUpdateUsername(to: newUsername, ofUserType: T.self) { error in
          completion(error, nil)
          return
        }
      } else {
        self.getUniqueUsername(newUsername, using: suggestionGenerator) { suggestion in
          completion(nil, suggestion)
          return
        }
      }
    }
  }
  
  /**
   Updates the user's username.
   
   This method is *unsafe*, meaning that it will update the username regardless if there is another user with a matching username.
   
   If you wish to update the user's username if it is available and provide a suggested username upon failure, see ``safelyUpdateUsername(to:ofType:suggesting:completion:)``.
   
   - parameter newUsername: The username to update to.
   - parameter type: The type of the user.
   - parameter completion: The completion hander.
   */
  func unsafelyUpdateUsername<T>(to newUsername: String, ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    let oldUsername = username
    self.username = newUsername
    set(field: "username", using: \.username, ofUserType: T.self, completion: { error in
      if let error = error {
        completion(error)
        self.username = oldUsername
      } else {
        completion(nil)
      }
    })
  }
  
  /**
   Updates the current user's display name.
   
   - parameter newName: The new display name to update with.
   - parameter type: The type of the user.
   - parameter completion: The completion handler.
   */
  func updateDisplayName<T>(to newName: String, ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { return }
    if let authUser = authUser {
      let changeRequest = authUser.createProfileChangeRequest()
      changeRequest.displayName = newName
      changeRequest.commitChanges { [self] error in
        if error == nil {
          self.displayName = newName
          set(field: "displayName", using: \.displayName, ofUserType: T.self, completion: completion)
        } else {
          completion(error)
        }
      }
    }
  }
  
  /**
   Updates the current user's photo URL.
   
   - parameter url: The new photo URL to update with.
   - parameter type: The type of the user.
   - parameter completion: The completion handler.
   */
  func updatePhoto<T>(with url: URL, ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { completion(nil); return }
    if let authUser = authUser {
      let changeRequest = authUser.createProfileChangeRequest()
      changeRequest.photoURL = url
      changeRequest.commitChanges { error in
        if error == nil {
          self.profileImageURL = url.absoluteString
          Firestore.firestore().collection(String(describing: type)).document(self.id).updateData(["profileImageURL": url.absoluteString])
        }
        completion(error)
      }
    }
  }
  
  /**
   Updates the current user's photo, using data.
   
   - parameter data: The data of the new photo to update with.
   - parameter type: The type of the user.
   - parameter completion: The completion handler.
   */
  func updatePhoto<T>(with data: Data, ofUserType type: T.Type, progress: @escaping (Double) -> Void = { _ in }, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { completion(nil); return }
    EasyStorage.put(data, to: StorageResource(id: id, folder: "Profile Images"), progress: progress) { [self] url in
      guard let url = url else { completion(nil); return }
      updatePhoto(with: url, ofUserType: type, completion: completion)
    }
  }
  
  /**
   Updates the current user's password.
   
   - parameter newPassword: The new password to update with.
   - parameter completion: The completion handler.
   */
  func updatePassword(to newPassword: String, completion: @escaping (Error?) -> Void = { _ in }) {
    guard assertAuthMatches() else { completion(nil); return }
    if let authUser = authUser {
      authUser.updatePassword(to: newPassword, completion: completion)
    }
  }
  
  /**
   Sends an email verification on the current user's behalf.
   
   - parameter completion: The completion handler.
   */
  func sendEmailVerification(completion: @escaping (Error?) -> Void = { _ in }) {
    if let authUser = authUser {
      authUser.sendEmailVerification(completion: completion)
    }
  }
  
  /**
   Refreshes the `emailVerified` static property of `EasyAuth`.
   */
  func refreshEmailVerifcationStatus(completion: @escaping () -> Void = {}) {
    guard assertAuthMatches() else { completion(); return }
    if let authUser = authUser {
      authUser.reload(completion: { _ in
        guard let user = Auth.auth().currentUser else { completion(); return }
        EasyAuth.emailVerified = user.isEmailVerified
        let id = user.providerData.first?.providerID ?? ""
        EasyAuth.accountProvider = EasyAuth.Provider(provider: id)
        completion()
      })
    } else {
      completion()
    }
  }
  
  /**
   Send a password reset request to the associated email.
   
   - parameter email: The email to send the password reset request to.
   - parameter completion: The completion handler.
   */
  func sendPasswordReset(toEmail email: String, completion: @escaping (Error?) -> Void = { _ in }) {
    Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
  }
  
  /**
   Deletes the current user.
   
   ⚠️ **Warning!** This method will *not* ask for confirmation. Implement that within your app!
   
   - parameter type: The type of the user
   - parameter completion: The completion handler
   */
  func delete<T>(ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { return }
    if let authUser = authUser {
      EasyFirestore.Listening.stop(EasyAuth.listenerKey)
      authUser.delete { error in
        if let error = error {
          completion(error)
          return
        }
        EasyFirestore.Removal.remove(id: self.id, ofType: T.self, completion: completion)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          EasyAuth.signOut()
        }
      }
    }
  }
  
  // MARK: - Private Properties
  
  private var authUser: User? {
    Auth.auth().currentUser
  }
  
  // MARK: - Private Methods
  
  private func getUniqueUsername(_ base: String, using generator: @escaping (String) -> String, completion: @escaping (String) -> Void) {
    let new = generator(base)
    EasyAuth.checkUsernameAvailable(new, forUserType: Self.self) { available in
      if available {
        completion(new)
      } else {
        self.getUniqueUsername(new, using: generator, completion: completion)
      }
    }
  }
  
  private func assertAuthMatches() -> Bool {
    guard let uid = Auth.auth().currentUser?.uid else {
      return false
    }
    return uid == id
  }
}

fileprivate extension String {
  static func random(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
  }
}
