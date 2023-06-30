//
//  EasyUser.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseFirestore
import FirebaseFirestoreSwift

/**
 A fundamental user object.
 
 Extend your own user class from the `EasyUser` protocol to quickly create user objects that are compatabile with `EasyAuth`.
 
 All user objects come with `lastSignon`, `displayName`, `username`, `email`, `appVersion`, `deviceToken`, and `progress` support.
 
 ```swift
 class MyUser: EasyUser {
   
   var lastSignon: Date
   var displayName: String
   var username: String
   var email: String
   var appVersion: String
   var deviceToken: String?
   var id: String
   var dateCreated: Date
   var progress: Int
 
   var balance: Int = 0
      
   func addBalance() {
     balance += 1
   }
 }
 ```
 */
@available(iOS 13.0, *)
open class EasyUser: Document, IndexedDocument {
  
  // MARK: - Mixed Static Properties
  
  /// The change of the user's version.
  public internal(set) static var versionUpdate: VersionChange = .none
  
  // MARK: - Public Properties
  
  /// The user's notifications.
  ///
  /// Send notifications to a user using ``EasyMessaging``.
  public var notifications: [MessagingNotification] = []
  
  /// The user's disabled notification categories.
  ///
  /// Any messages with a ``MessageCategory`` that is in this array will not be send to the recipient.
  public var disabledMessageCategories: [MessageCategory] = []
  
  /// The user's app progression.
  ///
  /// This is a utility variable that you can use to keep track of tutorial progress, user progression, etc.
  ///
  /// There are a few preset values:
  ///
  /// - `-1` means the user has just been initalized.
  /// - `0` means the user data has been pushed to Firestore.
  /// - `1` and above are values you can customize.
  public var progress: Int = -1
  
  /// The user's profile image.
  ///
  /// If the user uses a third-party authentication service like Google, this image will automatically update.
  /// You can specify a default profile image by setting `EasyAuth.defaultProfileImageURLs`.
  public var profileImageURL: String?
  
  // MARK: - Mixed Properties
  
  /// The user's FCM device token.
  ///
  /// This value is automatically updated.
  public internal(set) var deviceToken: String?
  
  /// The user's last logged-in app version.
  ///
  /// This value is automatically updated when the user logs in.
  public internal(set) var appVersion: String
  
  /// The user's last signon date.
  ///
  /// This value is automatically updated each time the user logs into your application.
  public internal(set) var lastSignon: Date
  
  /// The user's email address.
  public internal(set) var email: String
  
  /// The user's active sessions.
  ///
  /// This property is a dictionary with the session's class name as a key and the ID of the session as the value.
  /// Users can join only one session per session type.
  @objc public internal(set) var sessions: [String: String] = [:]
  
  // MARK: - Objective-C Exposed Mixed Properties
  
  /// The user's username.
  ///
  /// This value is automatically generated based on the user's email upon account creation.
  @objc public internal(set) var username: String
  
  /// The user's display name.
  ///
  /// This value is automatically updated to a suggested display name when an account is created.
  @objc public internal(set) var displayName: String
  
  // MARK: - Inherited Properties
  
  public var index: Int?
  public var id: String
  public var dateCreated: Date
  
  // MARK: - Public Initalizers
  
  public required init() {
    id = "Guest"
    dateCreated = Date()
    deviceToken = "-"
    appVersion = Bundle.versionString
    lastSignon = Date()
    email = "guest@easy-firebase.com"
    username = "guest-user"
    displayName = "Guest"
    profileImageURL = EasyAuth.defaultProfileImageURLs.randomElement()!.absoluteString
  }
  
