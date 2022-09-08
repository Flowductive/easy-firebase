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
  
  /// The notification's key.
  ///
  /// Use this type to break notification handling into action cases.
  public var key: String?
  
  /// The user that this notification came from.
  public var user: EasyUser.ID?
  
  /// The notification's title. Displayed in bold.
  public var title: String
  /// The body of the push notification.
  public var body: String
  /// The attached image URL to the notification, if any.
  public var image: URL?
  /// Whether the notification has been read
  public var read: Bool = false
  
  // MARK: - Public Initalizers
  
  public init<T>(_ message: String,
                 from user: T,
                 in category: MessageCategory,
                 attach image: URL? = nil,
                 and additionalInfo: String? = nil,
                 with key: String? = nil
  ) where T: EasyUser {
    let username = user.username
    self.user = user.id
    self.title = ""
    self.category = category
    self.image = image
    self.body = "\(username) \(message)"
    self.key = key
    if let add = additionalInfo {
      self.body += ": \(add)"
    }
  }
  
  // MARK: - Public Static Methods
  
  public static func == (lhs: MessagingNotification, rhs: MessagingNotification) -> Bool {
    return lhs.title == rhs.title && lhs.body == rhs.body && (lhs.date.distance(to: rhs.date)) < TimeInterval(5 * 60)
  }
}
