//
//  File.swift
//  
//
//  Created by Ben Myers on 9/3/22.
//

import Foundation

@available(iOS 13.0, *)
public protocol GeoQueryable: Document {
  
  // MARK: - Public Static Properties
  
  /// The precision to use with geohashing.
  static var geohashPrecision: GeoPrecision { get }

  // MARK: - Properties
  
  /// The document's location latitude.
  var latitude: Double { get set }
  /// The document's location longitude.
  var longitude: Double { get set }
  /// The address of the location of the document.
  var address: String? { get set }
}

#if canImport(CoreLocation)

import CoreLocation

@available(iOS 13.0, *)
public extension GeoQueryable {
  
  // MARK: - Properties
  
  /// The document's location's geohash.
  var geohash: String {
    let location: CLLocationCoordinate2D = .init(latitude: latitude, longitude: longitude)
    let hash = location.geohash(length: Self.geohashPrecision.rawValue)
    return hash
  }
}

#endif

public enum GeoPrecision: Int {
  /// ± 2500 km.
  case maxLoose = 1
  /// ± 630 km.
  case veryLoose = 2
  /// ± 20 km.
  case loose = 4
  /// ± 610 m.
  case normal = 6
  /// ± 19 m.
  case tight = 8
  /// ± 2.4 m.
  case veryTight = 9
  /// ± 60 cm.
  case maxTight = 10
  /// ± 7.4 cm.
  case exact = 11
}