  public required init(from decoder: Decoder) throws {
    let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
    self.notifications = (try? values.decode([MessagingNotification].self, forKey: .notifications)) ?? []
    self.disabledMessageCategories = (try? values.decode([MessageCategory].self, forKey: .disabledMessageCategories)) ?? []
    self.progress = (try? values.decode(Int.self, forKey: .progress)) ?? -1
    self.profileImageURL = try? values.decode(String.self, forKey: .profileImageURL)
    self.deviceToken = try? values.decode(String.self, forKey: .deviceToken)
    self.lastSignon = (try? values.decode(Date.self, forKey: .lastSignon)) ?? Date()
    self.email = (try? values.decode(String.self, forKey: .email)) ?? "guest@easy-firebase.com"
    if let sessionsOptional = try? values.decode([String: String?].self, forKey: .sessions) {
      for (key, value) in sessionsOptional where value != nil {
        self.sessions.updateValue(value!, forKey: key)
      }
    }
    self.username = (try? values.decode(String.self, forKey: .username)) ?? "guest-user"
    self.displayName = (try? values.decode(String.self, forKey: .displayName)) ?? "Guest"
    self.id = (try? values.decode(String.self, forKey: .id)) ?? "Guest"
    self.dateCreated = (try? values.decode(Date.self, forKey: .dateCreated)) ?? Date()
    self.index = try? values.decode(Int.self, forKey: .index)
    self.appVersion = (try? values.decode(String.self, forKey: .appVersion)) ?? ""
    self.versionSupport(values)
  }
  
  // MARK: - Private Methods
  
  private func versionSupport(_ values: KeyedDecodingContainer<CodingKeys>) {
    
  }
  
  // MARK: - Public Enumerations
  
  public enum VersionChange: Int {
    /// No version change.
    case none = 0
    /// A patch version change.
    case patch = 1
    /// A minor version change.
    case minor = 2
    /// A major version change.
    case major = 3
    
    /**
     Gets a specific version change between two provided versions.
     
     - parameter before: The first version string (SemVer).
     - parameter after: The second version string (SemVer).
     */
    static func `get`(before: String, after: String) -> Self {
      let a = before.split(separator: ".")
      let b = after.split(separator: ".")
      guard a.count >= 3, b.count >= 3 else { return .none }
      let majorA = Int(a[0]) ?? 0
      let majorB = Int(b[0]) ?? 0
      let minorA = Int(a[1]) ?? 0
      let minorB = Int(b[1]) ?? 0
      var patchA = 0
      var patchB = 0
      if let _patchA = a[2].split(separator: "-").first, let _patchB = b[2].split(separator: "-").first {
        patchA = Int(_patchA) ?? 0
        patchB = Int(_patchB) ?? 0
      }
      if majorB - majorA > 0 {
        return .major
      } else if minorB - minorA > 0 {
        return .minor
      } else if patchB - patchA > 0 {
        return .patch
      } else {
        return .none
      }
    }
    
    /// Whether this version change represents any change.
    var isAnyChange: Bool {
      return self.rawValue > 0
    }
    
    /// Whether this version change represents a minor change, or better.
    var isAnySignificantChange: Bool {
      return self.rawValue >= 2
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case notifications, disabledMessageCategories, progress, profileImageURL, deviceToken, appVersion, lastSignon, email, sessions, username, displayName, index, id, dateCreated
  }
  
  open func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(notifications, forKey: .notifications)
    try container.encode(disabledMessageCategories, forKey: .disabledMessageCategories)
    try container.encode(progress, forKey: .progress)
    try container.encode(profileImageURL, forKey: .profileImageURL)
    try container.encode(deviceToken, forKey: .deviceToken)
    try container.encode(appVersion, forKey: .appVersion)
    try container.encode(lastSignon, forKey: .lastSignon)
    try container.encode(email, forKey: .email)
    try container.encode(sessions, forKey: .sessions)
    try container.encode(username, forKey: .username)
    try container.encode(displayName, forKey: .displayName)
    try container.encode(index, forKey: .index)
    try container.encode(id, forKey: .id)
    try container.encode(dateCreated, forKey: .dateCreated)
  }
}

@available(iOS 13.0, *)
public extension EasyUser {
  
  // MARK: - Public Static Properties
  
  /// The default random username suggestion generator.
  static var defaultSuggestionGenerator: (String) -> String {{ username in
    let randomInt = Int.random(in: 0...99)
    return "\(username)\(randomInt)"
  }}
  
  // MARK: - Public Static Methods
  
