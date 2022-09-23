//
//  EasyLink.swift
//  
//
//  Created by Ben Myers on 9/2/22.
//

import Firebase
import Foundation

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
    guard let deepLinkURL = deepLinkURL, let urlPrefixURL = URL(string: urlPrefix) else { return nil }
    var builder = URLComponents()
    builder.scheme = "https"
    builder.host = urlPrefixURL.host
    builder.path = urlPrefixURL.path
    builder.queryItems = [
      .init(name: "link", value: deepLinkURL.absoluteString),
      .init(name: "ibi", value: Bundle.identifier),
    ]
    if let appStoreID = Self.appStoreID {
      builder.queryItems?.append(.init(name: "isi", value: appStoreID))
    }
    if let minimumAppVersion = Self.minimumAppVersion {
      builder.queryItems?.append(.init(name: "imv", value: minimumAppVersion))
    }
    if let backupURL = Self.backupURL {
      builder.queryItems?.append(.init(name: "ofl", value: backupURL.absoluteString))
    }
    if let social = social {
      builder.queryItems?.append(.init(name: "st", value: social.title))
      builder.queryItems?.append(.init(name: "sd", value: social.desc))
      if let imageURL = social.imageURL {
        builder.queryItems?.append(.init(name: "si", value: imageURL.absoluteString))
      }
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
  
  public init?(url: DeepLinkURL) {
    guard
      let _scheme = url.scheme,
      let scheme = Scheme(rawValue: _scheme),
      let host = url.host
    else {
      return nil
    }
    self.scheme = scheme
    self.host = host
    self.path = url.path
    self.query = url.queryDictionary ?? [:]
  }
  
  // MARK: - Public Static Methods
  
  public static func handle(_ url: UniversialURL?, completion: @escaping (EasyLink?) -> Void){
    guard
      let url = url,
      let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
      let dictionary = NSDictionary(contentsOfFile: path)
    else {
      completion(nil)
      return
    }
    let dict = [
      "requestedLink": url.absoluteString,
      "bundle_id": Bundle.identifier,
      "sdk_version": "9.0.0"
    ]
    guard
      let json: Data = try? JSONSerialization.data(withJSONObject: dict),
      let apiKey = dictionary["API_KEY"] as? String,
      let endpoint = URL(string: "https://firebasedynamiclinks.googleapis.com/v1/reopenAttribution?key=\(apiKey)")
    else {
      completion(nil)
      return
    }
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = json
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard
        let data = data,
        let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let deepLink = dict["deepLink"] as? String,
        let url = URL(string: deepLink)
      else {
        completion(nil)
        return
      }
      completion(EasyLink(url: url))
    }.resume()
  }
  
  // MARK: - Public Methods
  
  /**
   Shortens the URL.
   
   - parameter completion: The completion handler.
   */
  public func shorten(mode: ShortenMode = .short, completion: @escaping (URL?) -> Void) {
    guard
      let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
      let dictionary = NSDictionary(contentsOfFile: path),
      let longURL = longURL
    else {
      completion(nil)
      return
    }
    let dict: [String : Any] = [
      "longDynamicLink": longURL.absoluteString,
      "suffix": ["option": mode.string]
    ]
    guard
      let apiKey = dictionary["API_KEY"] as? String,
      let endpoint = URL(string: "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=\(apiKey)"),
      let json = try? JSONSerialization.data(withJSONObject: dict)
    else {
      completion(nil)
      return
    }
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = json
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard
        let data = data,
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let link = json["shortLink"] as? String
      else {
        completion(nil)
        return
      }
      completion(URL(string: link))
    }.resume()
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
    var string: String {
      switch self {
      case .secure: return "UNGUESSABLE"
      case .short: return "SHORT"
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
