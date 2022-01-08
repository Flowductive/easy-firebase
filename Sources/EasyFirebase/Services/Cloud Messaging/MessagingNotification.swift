//
//  MessagingNotification.swift
//  
//
//  Created by Ben Myers on 12/29/21.
//

import Foundation

public typealias MessageCategory = String

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
@available(iOS 13.0, *)
public class MessagingNotification: Model, Equatable {
  
  // MARK: - Public Properties
  
  /// The date of the notification.
  public var date: Date = Date()
  
  /// The notification's category.
  ///
  /// This value can be used to limit user notifications through ``EasyUser.disabledNotificationCategories``.
  public var category: MessageCategory
  
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
  /// The attached image URL to the notification, if any.
  public var image: URL?
  /// Whether the notification has been read
  public var read: Bool = false
  
  // MARK: - Public Initalizers
  
  public init<T>(_ message: String, from user: T, in category: MessageCategory, attach image: URL? = nil, and additionalInfo: String? = nil) where T: EasyUser {
    let username = user.username
    self.user = user.id
    self.text = message
    self.category = category
    self.image = image
    self.pushBody = "\(username) \(self.text)"
    if let add = additionalInfo {
      self.pushBody += ": \(add)"
      self.text += ": \(add)"
    }
  }
  
  // MARK: - Public Static Methods
  
  public static func == (lhs: MessagingNotification, rhs: MessagingNotification) -> Bool {
    return lhs.text == rhs.text && (lhs.date.distance(to: rhs.date)) < TimeInterval(5 * 60)
  }
}
