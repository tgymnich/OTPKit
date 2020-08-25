//
//  TOTP.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation


public final class TOTP: OTP {
    public static let typeString = "totp"

    public let secret: Data
    /// The period defines a period that a TOTP code will be valid for, in seconds.
    public let period: UInt64
    public let algorithm: Algorithm
    public let digits: Int

    public var counter : UInt64 { return UInt64(Date().timeIntervalSince1970) / period }
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
    
    public init(algorithm: Algorithm? = nil, secret: Data, digits: Int? = nil, period: UInt64? = nil) {
        self.secret = secret
        self.period = period ?? 30
        self.digits = digits ?? 6
        self.algorithm = algorithm ?? .sha1

        if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            RunLoop.main.add(timer, forMode: .default)
            timer.fire()
        }
    }
    
    public required convenience init(from url: URL) throws {
        guard url.scheme == "otpauth" else { throw URLDecodingError.invalidURLScheme(url.scheme) }
        guard url.host == "totp" else { throw URLDecodingError.invalidOTPType(url.host) }
        
        guard let query = url.queryParameters else { throw URLDecodingError.invalidURLQueryParamters }

        var algorithm: Algorithm?
        if let algorithmString = query["algorithm"] {
            guard let algo = Algorithm(from: algorithmString) else { throw URLDecodingError.invalidAlgorithm(algorithmString) }
            algorithm = algo
        }
        
        guard let secret = query["secret"]?.base32DecodedData, secret.count != 0 else { throw URLDecodingError.invalidSecret }

        var digits: Int?
        if let digitsString = query["digits"], let value = Int(digitsString), value >= 6 {
            digits = value
        }

        var period: UInt64?
        if let periodString = query["period"] {
            period = UInt64(periodString)
        }

        self.init(algorithm: algorithm, secret: secret, digits: digits, period: period)
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

    // MARK: Equatable

    public static func ==(lhs: TOTP, rhs: TOTP) -> Bool {
        return lhs.secret == rhs.secret && lhs.algorithm == rhs.algorithm && lhs.digits == rhs.digits && lhs.period == rhs.period
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(secret)
        hasher.combine(algorithm)
        hasher.combine(digits)
        hasher.combine(period)
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
