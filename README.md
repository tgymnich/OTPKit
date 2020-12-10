# OTPKit
![Swift](https://github.com/TG908/OTPKit/workflows/Swift/badge.svg)
[![codecov](https://codecov.io/gh/tgymnich/OTPKit/branch/master/graph/badge.svg?token=TALY1DNJWN)](https://codecov.io/gh/tgymnich/OTPKit)

A little swift package to generate HOTP and TOTP tokens and save them to the keychain. Featuring a combine publisher that publishes new tokens.

# SwiftPM
```swift
// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "MyTool",
  dependencies: [
    .package(url: "https://github.com/tgymnich/OTPKit.git", .from: "1.0.0"),
  ],
  targets: [
    .target(name: "MyTool", dependencies: ["OTPKit"]),
  ]
)
```

# Features
- Create TOTP and HOTP tokens 🔑
- `NotificationCenter` notifications for current tokens 📻
- Combine Publisher for newly current tokens 📡
- Save and load accounts from Keychain 🔒

# Usage

## Accounts

### Creating an Account from an URL
```swift
let url = URL(string: "otpauth://totp/foo?secret=wew3k6ztd7kuh5ucg4pejqi4swwrrneh72ad2sdovikfatzbc5huto2j&algorithm=SHA256&digits=6&period=30")!
let account = Account<TOTP>(from: url)

print(account?.otpGenerator.code()) // Prints the TOTP code for the current time.
```

### Saving and loading of accounts from the Keychain
```swift
let keychain = Keychain(service: "ch.gymni.test.otpauth")

let url = URL(string: "otpauth://totp/foo?secret=wew3k6ztd7kuh5ucg4pejqi4swwrrneh72ad2sdovikfatzbc5huto2j&algorithm=SHA256&digits=6&period=30")!
let totp = TOTP(algorithm: .sha256, secret: "wew3k6ztd7kuh5ucg4pejqi4swwrrneh72ad2sdovikfatzbc5huto2j".base32DecodedData! , digits: 6, period: 30)
let account = Account(label: "foo", otp: totp)
try account.save(to: keychain)

let accounts = try? Account.loadAll(from: keychain)
```

### Deleting all accounts from keychain
```swift
let keychain = Keychain(service: "ch.gymni.test.otpauth")
try! keychain.removeAll()
```


## Generating TOTP codes

### For a specific Date
```swift
let date = Date(timeIntervalSince1970: 1234)
let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: 30)
let code = totp.code(for: date)
```

### For the current period
```swift
let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: 30)
let code = totp.code()
```

### For a custom period
```swift
let period: UInt64 = 1234
let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: 30)
let code = totp.code(for: period)
```

### Using NotificationCenter
```swift
let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: 30)
NotificationCenter.default.addObserver(forName: .didGenerateNewOTPCode, object: totp, queue: .main) { notification in
   let code = notification.userInfo?[TOTP.UserInfoKeys.code] as? String
}
```

### Using a Combine Publisher
```swift
let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: TOTPPublisherTests.period)
let pub = TOTP.TOTPPublisher(totp: totp)
    .sink { code in
        print(code)
   }
```
