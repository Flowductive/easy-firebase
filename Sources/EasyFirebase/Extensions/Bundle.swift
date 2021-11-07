//
//  Bundle.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation

extension Bundle {
  
  // MARK: - Internal Static Properties
  
  /// The current build number
  internal static var versionString: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
  }
  
  /// The current version
  internal static var buildString: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
  }
}
