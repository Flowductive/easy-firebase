//
//  File.swift
//  
//
//  Created by Ben Myers on 2/4/22.
//

import Foundation
import Firebase
import FirebaseAnalytics
import FirebaseAnalyticsSwift

public typealias AnalyticsEventKey = String
public typealias AnalyticsUserPropertyKey = String

/**
 `EasyAnalytics` is a service manager for various functions related to Firebase Analytics.
 
 Analytics is divided into primary categories: **Events** and **User Properties**.
 
 To log an event, you can use `EasyAnalytics`' static methods:
 
 ```
 EasyAnalytics.log("food_eaten", data: [
   "name": "Hot Dog",
   "isHot": true
 ])
 ```
 
 If you have a model that conforms to `AnalyticsLoggable`, you can log events using the model itself:
 
 ```
 let hotdog = Food(name: "Hot Dog", temperature: 81)
 EasyAnalytics.log("food_eaten", model: hotdog)
 ```
 
 Alternatively, you can call the logging method from the model itself:
 
 ```
 hotdog.log(key: "food_eaten")
 ```
 
 ⚠️ **Note:** All User Properties data collected by `EasyAnalytics` is *not* linked to a specific user. User IDs are not collected intentionally. If you wish to link analytics data to a specific user, call `Analytics.setUserId(_:)`.
 */
@available(iOS 13.0, *)
public struct EasyAnalytics {
  
  // MARK: - Public Static Properties
  
  /// The timeout duration.
  ///
  /// To prevent logging spam, the timeout duration is checked. If another Analytics-related action is performed within the timeout duration, it will not be logged to Firebase Analytics.
  public static var timeout: TimeInterval = TimeInterval(5.0)
  
  /// Whether to collect analytics data.
  public static var collectAnalytics: Bool = true { didSet {
    Analytics.setAnalyticsCollectionEnabled(collectAnalytics)
  }}
  
  // MARK: - Mixed Static Properties
  
  /// The last time data was logged to Analytics.
  public private(set) static var lastLog: Date?
  
  // MARK: - Public Static Methods
  
  /**
   Logs an analytics event.
   
   - parameter key: The key of the event
   - parameter model: The model to log.
   */
  public static func log<T>(_ key: AnalyticsEventKey, model: T) where T: AnalyticsLoggable {
    log(key, data: model.analyticsData)
  }
  
  /**
   Logs an analytics event.
   
   - parameter key: The key of the event
   - parameter data: Any data associated with the event
   */
  public static func log(_ key: AnalyticsEventKey, data: [String: Any]? = [:]) {
    if let lastLog = lastLog {
      guard lastLog.distance(to: Date()) > timeout else { return }
    }
    lastLog = Date()
    Analytics.logEvent(key, parameters: data)
  }
  
  // MARK: - Internal Static Methods
  
  internal static func set(_ key: AnalyticsUserPropertyKey, value: String?) {
    Analytics.setUserProperty(value, forName: key)
  }
}
