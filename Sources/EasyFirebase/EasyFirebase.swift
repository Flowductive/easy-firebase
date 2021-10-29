//
//  File.swift
//  
//
//  Created by Ben Myers on 10/29/21.
//

import Foundation

/**
 Thanks for using EasyFirebase! 🎉
 
 EasyFirebase supports multiple Firebase services, including:
 
 - ``EasyFirestore``
 
 Additionally, you can set some module-wide settings here, including:
 
 - ``logLevel-swift.type.property``
 */
public struct EasyFirebase {
  
  // MARK: - Public Static Properties
  
  /// How detailed Firestore console out
  public static let logLevel: LogLevel = .none
  
  // MARK: - Internal Static Methods
  
  internal static func log(error: Any?) {
    guard logLevel.rawValue >= 1 else { return }
    if let error = error as? Error {
      print("[EasyFirestore] \(error.localizedDescription)")
    } else if let error = error {
      print("[EasyFirestore] ", error)
    }
  }
  
  internal static func log(_ item: Any?) {
    guard logLevel.rawValue >= 2 else { return }
    if let item = item {
      print("[EasyFirestore] ", item)
    }
  }
  
  // MARK: - Public Enumerations
  
  /**
   The log level for Firebase-related output.
   */
  public enum LogLevel: Int {
    
    /// Don't log any output
    case none = 0
    
    /// Only log errors
    case errors = 1
    
    /// Log errors and transfer messages
    case all = 2
  }
}
