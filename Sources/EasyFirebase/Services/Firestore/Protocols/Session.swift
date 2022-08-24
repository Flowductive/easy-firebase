//
//  Session.swift
//  
//
//  Created by Ben Myers on 8/20/22.
//

import Foundation

public typealias SessionID = DocumentID

public protocol Session: Document {
  
  // MARK: - Public Properties
  
  /// The host of the session.
  var host: DocumentID { get set }
  
  /// The session's users.
  var users: [DocumentID] { get set }
  
  // MARK: - Public Initalizers
  
  init()
  init(host: DocumentID)
}

public extension Session {
  
  // MARK: - Public Properties
  
  /// The session's users, including the host.
  var allUsers: [DocumentID] {
    var copy = Array(users)
    copy.append(host)
    return copy
  }
  
  // MARK: - Public Initalizers
  
  init(host: DocumentID) {
    self.init()
    self.host = host
    self.users = []
  }
}
