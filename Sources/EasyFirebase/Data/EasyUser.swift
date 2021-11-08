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
  
  // MARK: - Initalizers
  
  init()
}

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
  }
}
