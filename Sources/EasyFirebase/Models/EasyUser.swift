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
public protocol EasyUser: Document {
  
  // MARK: - Properties
  
  /// The user's last signon date.
  ///
  /// This value is automatically updated each time the user logs into your application.
  var lastSignon: Date { get set }
  
  /// The user's display name.
  ///
  /// This value is automatically updated to a suggested display name when an account is created.
  var displayName: String { get set }
  
  /// The user's username.
  ///
  /// This value is automatically generated based on the user's email upon account creation.
  var username: String { get set }
  
  /// The user's email address.
  var email: String { get set }
  
  /// The user's last logged-in app version.
  ///
  /// This value is automatically updated when the user logs in.
  var appVersion: String { get set }
  
  /// The user's FCM device token.
  ///
  /// This value is automatically updated.
  var deviceToken: String? { get set }
  
  /// The user's notifications.
  ///
  /// Send notifications to a user using ``EasyMessaging``.
  var notifications: [MessagingNotification] { get set }
  
  /// The user's disabled notification categories.
  ///
  /// Any messages with a ``MessageCategory`` that is in this array will not be send to the recipient.
  var disabledMessageCategories: [MessageCategory] { get set }
  
  /// The user's app progression.
  ///
  /// This is a utility variable that you can use to keep track of tutorial progress, user progression, etc.
  ///
  /// There are a few preset values:
  ///
  /// - `-1` means the user has just been initalized.
  /// - `0` means the user data has been pushed to Firestore.
  /// - `1` and above are values you can customize.
  var progress: Int { get set }
  
  // MARK: - Initalizers
  
  init()
}

@available(iOS 13.0, *)
public extension EasyUser {
  
  // MARK: - Public Initalizers
  
  init() {
    self.init()
    lastSignon = Date()
    displayName = "Guest"
    username = "guest-user"
    email = "test@example.com"
    appVersion = Bundle.versionString
    deviceToken = "-"
    notifications = []
    disabledMessageCategories = []
    progress = -1
  }
  
  init?(from user: User) {
    guard let email = user.email else { return nil }
    self.init()
    id = user.uid
    username = email.removeDomainFromEmail()
    notifications = []
    disabledMessageCategories = []
    displayName = user.displayName ?? username
    self.email = email
    deviceToken = Messaging.messaging().fcmToken
    progress = -1
  }
  
  // MARK: - Public Static Methods
  
  static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
}
