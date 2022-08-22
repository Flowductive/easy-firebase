//
//  File.swift
//  
//
//  Created by Ben Myers on 8/20/22.
//

import Foundation

internal enum SessionError: Error {
  
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
  
  /// Some issue(s) occured with trying to leave multiple sessions;
  case multiLeaveError(count: Int)
}

extension SessionError: LocalizedError {
  
  // MARK: - Properties
  
  var errorDescription: String? {
    switch self {
    case .internalError: return "An internal error occured."
    case .sessionAlreadyActive: return "A session has already been started."
    case .noSessionExists: return "The session does not exist."
    case .communicationError: return "A communication error occured."
    case .fetchFailed: return "The information for the session could not be fetched."
    case .noHostPermission: return "Missing privliges to perform this action."
    case .leaveError: return "An issue occured while you left your session."
    case .multiLeaveError(count: let i): return "An issue occured leaving \(i) session(s)."
    }
  }
}
