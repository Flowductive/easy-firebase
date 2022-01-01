//
//  EasyMessaging.swift
//  
//
//  Created by Ben Myers on 12/29/21.
//

import Foundation
import Firebase
import FirebaseMessaging

/**
 `EasyMessaging` is a service manager for various functions related to Firebase In-App Messaging and Cloud Messaging.
 
 Use `EasyMessaging` to send push notifications with ease:
 
 - Use ``subscribe(to:)`` to subscribe the user to In-App Messaging notifications of a particular topic.
 - Use ``send(_:to:perm:)`` to send a notification from a user to a different user.
 - Use ``sendNotification(to:title:body:data:)`` to send a customized message to a user.
 */
public struct EasyMessaging {
  
  // MARK: - Public Static Properties
  
  /// The application's Server Key.
  ///
  /// ⚠️ **Note:** Obtain this key in your [https://console.firebase.google.com](Firebase Console), and be sure to set it before using `EasyMessaging`!
  public static var serverKey: String?
  
  // MARK: - Public Static Methods
  
  /**
   Subscribes the user to a particular topic.
   
   - parameter topic: The topic to subscribe to.
   */
  public static func subscribe(to topic: String) {
    Messaging.messaging().subscribe(toTopic: topic)
  }
  
  /**
   Unsubscribes the user from a particular topic.
   
   - parameter topic: The topic to unsubscribe from.
   */
  public static func unsubscribe(from topic: String) {
    Messaging.messaging().unsubscribe(fromTopic: topic)
  }
  
  /**
   Sends a push notification to a certain user.
   
   This is a Flowductive wrapper for sending notifications to a particular user using Flowductive-provided `FNotification` and `FUser` objects.
   
   ⚠️ **Important:** This does not add a `FNotification` object to the user's notification list.
   
   # Device Token
   
   The `FUser` recipient must have a `deviceToken` property available in their user object. Such a token is automatically generated upon login, and is uploaded to Firestore. If a token is present (client version >= 0.3), a notification will be sent.
   
   - parameter notification: The notification to send to the user.
   - parameter user: The user to send the notification to.
   */
  public static func send<T>(_ notification: MessagingNotification, to user: T) where T: EasyUser {
    guard !user.disabledMessageCategories.contains(notification.category) else {
      EasyFirebase.log("Message not sent because the user has the message category '`\(notification.category)' disabled.")
      return
    }
    sendNotification(to: user, title: "", body: notification.pushBody, data: ["count": user.notifications.filter({ !$0.read }).count])
  }
  
  /**
   Sends a push notification to a certain user.
   
   - parameter user: The user to send to.
   - parameter title: The title of the notification.
   - parameter body: The body of the notification.
   */
  public static func sendNotification<T>(to user: T, title: String, body: String, data: [AnyHashable: Any] = [:]) where T: EasyUser {
    guard let serverKey = serverKey else {
      fatalError("❌ Your Messaging Server Key hasn't been set yet! Ensure that EasyMessaging.serverKey is set before using EasyMessaging.")
    }
    guard let token = user.deviceToken else {
      EasyFirebase.log(error: "Your user does not have a device token.")
      return
    }
    let urlString = "https://fcm.googleapis.com/fcm/send"
    let url = NSURL(string: urlString)!
    let paramString: [String: Any] = ["to": token,
                                      "notification": ["title": title, "body": body],
                                      "data": data
    ]
    let request = NSMutableURLRequest(url: url as URL)
    request.httpMethod = "POST"
    request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, _ in
      do {
        if let jsonData = data {
          if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
            EasyFirebase.log("Received data:\n\(jsonDataDict))")
          }
        }
      } catch let err as NSError {
        EasyFirebase.log(error: err.localizedDescription)
        return
      }
    }
    task.resume()
    EasyFirebase.log("Message sending! Title: '\(title)'")
  }
}
