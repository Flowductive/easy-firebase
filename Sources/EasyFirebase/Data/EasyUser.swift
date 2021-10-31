//
//  EasyUser.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation
import Firebase
import FirebaseAuth

open class EasyUser: Document {
  
  // MARK: - Conforming Properties
  
  public var id: String
  public var dateCreated: Date
  
  // MARK: - Public Properties
  
  /// The user's last signon date
  public var lastSignon: Date
  
  /// The user's display name
  public var displayName: String
  
  /// The user's username
  public var username: String
  
  /// The user's email address
  public var email: String
  
  /// The user's last logged-in app version
  public var appVersion: String
  
  // MARK: - Public Initalizers
  
  public init?(from user: User) {
    guard let email = user.email else { return nil }
    id = user.uid
    dateCreated = Date()
    lastSignon = Date()
    username = email.removeDomainFromEmail()
    displayName = user.displayName ?? username
    self.email = email
    appVersion = Bundle.versionString
  }
  
  // MARK: - Conforming Static Methods
  
  public static func == (lhs: EasyUser, rhs: EasyUser) -> Bool {
    return lhs.id == rhs.id
  }
}
