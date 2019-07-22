//
//  OTP.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation
import CommonCrypto


protocol OTP: Codable {
    var algorithm: Algorithm { get }
    var secret: Data { get set }
    var digits: Int { get }
    var count: UInt64 { get }
    
    mutating func code() -> String
    func code(for count: UInt64) -> String
    
    init?(from url: URL)
}

extension OTP {
    
    func code(for count: UInt64) -> String {
        var hash = Data(count: algorithm.hashLength)
        var swappedCount = count.bigEndian
        let secretPointer = self.secret.withUnsafeBytes { ptr -> UnsafeRawPointer in
            return ptr.baseAddress!
        }
            
        hash.withUnsafeMutableBytes { ptr in
            CCHmac(algorithm.rawValue, secretPointer, secret.count, &swappedCount, MemoryLayout.size(ofValue: swappedCount), ptr.baseAddress!)
        }
                
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