  /**
   Gets an `EasyUser` from a `FirebaseAuth` user.
   
   - parameter user: The `FirebaseAuth` user to transform.
   - returns: An `EasyUser` instance.
   */
  static func get(from user: User) -> Self? {
    let newUser = Self()
    newUser.id = user.uid
    newUser.dateCreated = Date()
    if let token = EasyMessaging.deviceToken {
      newUser.deviceToken = EasyMessaging.deviceToken
    }
    newUser.appVersion = Bundle.versionString
    newUser.lastSignon = Date()
    newUser.email = user.email ?? user.phoneNumber ?? ""
    newUser.username = newUser.email.removeDomainFromEmail()
    if newUser.username.count < 6 {
      newUser.username += String.random(length: 6 - newUser.username.count)
    }
    newUser.displayName = user.displayName ?? newUser.email.removeDomainFromEmail()
    newUser.profileImageURL = user.photoURL?.absoluteString ?? EasyAuth.defaultProfileImageURLs.randomElement()!.absoluteString
    newUser.updateAnalyticsUserProperties()
    newUser.refreshEmailVerifcationStatus()
    return newUser
  }
  
  // MARK: - Public Properties
  
  /// Returns whether the user is a guest (not signed in).
  var isGuest: Bool {
    return id == "Guest"
  }
  
  // MARK: - Public Methods
  
  /**
   Updates the current user's email address.
   
   - parameter newEmail: The new email to update with.
   - parameter type: The type of the user.
   - parameter completion: The completion handler.
   */
  func updateEmail<T>(to newEmail: String, ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { return }
    authUser?.updateEmail(to: newEmail) { [self] error in
      if error == nil {
        email = newEmail
        set(field: "email", using: \.email, ofUserType: T.self, completion: completion)
      }
      completion(error)
    }
  }
  
  /**
   Updates the user's username.
   
   This method is *safe*, meaning that it won't update the username if another user has an existing, matching username.
   
   If you wish to update the user's username regardless of whether it is unique, use ``unsafelyUpdateUsername(to:ofUserType:completion:)``.
   
   📌 **Important!** The completion block has two arguments. If the second `String?` value is `nil`, that means the username was successfully updated. Otherwise, if a non-`nil` value is passed, that means the username was *not* updated (and instead a suggested username is provided as the value).
   
   The `suggestionGenerator` parameter allows you to customize a random username to *suggest* based on the new username provided. For instance, if the username `myUsername` is unavailable, the generator can be customized to procure a new username `myUsername123`. If a random username is generated and is *still* taken, the generator will re-apply to the username previously generated (recursively).
   
   If no generator is provided, the default generator will append a random integer `0-99` to the end of the attempted username.
   
   ⚠️ **Note:** The suggested username returned in the completion block is not updated to be the user's new username when this method is called. Rather, it allows you to provide the user with the suggestion such that they can change it if they like.
   
   The completion handler has two arguments, an `Error?` and a `String?`. The first is the error that occurs while updating the username, if any. The second is the suggested username, created by the provided generator.
   
   # Example
   
   ```
   user.safelyUpdateUsername(to: "myNewUsername", ofUserType: MyUser.self,
                                    suggesting: { "\($0)\(Int.random(in: 0...999))" }
   ) { error, suggestion in
     if let error = error {
       // ...
     } else if let suggestion = suggestion {
       // Username taken, provide the user with this suggestion.
     } else {
       // Success! Username changed.
     }
   }
   ```
   
   - parameter newUsername: The username to update to.
   - parameter type: The type of the user.
   - parameter suggestionGenerator: A function that takes in a username and provides a new username (hopefully unique). See **Discussion** for more information.
   - parameter completion: The completion handler. See **Discussion** for more information.
   */
  func safelyUpdateUsername<T>(to newUsername: String,
                               ofType type: T.Type,
                               suggesting suggestionGenerator: @escaping (String) -> String = defaultSuggestionGenerator,
                               completion: @escaping (Error?, String?) -> Void) where T: EasyUser {
    EasyAuth.checkUsernameAvailable(newUsername, forUserType: T.self) { available in
      if available {
        self.unsafelyUpdateUsername(to: newUsername, ofUserType: T.self) { error in
          completion(error, nil)
          return
        }
      } else {
        self.getUniqueUsername(newUsername, using: suggestionGenerator) { suggestion in
          completion(nil, suggestion)
          return
        }
      }
    }
  }
  
