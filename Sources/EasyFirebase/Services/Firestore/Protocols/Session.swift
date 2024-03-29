//
//  Session.swift
//  
//
//  Created by Ben Myers on 8/20/22.
//

import Foundation

@available(iOS 13.0, *)
public protocol Session: Document {
  
  // MARK: - Public Properties
  
  /// The host of the session.
  var host: EasyUser.ID { get set }
  
  /// The session's users.
  var users: [EasyUser.ID] { get set }
  
  // MARK: - Public Initalizers
  
  init()
  init(host: EasyUser.ID)
}

@available(iOS 13.0, *)
public extension Session {
  
  // MARK: - Public Properties
  
  /// The session's users, including the host.
  var allUsers: [EasyUser.ID] {
    var copy = Array(users)
    if !copy.contains(host) { copy.append(host) }
    return copy
  }
  
  // MARK: - Public Initalizers
  
  init(host: EasyUser.ID) {
    self.init()
    self.host = host
    self.users = []
  }
}
