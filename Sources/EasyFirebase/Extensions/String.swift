//
//  String.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation
import CryptoKit

extension String {
  
  // MARK: - Internal Static Methods
  
  internal static func nonce(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }
      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }
        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    return result
  }
  
  // MARK: - Internal Methods
  
  @available(iOS 13, *)
  internal func sha256() -> String {
    let str = self
    let inputData = Data(str.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      return String(format: "%02x", $0)
    }.joined()

    return hashString
  }
  
  internal func removeDomainFromEmail() -> String {
    var copy = String(self)
    if let range = copy.range(of: "@") {
      copy.removeSubrange(range.lowerBound ..< copy.endIndex)
    }
    return copy
  }
}