  /**
   Updates the user's username.
   
   This method is *unsafe*, meaning that it will update the username regardless if there is another user with a matching username.
   
   If you wish to update the user's username if it is available and provide a suggested username upon failure, see ``safelyUpdateUsername(to:ofType:suggesting:completion:)``.
   
   - parameter newUsername: The username to update to.
   - parameter type: The type of the user.
   - parameter completion: The completion hander.
   */
  func unsafelyUpdateUsername<T>(to newUsername: String, ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    let oldUsername = username
    self.username = newUsername
    set(field: "username", using: \.username, ofUserType: T.self, completion: { error in
      if let error = error {
        completion(error)
        self.username = oldUsername
      } else {
        completion(nil)
      }
    })
  }
  
  /**
   Updates the current user's display name.
   
   - parameter newName: The new display name to update with.
   - parameter type: The type of the user.
   - parameter completion: The completion handler.
   */
  func updateDisplayName<T>(to newName: String, ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { return }
    if let authUser = authUser {
      let changeRequest = authUser.createProfileChangeRequest()
      changeRequest.displayName = newName
      changeRequest.commitChanges { [self] error in
        if error == nil {
          self.displayName = newName
          set(field: "displayName", using: \.displayName, ofUserType: T.self, completion: completion)
        } else {
          completion(error)
        }
      }
    }
  }
  
  /**
   Updates the current user's photo URL.
   
   - parameter url: The new photo URL to update with.
   - parameter type: The type of the user.
   - parameter completion: The completion handler.
   */
  func updatePhoto<T>(with url: URL, ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { completion(UserError.authDoesntMatch); return }
    if let authUser = authUser {
      let changeRequest = authUser.createProfileChangeRequest()
      changeRequest.photoURL = url
      changeRequest.commitChanges { error in
        if error == nil {
          self.profileImageURL = url.absoluteString
          Firestore.firestore().collection(String(describing: type)).document(self.id).updateData(["profileImageURL": url.absoluteString])
        }
        completion(error)
      }
    }
  }
  
  /**
   Updates the current user's photo, using data.
   
   - parameter data: The data of the new photo to update with.
   - parameter type: The type of the user.
   - parameter completion: The completion handler.
   */
  func updatePhoto<T>(with data: Data, ofUserType type: T.Type, progress: @escaping (Double) -> Void = { _ in }, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { completion(UserError.authDoesntMatch); return }
    EasyStorage.put(data, to: StorageResource(id: id, folder: "Profile Images"), progress: progress) { [self] url in
      guard let url = url else { completion(UserError.urlFailed); return }
      updatePhoto(with: url, ofUserType: type, completion: completion)
    }
  }
  
  /**
   Updates the current user's password.
   
   - parameter newPassword: The new password to update with.
   - parameter completion: The completion handler.
   */
  func updatePassword(to newPassword: String, completion: @escaping (Error?) -> Void = { _ in }) {
    guard assertAuthMatches() else { completion(nil); return }
    if let authUser = authUser {
      authUser.updatePassword(to: newPassword, completion: completion)
    }
  }
  
  /**
   Sends an email verification on the current user's behalf.
   
   - parameter completion: The completion handler.
   */
  func sendEmailVerification(completion: @escaping (Error?) -> Void = { _ in }) {
    if let authUser = authUser {
      authUser.sendEmailVerification(completion: completion)
    }
  }
  
  /**
   Refreshes the `emailVerified` static property of `EasyAuth`.
   */
  func refreshEmailVerifcationStatus(completion: @escaping () -> Void = {}) {
    guard assertAuthMatches() else { completion(); return }
    if let authUser = authUser {
      authUser.reload(completion: { _ in
        guard let user = Auth.auth().currentUser else { completion(); return }
        EasyAuth.emailVerified = user.isEmailVerified
        let id = user.providerData.first?.providerID ?? ""
        EasyAuth.accountProvider = EasyAuth.Provider(provider: id)
        completion()
      })
    } else {
      completion()
    }
  }
  
  /**
   Send a password reset request to the associated email.
   
   - parameter email: The email to send the password reset request to.
   - parameter completion: The completion handler.
   */
  func sendPasswordReset(toEmail email: String, completion: @escaping (Error?) -> Void = { _ in }) {
    Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
  }
  
