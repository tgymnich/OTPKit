//
//  TOTP.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation

public class TOTP: OTP {
    public static let otpType: OTPType = .totp
    public let secret: Data
    /// The period defines a period that a TOTP code will be valid for, in seconds.
    public var period: UInt64 = 30
    public var counter : UInt64 { return UInt64(Date().timeIntervalSince1970) / period }
    public var algorithm: Algorithm = .sha1
    public var digits: Int = 6
    public var urlQueryItems: [URLQueryItem] {
        let items: [URLQueryItem] = [
            URLQueryItem(name: "secret", value: secret.base32EncodedString.lowercased()),
            URLQueryItem(name: "algorithm", value: algorithm.string),
            URLQueryItem(name: "period", value: String(period)),
            URLQueryItem(name: "digits", value: String(digits)),
        ]
        return items
    }
    
    @available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    private lazy var timer: Timer = {
            let timeForNextPeriod = Date(timeIntervalSince1970: TimeInterval((counter + 1) * period))
            let timer = Timer(fire: timeForNextPeriod, interval: TimeInterval(period), repeats: true) { [weak self] _ in
                guard let self = self else { return }
                let timeForNextPeriod = Date(timeIntervalSince1970: TimeInterval((self.counter + 1) * self.period))
                let timeRemaining = timeForNextPeriod.timeIntervalSince(Date())
                NotificationCenter.default.post(name: .didGenerateNewOTPCode, object: self, userInfo: [UserInfoKeys.code : self.code(), UserInfoKeys.timeRemaining: timeRemaining])
            }
            timer.tolerance = 1
            return timer
        }()
    
    public init(algorithm: Algorithm = .sha1, secret: Data, digits: Int = 6, period: UInt64 = 30) {
        self.secret = secret
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
        if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            RunLoop.main.add(timer, forMode: .default)
            timer.fire()
        }
    }
    
    public required init?(from url: URL) {
        guard url.scheme == "otpauth", url.host == "totp" else { return nil }
        
        guard let query = url.queryParameters else { return nil }
        
        if let algorithmString = query["algorithm"], let algorithm = Algorithm(from: algorithmString) {
            self.algorithm = algorithm
        }
        
        guard let secret = query["secret"]?.base32DecodedData, secret.count != 0 else { return nil }
        self.secret = secret
        
        if let digitsString = query["digits"], let digits = Int(digitsString), digits >= 6 {
            self.digits = digits
        }
        
        if let periodString = query["period"], let period = UInt64(periodString) {
            self.period = period
        }
        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            RunLoop.main.add(timer, forMode: .default)
            timer.fire()
        }
    }
    
    public func code() -> String {
        return code(for: Date())
    }
    
    public func code(for date: Date) -> String {
        let count = UInt64(date.timeIntervalSince1970) / period
        return code(for: count)
    }

    deinit {
        if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            timer.invalidate()
        }
    }
    
}

public extension TOTP {
    enum UserInfoKeys: Hashable {
        case code
        case timeRemaining
    }
}

public extension Notification.Name {
    static let didGenerateNewOTPCode = Notification.Name("didGenerateNewOTPCode")
}
