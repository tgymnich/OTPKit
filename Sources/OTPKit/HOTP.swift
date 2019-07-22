//
//  HOTP.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation
import Base32


struct HOTP: OTP {
    var secret: Data
    var count: UInt64 = 0
    var algorithm: Algorithm = .sha1
    var digits: Int = 6
    
    init(algorithm: Algorithm = .sha1, secret: Data, digits: Int = 6, count: UInt64 = 0) {
        self.algorithm = algorithm
        self.secret = secret
        self.count = count
        self.digits = digits
    }
    
    init?(from url: URL) {
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
            self.count = count
        }
    }
    
    mutating func code() -> String {
        defer { count += 1 }
        return code(for: count)
    }
    
    
    
}
