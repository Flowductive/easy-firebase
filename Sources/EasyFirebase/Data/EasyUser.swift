//
//  EasyUser.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation

public protocol EasyUser: Document {
  
  // MARK: - Properties
  
  /// The user's last signon date
  var lastSignon: Date { get }
  
  /// The user's display name
  var displayName: String { get }
  
  /// The user's username
  var username: String { get }
  
  /// The user's email address
  var email: String { get }
  
  /// The user's last logged-in app version
  var appVersion: String { get }
}