  /**
   Deletes the current user.
   
   ⚠️ **Warning!** This method will *not* ask for confirmation. Implement that within your app!
   
   - parameter type: The type of the user
   - parameter completion: The completion handler
   */
  func delete<T>(ofUserType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: EasyUser {
    guard assertAuthMatches() else { return }
    if let authUser = authUser {
      EasyFirestore.Listening.stop(EasyAuth.listenerKey)
      authUser.delete { error in
        if let error = error {
          completion(error)
          return
        }
        EasyFirestore.Removal.remove(id: self.id, ofType: T.self, completion: completion)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          EasyAuth.signOut()
        }
      }
    }
  }
  
  // MARK: - Private Properties
  
  private var authUser: User? {
    Auth.auth().currentUser
  }
  
  // MARK: - Private Methods
  
  private func getUniqueUsername(_ base: String, using generator: @escaping (String) -> String, completion: @escaping (String) -> Void) {
    let new = generator(base)
    EasyAuth.checkUsernameAvailable(new, forUserType: Self.self) { available in
      if available {
        completion(new)
      } else {
        self.getUniqueUsername(new, using: generator, completion: completion)
      }
    }
  }
  
  private func assertAuthMatches() -> Bool {
    guard let uid = Auth.auth().currentUser?.uid else {
      return false
    }
    return uid == id
  }
}

@available(iOS 13.0, *)
public extension EasyUser {
  
  // MARK: - Public Methods
  
  /**
   Creates a new session.
   
   - parameter type: The type of session to create.
   - parameter completion: The completion handler.
   */
  func createSession<S>(ofType type: S.Type, completion: @escaping (S?, Error?) -> Void) where S: Session {
    guard self.sessions[String(describing: type)] == nil else {
      completion(nil, SessionError.alreadyInSession)
      return
    }
    let newSession: S = S(host: self.id)
    newSession.set { error in
      guard error == nil else {
        completion(nil, SessionError.communicationError)
        return
      }
      self.registerSession(newSession) { error in
        guard error == nil else {
          completion(newSession, SessionError.communicationError)
          return
        }
        completion(newSession, nil)
      }
    }
  }
  
  /**
   Joins an existing session.
   
   - parameter id: The ID of the session to join.
   - parameter type: The session's type.
   - parameter completion: The completion handler.
   */
  func joinSession<S>(id: S.ID, ofType type: S.Type, completion: @escaping (S?, Error?) -> Void) where S: Session {
    EasyFirestore.Retrieval.get(id: id, ofType: type, useCache: false) { session in
      guard let session = session else {
        completion(nil, SessionError.fetchFailed)
        return
      }
      self.registerSession(session) { error in
        guard error == nil else {
          completion(session, SessionError.communicationError)
          return
        }
        guard session.host != self.id else {
          completion(session, nil)
          return
        }
        Firestore.firestore().collection(String(describing: type)).document(id).updateData(["users": FieldValue.arrayUnion([self.id])]) { error in
          completion(session, nil)
        }
      }
    }
  }
  
  /**
   Checks all sessions and joins them if necessary.
   
   This method is useful if you wish to re-join a session on app open.
   
   - parameter completion: The completion handler.
   */
  func checkSession<S>(ofType type: S.Type, completion: @escaping (S?, Error?) -> Void) where S: Session {
    let key = String(describing: type)
    guard let id = sessions[key] else { return }
    joinSession(id: id, ofType: type) { session, error in
      if let error = error, let sessionError = error as? SessionError, sessionError == .fetchFailed {
        self.unregisterSession(ofType: type) { error in
          if let _ = error {
            completion(nil, SessionError.communicationError)
            return
          }
          completion(nil, nil)
        }
      } else {
        completion(session, error)
      }
    }
  }
  
  /**
   Leaves a session.
   
   If the user is the host of the session, or if the session has no other active users, then the session will be ended.
   
   If you are the host of a session and you wish to *leave* but not *end* the session, use ``transferHost(to:in:completion:)``.
   
   - parameter session: The sessino to leave.
   - parameter completion: The completion handler.
   */
  func leaveSession<S>(_ session: S, completion: @escaping (Error?) -> Void = { _ in }) where S: Session {
    guard session.host != self.id, session.allUsers.count > 0 else {
      endSession(session, completion: completion)
      return
    }
    guard self.sessions[String(describing: type(of: session))] != nil else {
      completion(SessionError.notInSession)
      return
    }
    self.sessions.removeValue(forKey: session.typeName)
    EasyFirestore.Listening.stop("_session_\(session.id)")
    Firestore.firestore().collection(String(describing: type(of: session))).document(session.id).updateData(["users": FieldValue.arrayRemove([self.id])]) { error in
      guard error == nil else {
        completion(SessionError.leaveError)
        return
      }
      self.unregisterSession(ofType: type(of: session)) { error in
        guard error == nil else {
          completion(SessionError.leaveError)
          return
        }
        completion(nil)
      }
    }
  }
  
