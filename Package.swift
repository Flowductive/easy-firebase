// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "EasyFirebase",
  platforms: [.iOS(.v11), .macOS(.v10_15), .tvOS(.v12), .watchOS(.v7)],
  products: [
    .library(
      name: "EasyFirebase",
      targets: ["EasyFirebase"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "8.0.0")),
  ],
  targets: [
    .target(
      name: "EasyFirebase",
      dependencies: [
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
        .product(name: "FirebaseFirestoreSwift-Beta", package: "firebase-ios-sdk"),
        .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
      ]
    ),
    /*
     .testTarget(
     name: "EasyFirebaseTests",
     dependencies: ["EasyFirebase"]),
     */
  ]
)
