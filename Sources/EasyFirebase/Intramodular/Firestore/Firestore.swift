//
//  File.swift
//  
//
//  Created by Ben Myers on 9/6/22.
//

import Foundation

public struct Firestore {
  
  public enum Error: LocalizedError {
    
    /// No batch is present.
    case batchEmpty
    /// No key was found for the field.
    case noKey
    
    public var errorDescription: String? {
      switch self {
      case .batchEmpty: return "Nothing was changed in this document."
      case .noKey: return "An issue occured with your document's field keys."
      }
    }
    
    public var recoverySuggestion: String? {
      switch self {
      case .batchEmpty: return "Ensure you are setting fields using document.$field.set(_:) and supplying a new value."
      case .noKey: return "Keys can be manually added by passing in the @Field(\"keyName\") property wrapper."
      }
    }
    
    public var failureReason: String? {
      switch self {
      case .batchEmpty: return "The batch your document tried to write was nil or contained no changes."
      case .noKey: return "Your field does not have a key supplied."
      }
    }
  }
}
