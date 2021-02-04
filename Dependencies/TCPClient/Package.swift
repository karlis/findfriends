// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TCPClient",
  platforms: [
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "TCPClient",
      targets: ["TCPClient"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.1.2")
  ],
  targets: [
    .target(
      name: "TCPClient",
      dependencies: [
        .product(name: "Parsing", package: "swift-parsing")
      ]
    ),
  ]
)
