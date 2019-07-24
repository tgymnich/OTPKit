# OTPKit

A little swift package to generate HOTP and TOTP tokens and save them to the keychain.

# Usage
```
// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "MyTool",
  dependencies: [
    .package(url: "https://github.com/TG908/OTPKit.git", .from: "0.0.1"),
  ],
  targets: [
    .target(name: "MyTool", dependencies: ["OTPKit"]),
  ]
)
```
