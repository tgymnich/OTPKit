//
//  OTP.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation
import CommonCrypto

public enum OTPType: String, Codable, CaseIterable {
    // Main purpose of this enum is to link a type string from a url to the Swift type implementing that OTP variant.
    
    // The type string as it would appear in the URL:
    // otpauth://TYPE/LABEL?PARAMETERS
    case hotp = "hotp"
    case totp = "totp"
    
    /// Type conforming to OTP that implements the OTPType
    var implementation: OTP.Type {
        switch self {
        case .hotp: return HOTP.self
        case .totp: return TOTP.self
        }
    }
    
    init?(for type: String) {
        // There can only be one or zero matching types because strings in a string backed enum must be unique.
        guard let matchingType = OTPType.allCases.filter({ $0.rawValue == type }).first else {
            return nil
        }
        self = matchingType
    }
}

public protocol OTP: Codable {
    /// Algorithm used to calculate the hash
    var algorithm: Algorithm { get }
    /// The secret is an arbitrary key value
    var secret: Data { get }
    /// The digits parameter determines how long of a one-time passcode to display to the user. The default is 6.
    var digits: Int { get }
    /// Used to derive to one time password
    var counter: UInt64 { get }
    
    /// Used to match the OTP type string in a URL to determine the matching swift type.
    static var otpType: OTPType { get }
    /// Used by Account to URL encode the HOTP instance.
    var urlQueryItems: [URLQueryItem] { get }
    
    /// Generate a one time password.
    mutating func code() -> String
    /// Generate a one time password for a specific counter value.
    func code(for count: UInt64) -> String
    
    /// Initalizes the OTP instance from a URL
    /// - Parameter url
    init?(from url: URL)
}

extension OTP {
    
    public func code(for count: UInt64) -> String {
        var hash = Data(count: algorithm.hashLength)
        var swappedCount = count.bigEndian
        let secretPointer = self.secret.withUnsafeBytes { ptr -> UnsafeRawPointer in
            return ptr.baseAddress!
        }
        
        // Perform HMAC
        hash.withUnsafeMutableBytes { ptr in
            CCHmac(algorithm.rawValue, secretPointer, secret.count, &swappedCount, MemoryLayout.size(ofValue: swappedCount), ptr.baseAddress!)
        }
        
        // Mask the hash
        let offset = Int(hash[algorithm.hashLength - 1]) & 0x0f
        
        let mask = hash.withUnsafeBytes { ptr -> UInt32 in
            let start = ptr.baseAddress!.advanced(by: offset).assumingMemoryBound(to: UInt32.self)
            return start.pointee.bigEndian & 0x7fffffff
        }
        
        var divisor: UInt32 = 1
        for _ in 0..<digits { divisor *= 10 }
        
        return String(format: String(format: "%%0%hhulu", digits), mask % divisor)
    }
}
