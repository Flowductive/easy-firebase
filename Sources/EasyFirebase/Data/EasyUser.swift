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

@available(iOS 13.0, *)
public protocol EasyUser: Document {
  
  // MARK: - Properties
  
  /// The user's last signon date.
  var lastSignon: Date { get set }
  
  /// The user's display name.
  var displayName: String { get set }
  
  /// The user's username.
  var username: String { get set }
  
  /// The user's email address.
  var email: String { get set }
  
  /// The user's last logged-in app version.
  var appVersion: String { get set }
  
  /// The user's FCM device token.
  var deviceToken: String? { get set }
  
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
extension EasyUser {
  
  // MARK: - Initalizers
  
  public init?(from user: User) {
    guard let email = user.email else { return nil }
    self.init()
    id = user.uid
    lastSignon = Date()
    username = email.removeDomainFromEmail()
    displayName = user.displayName ?? username
    self.email = email
    appVersion = Bundle.versionString
    deviceToken = Messaging.messaging().fcmToken
    progress = -1
  }
}
