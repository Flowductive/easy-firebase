//
//  EasyFirebase.swift
//  
//
//  Created by Ben Myers on 10/29/21.
//

import Foundation
import Firebase

/**
 Thanks for using EasyFirebase! 🎉
 
 EasyFirebase supports multiple Firebase services, including:
 
 - ``EasyFirestore``
 - ``EasyAuth``
 
 Additionally, you can set some module-wide settings here, including:
 
 - ``logLevel-swift.type.property``
 - ``useCache``
 */
public struct EasyFirebase {
  
  // MARK: - Public Static Properties
  
  /// How detailed Firestore console out.
  public static var logLevel: LogLevel = .none
  
  /// Whether the cache should be used.
  public static var useCache: Bool = true
  
  // MARK: - Public Static Methods
  
  public static func configure() {
    FirebaseApp.configure()
  }
  
  public static func configure(options: FirebaseOptions) {
    FirebaseApp.configure(options: options)
  }
  
  // MARK: - Internal Static Methods
  
  internal static func log(error: Any?) {
    guard logLevel.rawValue >= 1 else { return }
    if let error = error as? Error {
      print("[EasyFirebase] \(error.localizedDescription)")
    } else if let error = error {
      print("[EasyFirebase]", error)
    }
  }
  
  internal static func log(_ item: Any?) {
    guard logLevel.rawValue >= 2 else { return }
    if let item = item {
      print("[EasyFirebase]", item)
    }
  }
  
  // MARK: - Public Enumerations
  
  /**
   The log level for Firebase-related output.
   */
  public enum LogLevel: Int {
    
    /// Don't log any output.
    case none = 0
    
    /// Only log errors.
    case errors = 1
    
    /// Log errors and transfer messages.
    case all = 2
  }
}
