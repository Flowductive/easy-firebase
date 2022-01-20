//
//  IndexedDocument.swift
//  
//
//  Created by Ben Myers on 1/20/22.
//

import Foundation

/**
 A document that is indexed using a counter.
 
 Each new document that is created and pushed to Firestore has a unique index determined by an associated `Singleton` that is automatically created when the indexed document is created.
 */
public protocol IndexedDocument: Document {
  
  // MARK: - Public Properties
  
  /// The document's index.
  ///
  /// If the document has not yet been sent to Firestore, this value will be `nil`.
  var index: Int? { get set }
}
