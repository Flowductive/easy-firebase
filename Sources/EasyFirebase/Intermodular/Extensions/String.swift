//
//  File.swift
//  
//
//  Created by Ben Myers on 10/23/22.
//

#if canImport(SwiftUI)
import SwiftUI

public extension String {
  
  func underscorePrefixRemoved() -> String {
    if self.first == "_" {
      return String(self.dropFirst())
    }
    return self
  }
  
  /**
   Copies the string to the user's clipboard.
   */
  func copyToClipboard() {
#if os(iOS)
    UIPasteboard.general.string = self
#else
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(self, forType: .string)
#endif
  }
}
#endif
