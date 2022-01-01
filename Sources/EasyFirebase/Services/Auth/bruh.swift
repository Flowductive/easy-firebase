//
//  File.swift
//  
//
//  Created by Ben Myers on 1/1/22.
//

import Foundation

class FUser: EasyUser {
  
  var lastSignon: Date
  var displayName: String
  var username: String
  var email: String
  var appVersion: String
  var deviceToken: String?
  var notifications: [MessagingNotification]
  var disabledMessageCategories: [MessageCategory]
  var progress: Int
  var id: String
  var dateCreated: Date
  
}
