//
//  File.swift
//  
//
//  Created by Ben Myers on 8/20/22.
//

import Foundation

internal enum SessionError: Error, Equatable {
  
  /// An internal code error.
  case internalError
  
  /// A session has already been started.
  case sessionAlreadyActive
  
  /// A session tried to be cancelled, but it was `nil`.
  case noSessionExists
  
  /// A communication error occured with the online session.
  case communicationError
  
  /// Information about the session failed to fetch.
  case fetchFailed
  
  /// The user is not a host, so they lack permission to perform the action.
  case noHostPermission
  
  /// An issue occured while trying to leave the session.
  case leaveError
  
  /// An issue occured while trying to end the session.
  case endError
  
  /// The user is already the host of the session.
  case alreadyHost
  
  /// The user is not in a session.
  case notInSession
  
  /// The user is already in a session.
  case alreadyInSession
  
  /// Some issue(s) occured with trying to leave multiple sessions;
  case multiLeaveError(count: Int)
}

extension SessionError: LocalizedError {
  
  // MARK: - Properties
  
  var errorDescription: String? {
    switch self {
    case .internalError: return "An internal error occured."
    case .sessionAlreadyActive: return "A session has already been started."
    case .noSessionExists: return "Your session does not exist."
    case .communicationError: return "A communication error occured."
    case .fetchFailed: return "The information for your session could not be fetched."
    case .noHostPermission: return "You are missing privliges to perform this action."
    case .leaveError: return "An issue occured while you left your session."
    case .endError: return "Your session could not be ended."
    case .alreadyHost: return "You are already the host."
    case .notInSession: return "You are not in this session."
    case .alreadyInSession: return "You are already in a session."
    case .multiLeaveError(count: let i): return "An issue occured leaving \(i) session(s)."
    }
  }
}
