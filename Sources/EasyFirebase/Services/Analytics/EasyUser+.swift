//
//  File.swift
//  
//
//  Created by Ben Myers on 2/4/22.
//

import Foundation

@available(iOS 13.0, *)
public extension EasyUser {
  
  // MARK: - Public Methods
  
  /**
   The analytics User Properties for this user.
   
   When creating your own `EasyUser` subclass, you can override this property to specify custom User Properties to include in Analytics.
   
   User Properties are automatically updated when the user opens your application.
   
   - returns: A dictionary with data to send to Firebase Analytics when the user opens the application.
   */
  func analyticsProperties() -> [String: String] {
    return ["progress": "\(progress)", "app_version": appVersion]
  }
  
  /**
   Sends the `EasyUser`'s analytics properties to Firebase Analytics.
   */
  func updateAnalyticsUserProperties() {
    for key in analyticsProperties().keys {
      EasyAnalytics.set(String(key), value: analyticsProperties()[key])
    }
  }
}
