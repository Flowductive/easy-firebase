//
//  Singleton.swift
//  
//
//  Created by Ben Myers on 10/29/21.
//

import Foundation

public typealias SingletonName = DocumentID

public protocol Singleton: Document {
  
  /// The name of the singleton.
  var id: SingletonName { get set }
}
