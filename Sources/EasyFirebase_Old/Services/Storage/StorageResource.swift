//
//  StorageResource.swift
//  
//
//  Created by Ben Myers on 12/29/21.
//

import Foundation

@available(*, deprecated, renamed: "StorageResource.Path", message: "Use \"StorageResource.Path\" to reference a storage resource path type.")
public typealias ResourcePath = String

/**
 Provides information about an uploadable resource.
 
 Use this class with ``EasyStorage``!
 
 Resources can be uploaded to Firebase Storage. Resources are not themselves uploadable; they simply provide information about where a particular resource should go in Firebase Storage.
 */
public class StorageResource: Model, Identifiable {
  
  // MARK: - Public Type Aliases
  
  public typealias Path = String
  
  // MARK: - Public Properties
  
  /// The url of the resource.
  public var url: URL?
  /// The id of the resource.
  public var id: String = UUID().uuidString
  /// The resource's content type.
  public var kind: Kind = .png
  /// An optional folder to place the image in.
  public var folder: String?
  
  /// The reference path of the resource.
  public var path: Path {
    if let folder = folder {
      return "\(kind.category())s/\(folder)/\(id).\(kind.rawValue)"
    } else {
      return "\(kind.category())s/\(id).\(kind.rawValue)"
    }
  }
  
  // MARK: - Public Initalizers
  
  public init(id: String) {
    self.id = id
  }
  
  public init(id: String, folder: String?) {
    self.id = id
    self.folder = folder
  }
  
  // MARK: - Enumerations
  
  /**
   The kind of resource being dealt with.
   
   ⚠️ Currently, PNG images are only supported.
   */
  public enum Kind: String, Codable {
    
    case png
    
    public func category() -> String {
      switch self {
      case .png: return "image"
      }
    }
    
    public func contentType() -> String {
      return "\(category())/\(self.rawValue)"
    }
  }
}
