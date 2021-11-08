//
//  Bundle.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation

extension Bundle {
  
  // MARK: - Internal Static Properties
  
  internal static var versionString: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
  }
  
  internal static var buildString: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
  }
}
