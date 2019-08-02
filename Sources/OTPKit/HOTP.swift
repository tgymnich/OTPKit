//
//  HOTP.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation
import Base32


public class HOTP: OTP {
    public static let otpType: OTPType = .hotp
    public let secret: Data
    public var counter: UInt64 = 0
    public var algorithm: Algorithm = .sha1
    public var digits: Int = 6
    public var urlQueryItems: [URLQueryItem] {
        let items: [URLQueryItem] = [
        URLQueryItem(name: "secret", value: secret.base32EncodedString.lowercased()),
        URLQueryItem(name: "algorithm", value: algorithm.string),
        URLQueryItem(name: "counter", value: String(counter)),
        URLQueryItem(name: "digits", value: String(digits)),
    ]
        return items
    }
    
    public init(algorithm: Algorithm = .sha1, secret: Data, digits: Int = 6, count: UInt64 = 0) {
        self.algorithm = algorithm
        self.secret = secret
        self.counter = count
        self.digits = digits
    }
    
    required public init?(from url: URL) {
        guard url.scheme == "otpauth", url.host == "hotp" else { return nil }
        
        guard let query = url.queryParameters else { return nil }
        
        if let algorithmString = query["algorithm"], let algorithm = Algorithm(from: algorithmString) {
            self.algorithm = algorithm
        }
        
        guard let secret = query["secret"]?.base32DecodedData, secret.count != 0 else { return nil }
        self.secret = secret
        
        if let digitsString = query["digits"], let digits = Int(digitsString), digits >= 6 {
            self.digits = digits
        }
        
        if let countString = query["counter"], let count = UInt64(countString) {
            self.counter = count
        }
    }
    
    public func code() -> String {
        defer { counter += 1 }
        return code(for: counter)
    }
    
}
