//
//  AccountTests.swift
//  OTPKitTests
//
//  Created by Tim Gymnich on 7/22/19.
//

import XCTest
@testable import OTPKit

final class AccountTests: XCTestCase {
    
    func testBasicTOTPAccount() {
        let url = URL(string: "otpauth://totp/foo?secret=wew3k6ztd7kuh5ucg4pejqi4swwrrneh72ad2sdovikfatzbc5huto2j&algorithm=SHA256&digits=6&period=30")!
        
        let account = Account(from: url)

        XCTAssertNotNil(account)
        XCTAssertEqual(account?.label, "foo")
        XCTAssert(account?.otp is TOTP)
    }
    
    func testAdvancedTOTPAccount() {
        let url = URL(string: "otpauth://totp/www.example.com:foo?secret=avelj2f3hqxgbm5gi7rvrfskdvxnia72rt7kxwfa5l5yuisqfpjlezm5&algorithm=SHA256&digits=12&period=30&image=http%3A%2F%2Fwww.example.com%2Fimage")!
        
        let account = Account(from: url)
        
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.label, "foo")
        XCTAssertEqual(account?.issuer, "www.example.com")
        XCTAssertEqual(account?.imageURL, URL(string: "http://www.example.com/image")!)
        XCTAssert(account?.otp is TOTP)
    }
    
    func testBasicHOTPAccount() {
        let url = URL(string: "otpauth://hotp/foo?secret=qtezwnbabbgdb3kspqx3kjp5z6n7qtc5xcrkvk3p4scbyeuzwlfpbnhe&algorithm=SHA1&digits=6&counter=0")!
        
        let account = Account(from: url)
        
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.label, "foo")
        XCTAssert(account?.otp is HOTP)
    }
    
    func testAdvancedHOTPAccount() {
        let url = URL(string: "otpauth://hotp/www.example.com:foo?secret=vutgq34hz4fi4ljm2ycg6im6sd5pl6jmy4rihpvzaddliiqoi64gnquq&algorithm=SHA256&digits=12&counter=0&image=http%3A%2F%2Fwww.example.com%2Fimage")!
        
        let account = Account(from: url)
        
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.label, "foo")
        XCTAssertEqual(account?.issuer, "www.example.com")
        XCTAssertEqual(account?.imageURL, URL(string: "http://www.example.com/image")!)
        XCTAssert(account?.otp is HOTP)
    }
    
    static var allTests = [
        ("testBasicTOTPAccount", testBasicTOTPAccount),
        ("testAdvancedTOTPAccount", testAdvancedTOTPAccount),
        ("testBasicHOTPAccount", testBasicHOTPAccount),
        ("testAdvancedTOTPAccount", testAdvancedTOTPAccount),
    ]
    
}
