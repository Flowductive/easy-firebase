//
//  File.swift
//  
//
//  Created by Ben Myers on 2/4/22.
//

import Foundation

/**
 A protocol that establishes that the model can be logged into Firebase Analytics.
 
 Some models, upon creation, can be logged to Analytics to monitor properties of user engagement. For instace, if we have a `Food` model like so:
 
 ```
 struct Food: Model, AnalyticsLoggable {
   var name: String
   var temperature: Int
   var analyticsData: [String : Any] {[
     "name": name,
     "isHot": temperature > 65
   ]}
 }
 ```
 
 Then calling `.log(key:)` on an instance of `Food` will log an Analytics Event to firestore with the data as provided above.
 */
public protocol AnalyticsLoggable {
  
  /// Data provided for analytics.
  var analyticsData: [String: Any] { get }
}

public extension AnalyticsLoggable {
  
  // MARK: - Public Methods
  
  /**
   Logs an analytics event using the model.
   
   - parameter key: The key of the event
   */
  func log(key: AnalyticsEventKey) {
    EasyAnalytics.log(key, model: self)
  }
}
