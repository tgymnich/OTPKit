//
//  TOTPTests.swift
//  OTPKitTests
//
//  Created by Tim Gymnich on 7/22/19.
//

import XCTest
@testable import OTPKit

final class TOTPTests: XCTestCase {
    
    let secret = "12345678901234567890"
    lazy var secretData = { secret.data(using: .ascii)! }()
    
    let timeIntervals: [TimeInterval] = [1111111111, 1234567890, 2000000000]
    
    let expectedCodesSHA1: [TimeInterval: String] = [
        1111111111: "050471",
        1234567890: "005924",
        2000000000: "279037",
    ]
    
    let expectedCodesSHA256: [TimeInterval: String] = [
        1111111111: "584430",
        1234567890: "829826",
        2000000000: "428693",
    ]
    
    let expectedCodesSHA512: [TimeInterval: String] = [
        1111111111: "380122",
        1234567890: "671578",
        2000000000: "464532",
    ]
    
    let expectedCodesMD5: [TimeInterval: String] = [
        1111111111: "275841",
        1234567890: "280616",
        2000000000: "090484",
    ]
    
    func testSHA1() {
        let totp = TOTP(algorithm: .sha1, secret: secretData, digits: 6, period: 30)
        for interval in timeIntervals {
            let date = Date(timeIntervalSince1970: interval)
            let code = totp.code(for: date)
            XCTAssertEqual(code, expectedCodesSHA1[interval])
        }
    }
    
    func testSHA256() {
        let totp = TOTP(algorithm: .sha256, secret: secretData, digits: 6, period: 30)
        for interval in timeIntervals {
            let date = Date(timeIntervalSince1970: interval)
            let code = totp.code(for: date)
            XCTAssertEqual(code, expectedCodesSHA256[interval])
        }
    }
    
    func testSHA512() {
        let totp = TOTP(algorithm: .sha512, secret: secretData, digits: 6, period: 30)
        for interval in timeIntervals {
            let date = Date(timeIntervalSince1970: interval)
            let code = totp.code(for: date)
            XCTAssertEqual(code, expectedCodesSHA512[interval])
        }
    }
    
    func testMD5() {
        let totp = TOTP(algorithm: .md5, secret: secretData, digits: 6, period: 30)
        for interval in timeIntervals {
            let date = Date(timeIntervalSince1970: interval)
            let code = totp.code(for: date)
            XCTAssertEqual(code, expectedCodesMD5[interval])
        }
    }
    
    func testInitFromURLBasic() {
        let url = URL(string: "otpauth://totp/foo?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")!
        let totp = try? TOTP(from: url)
        
        XCTAssertNotNil(totp)
        XCTAssertEqual(totp?.algorithm, Algorithm.sha1)
        XCTAssertEqual(totp?.digits, 6)
        XCTAssertEqual(totp?.secret, "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ".base32DecodedData!)
    }
    
    func testInitFromURLAdvanced() {
        let url = URL(string: "otpauth://totp/www.example.com:foo?secret=ahkzlrgopti4qd2u5olxmj6dj6d3ag6zxddbutu6oaukrkuup2r7wklw&algorithm=SHA256&digits=7&period=15&image=http%3A%2F%2Fwww.example.com%2Fimage")!
        
        let totp = try? TOTP(from: url)
        
        XCTAssertNotNil(totp)
        XCTAssertEqual(totp?.algorithm, Algorithm.sha256)
        XCTAssertEqual(totp?.digits, 7)
        XCTAssertEqual(totp?.secret, "ahkzlrgopti4qd2u5olxmj6dj6d3ag6zxddbutu6oaukrkuup2r7wklw".base32DecodedData!)
        XCTAssertEqual(totp?.period, 15)
    }
    
    func testBrokenURL() {
        let url = URL(string: "otpauth://totp/foo?secret=")!
        let totp = try? TOTP(from: url)
        
        XCTAssertNil(totp)
    }
    
    func testWrongURLType() {
        let url = URL(string: "otpauth://hotp/foo?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&algorithm=SHA1&digits=6")!
        let totp = try? TOTP(from: url)
        
        XCTAssertNil(totp)
    }
    
    func testWrongURLScheme() {
        let url = URL(string: "http://totp/foo?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")!
        let totp = try? TOTP(from: url)
        
        XCTAssertNil(totp)
    }

    
    static var allTests = [
        ("testSHA1", testSHA1),
        ("testSHA256", testSHA256),
        ("testSHA512", testSHA512),
        ("testMD5", testMD5),
        ("testInitFromURLBasic", testInitFromURLBasic),
        ("testInitFromURLAdvanced", testInitFromURLAdvanced),
        ("testBrokenURL", testBrokenURL),
        ("testWrongURLType", testWrongURLType),
        ("testWrongURLScheme", testWrongURLScheme),
    ]
    
}
