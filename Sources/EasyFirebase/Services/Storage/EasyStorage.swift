//
//  EasyStorage.swift
//  
//
//  Created by Ben Myers on 12/29/21.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseStorageSwift

/**
 `EasyStorage` is a service manager for various functions related to Firebase Storage.
 
 To use ``EasyStorage``, check out the following methods:
 
 - Use ``put(_:to:progress:completion:)`` to store data in Firebase Storage.
 - Use ``delete(_:completion:)`` to remove data in Firebase Storage.
 */
public struct EasyStorage {
  
  // MARK: - Private Static Properties
  
  private static let storage = Storage.storage()
  private static let storageRef = storage.reference()
  
  // MARK: - Mixed Static Properties
  
  /// The active storage upload task.
  public private(set) static var task: StorageUploadTask?
  
  // MARK: - Public Static Methods
  
  /**
   Stores a resource in Firebase Storage.
   
   ✅ This is a safe method. Existing resources with a matching ID will be removed from Firebase Storage before the resource is added.
   
   - parameter data: The data to store.
   - parameter resource: Information about the resource in Firebase Storage.
   - parameter progress: A handler for completion progress updates.
   - parameter completion: An optional completion handler.
   */
  public static func put(_ data: Data, to resource: StorageResource, progress: @escaping (Double) -> Void = { _ in }, completion: @escaping (URL?) -> Void) {
    delete(resource, completion: { _ in
      unsafePut(data, to: resource, progress: progress, completion: completion)
    })
  }
  
  /**
   Removes a resource from Firebase Storage.
   
   - parameter resource: Information about the location of the resource in Firebase Storage.
   - parameter completino: The completion handler.
   */
  public static func delete(_ resource: StorageResource, completion: @escaping (Bool) -> Void) {
    let ref = storageRef.child(resource.path)
    ref.delete(completion: { err in
      if err != nil {
        print("[!] No resource was deleted because no resource exists.")
        completion(false)
      } else {
        completion(true)
      }
    })
  }
  
  /**
   Pauses an upload task, if any.
   */
  public static func pause() {
    task?.pause()
  }
  
  /**
   Resumes an upload task, if any.
   */
  public static func resume() {
    task?.resume()
  }
  
  /**
   Cancels an upload task, if any.
   */
  public static func cancel() {
    task?.cancel()
  }
  
  // MARK: - Private Methods
  
  private static func unsafePut(_ data: Data, to resource: StorageResource, progress: @escaping (Double) -> Void, completion: @escaping (URL?) -> Void = { _ in }) {
    let ref = storageRef.child(resource.path)
    let metadata = StorageMetadata()
    metadata.contentType = resource.kind.contentType()
    task = ref.putData(data, metadata: metadata) { (_, _) in
      task?.removeAllObservers()
      task = nil
      ref.downloadURL { (url, _) in
        resource.url = url
        completion(url)
      }
    }
    _ = task?.observe(.progress, handler: { snapshot in
      progress(snapshot.progress?.fractionCompleted ?? 0.0)
    })
  }
}
