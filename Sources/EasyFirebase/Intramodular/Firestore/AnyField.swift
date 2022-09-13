//
//  AnyField.swift
//  
//
//  Created by Ben Myers on 9/11/22.
//

import Foundation

public class AnyField {
  
  var valueAsAny: Any { fatalError() }
  var documentAsAny: Any? { get { fatalError() } set { fatalError() }}
  
  internal final var key: String?
  
  public init(key: String?) {
    self.key = key
  }
  
  public func inject(document: Firestore.Document?, key: String) {
    self.documentAsAny = document
    self.key = key
  }
}
