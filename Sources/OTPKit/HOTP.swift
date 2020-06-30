//
//  HOTP.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation
import Base32


public final class HOTP: OTP {
    public static let otpType: OTPType = .hotp

    public let secret: Data
    public let algorithm: Algorithm
    public let digits: Int

    public var counter: UInt64 = 0
    public var urlQueryItems: [URLQueryItem] {
        let items: [URLQueryItem] = [
        URLQueryItem(name: "secret", value: secret.base32EncodedString.lowercased()),
        URLQueryItem(name: "algorithm", value: algorithm.string),
        URLQueryItem(name: "counter", value: String(counter)),
        URLQueryItem(name: "digits", value: String(digits)),
    ]
        return items
    }
    
    public init(algorithm: Algorithm? = nil, secret: Data, digits: Int? = nil, count: UInt64? = nil) {
        self.algorithm = algorithm ?? .sha1
        self.secret = secret
        self.counter = count ?? 0
        self.digits = digits ?? 6
    }
    
    required public convenience init?(from url: URL) {
        guard url.scheme == "otpauth", url.host == "hotp" else { return nil }
        
        guard let query = url.queryParameters else { return nil }

        var algorithm: Algorithm?
        if let algorithmString = query["algorithm"] {
            algorithm = Algorithm(from: algorithmString)
        }
        
        guard let secret = query["secret"]?.base32DecodedData, secret.count != 0 else { return nil }

        var digits: Int?
        if let digitsString = query["digits"], let value = Int(digitsString), value >= 6 {
            digits = value
        }

        var count: UInt64?
        if let countString = query["counter"] {
            count = UInt64(countString) ?? 0
        }

        self.init(algorithm: algorithm, secret: secret, digits: digits, count: count)
    }
    
    public func code() -> String {
        defer { counter += 1 }
        return code(for: counter)
    }
    
}
