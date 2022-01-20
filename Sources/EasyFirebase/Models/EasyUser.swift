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
  
  /// The user's username.
  ///
  /// This value is automatically generated based on the user's email upon account creation.
  public internal(set) var username: String
  
  /// The user's display name.
  ///
  /// This value is automatically updated to a suggested display name when an account is created.
  public internal(set) var displayName: String
  
  /// The user's profile image.
  ///
  /// If the user uses a third-party authentication service like Google, this image will automatically update.
  /// You can specify a default profile image by setting `EasyAuth.defaultProfileImageURLs`.
  public var profileImageURL: URL?
  
  // MARK: - Inherited Properties
  
  public var index: Int?
  public var id: String
  public var dateCreated: Date
  
  // MARK: - Public Initalizers
  
  public required init?(from user: User) {
    id = user.uid
    dateCreated = Date()
    guard let email = user.email else { return nil }
    deviceToken = EasyMessaging.deviceToken
    appVersion = Bundle.versionString
    lastSignon = Date()
    self.email = email
    username = email.removeDomainFromEmail()
    displayName = user.displayName ?? username
    profileImageURL = user.photoURL ?? EasyAuth.defaultProfileImageURLs.randomElement()!
  }
  
  public init() {
    id = "Guest"
    dateCreated = Date()
    deviceToken = "-"
    appVersion = Bundle.versionString
    lastSignon = Date()
    email = "guest@easy-firebase.com"
    username = "guest-user"
    displayName = "Guest"
    profileImageURL = EasyAuth.defaultProfileImageURLs.randomElement()!
  }
}

@available(iOS 13.0, *)
public extension EasyUser {
  
  // MARK: - Public Methods
  
  /**
   Updates the current user's email address.
   
   - parameter newEmail: The new email to update with.
   - parameter completion: The completion handler.
   */
  func updateEmail(to newEmail: String, completion: @escaping (Error?) -> Void) {
    guard assertAuthMatches() else { return }
    authUser?.updateEmail(to: newEmail) { [self] error in
      if error == nil {
        email = newEmail
      }
      completion(error)
    }
  }
  
  /**
   Updates the current user's display name.
   
   - parameter newName: The new display name to update with.
   - parameter completion: The completion handler.
   */
  func updateDisplayName(to newName: String, completion: @escaping (Error?) -> Void) {
    guard assertAuthMatches() else { return }
    if let authUser = authUser {
      let changeRequest = authUser.createProfileChangeRequest()
      changeRequest.displayName = newName
      changeRequest.commitChanges { [self] error in
        if error == nil {
          self.displayName = newName
        }
        completion(error)
      }
    }
  }
  
  /**
   Updates the current user's photo URL.
   
   - parameter url: The new photo URL to update with.
   - parameter completion: The completion handler.
   */
  func updatePhoto(with url: URL, completion: @escaping (Error?) -> Void) {
    guard assertAuthMatches() else { return }
    if let authUser = authUser {
      let changeRequest = authUser.createProfileChangeRequest()
      changeRequest.photoURL = url
      changeRequest.commitChanges { error in
        if error == nil {
          self.profileImageURL = url
        }
        completion(error)
      }
    }
  }
  
  /**
   Updates the current user's photo, using data.
   
   - parameter data: The data of the new photo to update with.
   - parameter completion: The completion handler.
   */
  func updatePhoto(with data: Data, completion: @escaping (Error?) -> Void) {
    guard assertAuthMatches() else { return }
    EasyStorage.put(data, to: StorageResource(id: id)) { [self] url in
      guard let url = url else { return }
      updatePhoto(with: url, completion: completion)
    }
  }
  
  /**
   Updates the current user's password.
   
   - parameter newPassword: The new password to update with.
   - parameter completion: The completion handler.
   */
  func updatePassword(to newPassword: String, completion: @escaping (Error?) -> Void) {
    guard assertAuthMatches() else { return }
    if let authUser = authUser {
      authUser.updatePassword(to: newPassword, completion: completion)
    }
  }
  
  /**
   Sends an email verification on the current user's behalf.
   
   - parameter completion: The completion handler.
   */
  func sendEmailVerification(completion: @escaping (Error?) -> Void) {
    if let authUser = authUser {
      authUser.sendEmailVerification(completion: completion)
    }
  }
  
  /**
   Refreshes the `emailVerified` static property of `EasyAuth`.
   */
  func refreshEmailVerifcationStatus() {
    guard assertAuthMatches() else { return }
    if let authUser = authUser {
      EasyAuth.emailVerified = authUser.isEmailVerified
    }
  }
  
  /**
   Send a password reset request to the associated email.
   
   - parameter email: The email to send the password reset request to.
   - parameter completion: The completion handler.
   */
  func sendPasswordReset(toEmail email: String, completion: @escaping (Error?) -> Void) {
    Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
  }
  
  /**
   Deletes the current user.
   
   ⚠️ **Warning!** This method will *not* ask for confirmation. Implement that within your app!
   
   - parameter completion: The completion handler
   */
  func delete(completion: @escaping (Error?) -> Void) {
    guard assertAuthMatches() else { return }
    if let authUser = authUser {
      authUser.delete { error in
        completion(error)
        // TODO: Delete the user object in Firestore.
      }
    }
  }
  
  // MARK: - Private Properties
  
  private var authUser: User? {
    Auth.auth().currentUser
  }
  
  // MARK: - Private Methods
  
  private func assertAuthMatches() -> Bool {
    guard let uid = Auth.auth().currentUser?.uid else {
      return false
    }
    return uid == id
  }
}
