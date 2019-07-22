//
//  HOTPTests.swift
//  OTPKitTests
//
//  Created by Tim Gymnich on 7/22/19.
//

import XCTest
@testable import OTPKit

final class HOTPTests: XCTestCase {
    
    let secret = "12345678901234567890"
    lazy var secretData = { secret.data(using: .ascii)! }()
    
    let expectedCodesSHA1 = ["755224", "287082", "359152", "969429", "338314", "254676", "287922", "162583", "399871", "520489", "403154",]
    
    func testSHA1() {
        let hotp = HOTP(algorithm: .sha1, secret: secretData, digits: 6, count: 0)
        for count in 0..<expectedCodesSHA1.count {
            let code = hotp.code(for: UInt64(count))
            XCTAssertEqual(code, expectedCodesSHA1[count])
        }
    }
    
    func testInitFromURLBasic() {
        let url = URL(string: "otpauth://hotp/foo?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&algorithm=SHA1&digits=6")!
        
        let hotp = HOTP(from: url)
        
        XCTAssertNotNil(hotp)
        XCTAssertEqual(hotp?.algorithm, Algorithm.sha1)
        XCTAssertEqual(hotp?.digits, 6)
        XCTAssertEqual(hotp?.secret, "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ".base32DecodedData!)
    }
    
    func testInitFromURLAdvanced() {
        let url = URL(string: "otpauth://hotp/www.example.com:foo?secret=rk7xql2piogveotejq2ulv7d2aicbpzlh33xeaqnkqjck4iyz2cm6xzg&algorithm=SHA256&digits=7&period=30&counter=34&image=http%3A%2F%2Fwww.example.com%2Fimage")!
        
        let hotp = HOTP(from: url)
        
        XCTAssertNotNil(hotp)
        XCTAssertEqual(hotp?.algorithm, Algorithm.sha256)
        XCTAssertEqual(hotp?.digits, 7)
        XCTAssertEqual(hotp?.count, 34)
        XCTAssertEqual(hotp?.secret, "rk7xql2piogveotejq2ulv7d2aicbpzlh33xeaqnkqjck4iyz2cm6xzg".base32DecodedData!)
    }
    
    func testBrokenURL() {
        let url = URL(string: "otpauth://hotp/foo?secret=&algorithm=SHA1&digits=6")!
        let hotp = HOTP(from: url)
        
        XCTAssertNil(hotp)
    }
    
    func testWrongURLType() {
        let url = URL(string: "otpauth://totp/foo?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")!
        let hotp = HOTP(from: url)
    
        XCTAssertNil(hotp)
    }
    
    func testWrongURLScheme() {
        let url = URL(string: "http://hotp/foo?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&algorithm=SHA1&digits=6")!
        let hotp = HOTP(from: url)
        
        XCTAssertNil(hotp)
    }
    
    static var allTests = [
        ("testSHA1", testSHA1),
        ("testInitFromURLBasic", testInitFromURLBasic),
        ("testInitFromURLAdvanced", testInitFromURLAdvanced),
        ("testBrokenURL", testBrokenURL),
        ("testWrongURLType", testWrongURLType),
        ("testWrongURLScheme", testWrongURLScheme),
    ]
    
}