  /**
   Transfers host status to another user.
   
   - parameter user: The user to make host.
   - parameter session: The session to perform this operation in.
   - parameter completion: The completion handler.
   */
  func transferHost<S>(to user: EasyUser.ID, in session: inout S, completion: @escaping (Error?) -> Void = { _ in }) where S: Session {
    guard session.host == self.id else {
      completion(SessionError.noHostPermission)
      return
    }
    guard user != self.id else {
      completion(SessionError.alreadyHost)
      return
    }
    guard session.users.contains(user) else {
      completion(SessionError.notInSession)
      return
    }
    session.users.removeAll { $0 == self.id }
    if !session.users.contains(user) { session.users.append(user) }
    session.set { error in
      guard error == nil else {
        completion(SessionError.communicationError)
        return
      }
      completion(nil)
    }
  }
  
  /**
   Ends a session.
   */
  func endSession<S>(_ session: S, completion: @escaping (Error?) -> Void = { _ in }) where S: Session {
    guard session.host == self.id || session.users.count <= 1 else {
      completion(SessionError.noHostPermission)
      return
    }
    EasyFirestore.Listening.stop("_session_\(session.id)")
    EasyFirestore.Removal.remove(session) { error in
      guard error == nil else {
        completion(SessionError.endError)
        return
      }
      self.unregisterSession(ofType: type(of: session)) { error in
        guard error == nil else {
          completion(SessionError.communicationError)
          return
        }
        completion(nil)
      }
    }
  }
  
  /**
   Leaves all sessions.
   
   If an error occurs while trying to exit a session, it will be tallied, and the remaining sessions will continue to be exited.
   If one or more error(s) occured during the method, the `completion(...)` handler will pass an error. The `errorDescription` of the passed error will
   descibe how many sessions failed to exited.
   
   - parameter completion: The completion handler.
   */
  func leaveAllSessions(completion: @escaping (Error?) -> Void = { _ in }) {
    let total: Int = self.sessions.count
    var okCount: Int = 0
    var errCount: Int = 0
    for sessionClass in self.sessions.keys {
      guard let id: String = self.sessions[sessionClass] else { continue }
      EasyFirestore.Listening.stop("_session_\(id)")
      Firestore.firestore().collection(sessionClass).document(id).updateData(["users": FieldValue.arrayRemove([self.id])]) { error in
        if let _ = error {
          errCount += 1
        } else {
          okCount += 1
        }
        if okCount + errCount >= total {
          completion(nil)
        } else {
          completion(SessionError.multiLeaveError(count: errCount))
        }
      }
    }
  }
  
  /**
   Listens to session updates.
   
   - parameter onUpdate: The update handler.
   - parameter onEnd: The session closed handler.
   */
  func listen<S>(to session: S, onUpdate: @escaping (S) -> Void, onEnd: @escaping () -> Void) where S: Session {
    EasyFirestore.Listening.listen(to: session.id, ofType: S.self, key: "_session_\(id)", onUpdate: { newSession in
      if let newSession = newSession {
        onUpdate(newSession)
      } else {
        self.leaveSession(session)
        onEnd()
      }
    })
  }
  
  // MARK: - Private Methods
  
  private func registerSession<S>(_ session: S, completion: @escaping (Error?) -> Void) where S: Session {
    self.sessions.updateValue(session.id, forKey: session.typeName)
    EasyFirestore.Updating.updateMapValue(key: session.typeName, value: session.id, to: \.sessions, in: self, completion: completion)
  }
  
  private func unregisterSession<S>(ofType type: S.Type, completion: @escaping (Error?) -> Void) where S: Session {
    guard let _ = self.sessions.removeValue(forKey: String(describing: type)) else {
      completion(nil)
      return
    }
    EasyFirestore.Updating.removeMapValue(key: String(describing: type), from: \.sessions, in: self, completion: completion)
  }
}

fileprivate extension String {
  static func random(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
  }
}

