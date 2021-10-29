// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "EasyFirebase",
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
      dependencies: []),
    .testTarget(
      name: "EasyFirebaseTests",
      dependencies: ["EasyFirebase"]),
  ]
)
