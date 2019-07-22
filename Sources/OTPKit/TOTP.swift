//
//  TOTP.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation

struct TOTP: OTP {
    var secret: Data
    var period: UInt64 = 30
    var count : UInt64 { return UInt64(NSDate().timeIntervalSince1970) / period }
    var algorithm: Algorithm = .sha1
    var digits: Int = 6
    
    init(algorithm: Algorithm = .sha1, secret: Data, digits: Int = 6, period: UInt64 = 30) {
        self.secret = secret
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
    }
    
    init?(from url: URL) {
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
        
    }
    
    func code() -> String {
        return code(for: Date())
    }
    
    func code(for date: Date) -> String {
        let count = UInt64(date.timeIntervalSince1970) / period
        return code(for: count)
    }
    
}
