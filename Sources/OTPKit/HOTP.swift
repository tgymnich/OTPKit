//
//  HOTP.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation
import Base32

public final class HOTP: OTP {
    public static let typeString = "hotp"

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
    
    required public convenience init(from url: URL) throws {
        guard url.scheme == "otpauth" else { throw URLDecodingError.invalidURLScheme(url.scheme) }
        guard url.host == "hotp" else { throw URLDecodingError.invalidOTPType(url.host) }
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

    // MARK: Equatable

    public static func ==(lhs: HOTP, rhs: HOTP) -> Bool {
        return lhs.secret == rhs.secret && lhs.algorithm == rhs.algorithm && lhs.digits == rhs.digits && lhs.counter == rhs.counter
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(secret)
        hasher.combine(algorithm)
        hasher.combine(digits)
        hasher.combine(counter)
    }
    
}
