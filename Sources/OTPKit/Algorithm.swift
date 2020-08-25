//
//  Algorithm.swift
//
//  Created by Tim Gymnich on 7/18/19.
//

import Foundation
import CommonCrypto

public enum Algorithm: RawRepresentable, CaseIterable, Hashable, Codable {
    case md5
    case sha1
    case sha224
    case sha256
    case sha384
    case sha512
    
    public typealias RawValue = CCHmacAlgorithm
    
    public init?(rawValue: CCHmacAlgorithm) {
        switch rawValue {
        case CCHmacAlgorithm(kCCHmacAlgMD5): self = .md5
        case CCHmacAlgorithm(kCCHmacAlgSHA1): self = .sha1
        case CCHmacAlgorithm(kCCHmacAlgSHA224): self = .sha224
        case CCHmacAlgorithm(kCCHmacAlgSHA256): self = .sha256
        case CCHmacAlgorithm(kCCHmacAlgSHA384): self = .sha384
        case CCHmacAlgorithm(kCCHmacAlgSHA512): self = .sha512
        default: return nil
        }
    }
    
    init?(from string: String) {
        switch string.lowercased() {
        case "md5": self = .md5
        case "sha1": self = .sha1
        case "sha224": self = .sha224
        case "sha256": self = .sha256
        case "sha384": self = .sha384
        case "sha512": self = .sha512
        default: return nil
        }
    }
    
    public var rawValue: CCHmacAlgorithm {
        switch self {
        case .md5: return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .sha1: return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .sha224: return CCHmacAlgorithm(kCCHmacAlgSHA224)
        case .sha256: return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .sha384: return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .sha512: return CCHmacAlgorithm(kCCHmacAlgSHA512)
        }
    }
    
    
    /// Length of the digest
    public var hashLength: Int {
        switch self {
        case .md5: return Int(CC_MD5_DIGEST_LENGTH)
        case .sha1: return Int(CC_SHA1_DIGEST_LENGTH)
        case .sha224: return Int(CC_SHA224_DIGEST_LENGTH)
        case .sha256: return Int(CC_SHA256_DIGEST_LENGTH)
        case .sha384: return Int(CC_SHA384_DIGEST_LENGTH)
        case .sha512: return Int(CC_SHA512_DIGEST_LENGTH)
        }
    }
    
    public var string: String {
        switch self {
        case .md5: return "md5"
        case .sha1: return "sha1"
        case .sha224: return "sha224"
        case .sha256: return "sha256"
        case .sha384: return "sha384"
        case .sha512: return "sha512"
        }
    }
    
}
