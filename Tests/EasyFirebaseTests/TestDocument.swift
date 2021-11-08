//
//  TestDocument.swift
//  
//
//  Created by Ben Myers on 11/7/21.
//

import Foundation
import EasyFirebase

class TestDocument: Document {
  
  var id: String = UUID().uuidString
  var dateCreated: Date = Date()
  
  static func == (lhs: TestDocument, rhs: TestDocument) -> Bool {
    return lhs.id == rhs.id
  }
  
  var a: Int = 5
  var b: String = "Hello World"
  
  var users: [DocumentID] = []
  
  init() {}
  
  init(a: Int, b: String) {
    self.a = a
    self.b = b
  }
}
