# OTPKit

A little swift package to generate HOTP and TOTP tokens and save them to the keychain.

# SwiftPM
```
// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "MyTool",
  dependencies: [
    .package(url: "https://github.com/TG908/OTPKit.git", .from: "0.0.2"),
  ],
  targets: [
    .target(name: "MyTool", dependencies: ["OTPKit"]),
  ]
)
```

# Usage
```
let url = URL(string: "otpauth://totp/foo?secret=wew3k6ztd7kuh5ucg4pejqi4swwrrneh72ad2sdovikfatzbc5huto2j&algorithm=SHA256&digits=6&period=30")!
let account = Account(from: url)

print(account?.otp.code()) // Prints the TOTP code for the current time.

```
