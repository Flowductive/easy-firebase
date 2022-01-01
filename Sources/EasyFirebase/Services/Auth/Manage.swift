//
//  Manage.swift
//  
//
//  Created by Ben Myers on 12/29/21.
//

import Foundation

public extension EasyAuth {
  
  /**
   Manage user settings, profile images, etc.
   
   ⚠️ **Note: ** These methods do not update the current user's data. For instance, if you use ``updateDisplayName(to:completion:)`` to update the user's display name, you will *also* need to set the `displayName` property of your user instance.
   
   Use ``Manage`` to quickly update a user's auth properties:
   
   - Use ``updateEmail(to:completion:)`` to update a user's email address.
   - Use ``updateDisplayName(to:completion:)`` to update a user's display name.
   - Use ``updatePhotoURL(to:completion:)`` to update a user's profile photo using a URL.
   - Use ``updatePhoto(with:completion:)`` to update a user's profile photo using `Data`.
   - Use ``sendEmailVerification(completion:)`` to send an email verification.
   - Use ``sendPasswordReset(toEmail:completion:)`` to send a password reset request.
   - Use ``deleteUser(completion:)`` to delete a user.
   */
  struct Manage {
    
    // MARK: - Public Static Methods
    
    /**
     Updates the current user's email address.
     
     - parameter newEmail: The new email to update with.
     - parameter completion: The completion handler.
     */
    public static func updateEmail(to newEmail: String, completion: @escaping (Error?) -> Void) {
      if let currentUser = auth.currentUser {
        currentUser.updateEmail(to: newEmail, completion: completion)
      }
    }
    
    /**
     Updates the current user's display name.
     
     - parameter newName: The new display name to update with.
     - parameter completion: The completion handler.
     */
    public static func updateDisplayName(to newName: String, completion: @escaping (Error?) -> Void) {
      if let currentUser = auth.currentUser {
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = newName
        changeRequest.commitChanges(completion: completion)
      }
    }
    
    /**
     Updates the current user's photo URL.
     
     - parameter newURL: The new photo URL to update with.
     - parameter completion: The completion handler.
     */
    public static func updatePhotoURL(to newURL: URL, completion: @escaping (Error?) -> Void) {
      if let currentUser = auth.currentUser {
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.photoURL = newURL
        changeRequest.commitChanges(completion: completion)
      }
    }
    
    /**
     Updates the current user's photo, using data.
     
     - parameter new: The data of the new photo to update with.
     - parameter completion: The completion handler.
     */
    public static func updatePhoto(with new: Data, completion: @escaping (Error?) -> Void) {
      if let currentUser = auth.currentUser {
        EasyStorage.put(new, to: StorageResource(id: currentUser.uid)) { url in
          guard let url = url else { return }
          updatePhotoURL(to: url, completion: completion)
        }
      }
    }
    
    /**
     Updates the current user's password.
     
     - parameter newPassword: The new password to update with.
     - parameter completion: The completion handler.
     */
    public static func updatePassword(to newPassword: String, completion: @escaping (Error?) -> Void) {
      if let currentUser = auth.currentUser {
        currentUser.updatePassword(to: newPassword, completion: completion)
      }
    }
    
    /**
     Sends an email verification on the current user's behalf.
     
     - parameter completion: The completion handler.
     */
    public static func sendEmailVerification(completion: @escaping (Error?) -> Void) {
      if let currentUser = auth.currentUser {
        currentUser.sendEmailVerification(completion: completion)
      }
    }
    
    /**
     Send a password reset request to the associated email.
     
     - parameter completion: The completion handler.
     */
    public static func sendPasswordReset(toEmail email: String, completion: @escaping (Error?) -> Void) {
      auth.sendPasswordReset(withEmail: email, completion: completion)
    }
    
    /**
     Deletes the current user.
     
     ⚠️ **Warning!** This method will *not* ask for confirmation. Implement that within your app!
     
     - parameter completion: The completion handler
     */
    public static func deleteUser(completion: @escaping (Error?) -> Void) {
      if let currentUser = auth.currentUser {
        currentUser.delete(completion: completion)
      }
    }
  }
}
