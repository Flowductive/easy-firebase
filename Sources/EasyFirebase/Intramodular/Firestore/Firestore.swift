//
//  File.swift
//  
//
//  Created by Ben Myers on 9/6/22.
//

import Foundation

public struct Firestore {
  
  public enum Error: LocalizedError {
    
    /// Unknown error.
    case unknown
    /// No batch is present.
    case batchEmpty
    /// No key was found for the field.
    case noKey
    /// An connection issue occured while communicating with Firestore.
    case connection
    /// No document matching the provided conditions could be found.
    case noDocument
    /// A document failed to be decoded.
    case decodingFailed
    /// A document failed to be encoded.
    case encodingFailed
    /// The query was empty.
    case emptyQuery
    
    public var errorDescription: String? {
      switch self {
      case .unknown: return "An unknown error occured."
      case .batchEmpty: return "Nothing was changed in this document."
      case .noKey: return "An issue occured with your document's field keys."
      case .connection: return "An connection issue occured."
      case .noDocument: return "No matching document could be found."
      case .decodingFailed: return "The matching document failed to be decoded."
      case .encodingFailed: return "The document failed to be encoded."
      case .emptyQuery: return "No documents matching the query could be found."
      }
    }
    
    public var recoverySuggestion: String? {
      switch self {
      case .batchEmpty: return "Ensure you are setting fields using document.$field.set(_:) and supplying a new value."
      case .noKey: return "Keys can be manually added by passing in the @Field(\"keyName\") property wrapper."
      case .connection: return "Check your wireless connection, and try again."
      case .noDocument: return "Check that your ID and location is correct before requesting your document."
      case .emptyQuery: return "Try expanding your search."
      default: return errorDescription
      }
    }
    
    public var failureReason: String? {
      switch self {
      case .batchEmpty: return "The batch your document tried to write was nil or contained no changes."
      case .noKey: return "Your field does not have a key supplied."
      case .connection: return "Firestore could not be reached."
      case .noDocument: return "No document matching the specified ID and location were found."
      case .decodingFailed: return "firebase-ios-sdk failed to decode your document."
      case .encodingFailed: return "firebase-ios-sdk failed to encode your document."
      default: return errorDescription
      }
    }
  }
}
