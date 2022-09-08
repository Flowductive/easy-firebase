//
//  File.swift
//  
//
//  Created by Ben Myers on 9/8/22.
//

import Foundation

protocol KeyPathListable {
  var allKeyPaths: [String: PartialKeyPath<Self>] { get }
}

extension KeyPathListable {
  
  private subscript(checkedMirrorDescendant key: String) -> Any {
    return Mirror(reflecting: self).descendant(key)!
  }
  
  var allKeyPaths: [String: PartialKeyPath<Self>] {
    var membersTokeyPaths = [String: PartialKeyPath<Self>]()
    let mirror = Mirror(reflecting: self)
    for case (let key?, _) in mirror.children {
      membersTokeyPaths[key] = \Self.[checkedMirrorDescendant: key] as PartialKeyPath
    }
    return membersTokeyPaths
  }
  
}
