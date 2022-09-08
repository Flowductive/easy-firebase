//
//  EasyLink.swift
//  
//
//  Created by Ben Myers on 9/2/22.
//

#if os(iOS)

import Firebase
import Foundation
import FirebaseCore
import FirebaseDynamicLinks

@available(iOS 13.0, *)
public struct EasyLink {
  
  // MARK: - Typealiases
  
  public typealias LongURL = URL
  public typealias ShortURL = URL
  public typealias DeepLinkURL = URL
  public typealias UniversialURL = URL
  
  // MARK: - Public Static Properties
  
  public static var urlPrefix: String?
  public static var appStoreID: String?
  public static var minimumAppVersion: String?
  public static var backupURL: URL?
  
  // MARK: - Public Properties
  
  public var social: SocialMeta? = nil
  
  /// A long dynamic link that is the long vresion of your Dynamic Link.
  public var longURL: LongURL? {
    guard let urlPrefix = Self.urlPrefix else { fatalError("Set static value EasyLink.urlPrefix before creating EasyLink instance.") }
    guard let deepLinkURL = deepLinkURL else { return nil }
    guard let builder = DynamicLinkComponents(link: deepLinkURL, domainURIPrefix: urlPrefix) else { return nil }
    builder.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.identifier)
    if let appStoreID = Self.appStoreID {
      builder.iOSParameters?.appStoreID = appStoreID
    }
    if let minimumAppVersion = Self.minimumAppVersion {
      builder.iOSParameters?.minimumAppVersion = minimumAppVersion
      builder.iOSParameters?.fallbackURL = Self.backupURL
    }
    if let social = social {
      builder.socialMetaTagParameters = social.builderParameters
    }
    if let backupURL = Self.backupURL {
      let params = DynamicLinkOtherPlatformParameters()
      params.fallbackUrl = backupURL
      builder.otherPlatformParameters = params
    }
    return builder.url
  }
  
  /// The deep link your app will open.
  public var deepLinkURL: DeepLinkURL? {
    var components = URLComponents()
    components.scheme = scheme.rawValue
    components.host = host // "flowductive.com"
    components.path = path // "/link"
    if !query.isEmpty {
      components.queryItems = []
      for (key, value) in query {
        components.queryItems?.append(URLQueryItem(name: key, value: value))
      }
    }
    return components.url
  }
  
  // MARK: - Mixed Properties
  
  public private(set) var scheme: Scheme
  public private(set) var host: String
  public private(set) var path: String
  public private(set) var query: [String: String] = [:]
  
  // MARK: - Public Initalizers
  
  public init(scheme: Scheme = .https, host: String, path: String = "", query: [String: String]) {
    self.scheme = scheme
    self.host = host
    self.path = path
    self.query = query
  }
  
  public init(scheme: Scheme = .https, host: String, path: String = "", query: (String, String)? = nil) {
    self.scheme = scheme
    self.host = host
    self.path = path
    if let query = query { self.query[query.0] = query.1 }
  }
  
  // MARK: - Public Static Methods
  
  public static func handle(_ url: UniversialURL?, completion: @escaping (EasyLink?) -> Void){
    guard let url = url else {
      completion(nil)
      return
    }
    DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamicLink: Firebase.DynamicLink?, error: Error?) in
      guard
        error == nil,
        let dynamicLink = dynamicLink,
        let url = dynamicLink.url,
        let scheme = Scheme.get(from: url.scheme ?? ""),
        let host = url.host,
        let query = url.queryDictionary
      else {
        completion(nil)
        return
      }
      let link = EasyLink(scheme: scheme, host: host, path: url.path, query: query)
      completion(link)
    }
  }
  
  // MARK: - Public Methods
  
  /**
   Shortens the URL.
   
   - parameter completion: The completion handler.
   */
  public func shorten(mode: ShortenMode = .short, completion: @escaping (URL?) -> Void) {
    guard let longURL = longURL else {
      completion(nil)
      return
    }
    let opt = DynamicLinkComponentsOptions()
    opt.pathLength = mode.convert
    DynamicLinkComponents.shortenURL(longURL, options: opt) { url, warnings, error in
      guard let url = url, error == nil else {
        completion(nil)
        return
      }
      completion(url)
    }
  }
  
  // MARK: - Enumerations
  
  public enum Scheme: String {
    case http = "http", https = "https"
    static func get(from str: String) -> Self? {
      switch str {
      case "http": return .http
      case "https": return .https
      default: return nil
      }
    }
  }
  
  public enum ShortenMode {
    case secure, short
    var convert: ShortDynamicLinkPathLength {
      switch self {
      case .secure: return .unguessable
      case .short: return .short
      }
    }
  }
  
  // MARK: - Nested Structs
  
  public struct SocialMeta {
    public var title: String
    public var desc: String
    public var imageURL: URL?
    
    public init(title: String, desc: String = "", imageURL: URL? = nil) {
      self.title = title
      self.desc = desc
      self.imageURL = imageURL
    }
    
    internal var builderParameters: DynamicLinkSocialMetaTagParameters {
      let p = DynamicLinkSocialMetaTagParameters()
      p.title = title
      p.descriptionText = desc
      p.imageURL = imageURL
      return p
    }
  }
}

fileprivate extension URL {
  var queryDictionary: [String: String]? {
    guard let query = self.query else { return nil}
    var queryStrings = [String: String]()
    for pair in query.components(separatedBy: "&") {
      let key = pair.components(separatedBy: "=")[0]
      let value = pair
        .components(separatedBy:"=")[1]
        .replacingOccurrences(of: "+", with: " ")
        .removingPercentEncoding ?? ""
      queryStrings[key] = value
    }
    return queryStrings
  }
}

#endif
