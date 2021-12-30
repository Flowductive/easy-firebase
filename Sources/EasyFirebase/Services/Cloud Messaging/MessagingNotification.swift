//
//  MessagingNotification.swift
//  
//
//  Created by Ben Myers on 12/29/21.
//

import Foundation

/**
 A notification, often triggered by an Apple Push Notification.
 
 These notifications are **solely** used for user-to-user interactions.
 
 # Examples
 
 - "*User* followed you"
 - "*User* liked your post"
 - and so on.
 
 To use these, check out ``EasyMessaging``.
 
 If you want to send a message with just a title and a body to a user, check out ``EasyMessaging.sendNotification(to:title:body:data:)`` instead.
 */
public class FNotification: Model, Equatable {
  
  // MARK: - Public Properties
  
  /// The date of the notification.
  public var date: Date = Date()
  /// The user that this notification came from.
  public var user: DocumentID?
  
  /// The notification's message.
  ///
  /// Do not include a placeholder for the user. The user's username will **always** be appended before the message.
  ///
  /// For instance, if you set `message` to `"followed you"`, the end user will receive the notification "*User* followed you".
  public var text: String
  /// The body of the push notification.
  public var pushBody: String
  /// The attached item to the notification, if any.
  public var attachment: Attachment?
  /// Whether the notification has been read
  public var read: Bool = false
  
  // MARK: - Public Initalizers
  
  public init(_ message: String, from user: EasyUser, attach attachment: Attachment? = nil, and additionalInfo: String? = nil) {
    let username = user.username
    self.kind = kind
    self.user = user.id
    self.text = message
    self.attachment = attachment
    self.pushBody = "\(username) \(self.text)"
    if let add = additionalInfo {
      self.pushBody += ": \(add)"
      self.text += ": \(add)"
    }
  }
  
  // MARK: - Static Methods
  
  static func == (lhs: FNotification, rhs: FNotification) -> Bool {
    return lhs.kind == rhs.kind && lhs.text == rhs.text && (lhs.date - rhs.date) < 5.minutes
  }
}
