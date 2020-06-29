//
//  AccountTests.swift
//  OTPKitTests
//
//  Created by Tim Gymnich on 7/22/19.
//

import XCTest
import KeychainAccess
@testable import OTPKit

final class AccountTests: XCTestCase {
    
    func testBasicTOTPAccount() {
        let url = URL(string: "otpauth://totp/foo?secret=wew3k6ztd7kuh5ucg4pejqi4swwrrneh72ad2sdovikfatzbc5huto2j&algorithm=SHA256&digits=6&period=30")!
        
        let account = Account(from: url)
        
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.label, "foo")
        XCTAssert(account?.otpGenerator is TOTP)
    }
    
    func testAdvancedTOTPAccount() {
        let url = URL(string: "otpauth://totp/www.example.com:foo?secret=avelj2f3hqxgbm5gi7rvrfskdvxnia72rt7kxwfa5l5yuisqfpjlezm5&algorithm=SHA256&digits=7&period=30&image=http%3A%2F%2Fwww.example.com%2Fimage")!
        
        let account = Account(from: url)
        
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.label, "foo")
        XCTAssertEqual(account?.issuer, "www.example.com")
        XCTAssertEqual(account?.imageURL, URL(string: "http://www.example.com/image")!)
        XCTAssert(account?.otpGenerator is TOTP)
    }
    
    func testBasicHOTPAccount() {
        let url = URL(string: "otpauth://hotp/foo?secret=qtezwnbabbgdb3kspqx3kjp5z6n7qtc5xcrkvk3p4scbyeuzwlfpbnhe&algorithm=SHA1&digits=6&counter=0")!
        
        let account = Account(from: url)
        
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.label, "foo")
        XCTAssert(account?.otpGenerator is HOTP)
    }
    
    func testAdvancedHOTPAccount() {
        let url = URL(string: "otpauth://hotp/www.example.com:foo?secret=vutgq34hz4fi4ljm2ycg6im6sd5pl6jmy4rihpvzaddliiqoi64gnquq&algorithm=SHA256&digits=7&counter=0&image=http%3A%2F%2Fwww.example.com%2Fimage")!
        
        let account = Account(from: url)
        
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.label, "foo")
        XCTAssertEqual(account?.issuer, "www.example.com")
        XCTAssertEqual(account?.imageURL, URL(string: "http://www.example.com/image")!)
        XCTAssert(account?.otpGenerator is HOTP)
    }
    
    func testURLGenerationBasic1() {
        let totp = TOTP(algorithm: .sha1, secret: "ahkzlrgopti4qd2u5olxmj6dj6d3ag6zxddbutu6oaukrkuup2r7wklw".base32DecodedData!, digits: 6, period: 30)
        let account = Account(label: "foo", otp: totp)
        let expectedURL = URL(string: "otpauth://totp/foo?secret=ahkzlrgopti4qd2u5olxmj6dj6d3ag6zxddbutu6oaukrkuup2r7wklw&algorithm=sha1&digits=6&period=30")!
        let expectedCompontents = URLComponents(url: expectedURL, resolvingAgainstBaseURL: false)
        let urlComponents = URLComponents(url: account.url, resolvingAgainstBaseURL: false)
        
        XCTAssertEqual(urlComponents?.queryParameters, expectedCompontents?.queryParameters)
        XCTAssertEqual(urlComponents?.host, expectedCompontents?.host)
        XCTAssertEqual(urlComponents?.scheme, expectedCompontents?.scheme)
    }

    func testURLGenerationBasic2() {
        let account = Account(label: "foo bar", otp: TOTP(algorithm: .sha256, secret: "31234567890".data(using: .ascii)!, digits: 6, period: 30), issuer: "Google Mail", imageURL: nil)
        let expectedURL = URL(string: "otpauth://totp/Google%20Mail:foo%20bar?secret=gmytemzugu3doobzga%3D%3D%3D%3D%3D%3D&algorithm=sha256&period=30&digits=6")!
        let expectedCompontents = URLComponents(url: expectedURL, resolvingAgainstBaseURL: false)
        let urlComponents = URLComponents(url: account.url, resolvingAgainstBaseURL: false)

        XCTAssertEqual(urlComponents?.queryParameters, expectedCompontents?.queryParameters)
        XCTAssertEqual(urlComponents?.host, expectedCompontents?.host)
        XCTAssertEqual(urlComponents?.scheme, expectedCompontents?.scheme)
    }
    
    func testURLGenerationAdvanced() {
        let hotp = HOTP(algorithm: .sha256, secret: "pqo23pnqscq7ld3kyeq4vj3yij7chu7fjokn25aw6jx5byjfcdbambpc".base32DecodedData!, digits: 6, count: 0)
        let account = Account(label: "foo", otp: hotp, issuer: "example.com", imageURL: URL(string: "http://www.example.com/image")!)
        let expectedURL = URL(string: "otpauth://hotp/example.com:foo?secret=pqo23pnqscq7ld3kyeq4vj3yij7chu7fjokn25aw6jx5byjfcdbambpc&algorithm=SHA256&digits=6&counter=0&image=http%3A%2F%2Fwww.example.com%2Fimage")!
        let expectedCompontents = URLComponents(url: expectedURL, resolvingAgainstBaseURL: false)
        let urlComponents = URLComponents(url: account.url, resolvingAgainstBaseURL: false)

        XCTAssertEqual(urlComponents?.queryParameters, expectedCompontents?.queryParameters)
        XCTAssertEqual(urlComponents?.host, expectedCompontents?.host)
        XCTAssertEqual(urlComponents?.scheme, expectedCompontents?.scheme)
    }
    
    func testKeychainStore() {
        let keychain = Keychain(service: "ch.gymni.test.otpauth")
        let url = URL(string: "otpauth://totp/foo?secret=wew3k6ztd7kuh5ucg4pejqi4swwrrneh72ad2sdovikfatzbc5huto2j&algorithm=SHA256&digits=6&period=30")!
        let totp = TOTP(algorithm: .sha256, secret: "wew3k6ztd7kuh5ucg4pejqi4swwrrneh72ad2sdovikfatzbc5huto2j".base32DecodedData! , digits: 6, period: 30)
        let account = Account(label: "foo", otp: totp)
        
        XCTAssertNoThrow(try account.save(to: keychain))
        defer {
            try! keychain.removeAll()
        }
        
        let accounts = try? Account.loadAll(from: keychain)
        XCTAssertNotNil(accounts)
        
        XCTAssertEqual(accounts?.first, account)
    }
    
    static var allTests = [
        ("testBasicTOTPAccount", testBasicTOTPAccount),
        ("testAdvancedTOTPAccount", testAdvancedTOTPAccount),
        ("testBasicHOTPAccount", testBasicHOTPAccount),
        ("testAdvancedTOTPAccount", testAdvancedTOTPAccount),
        ("testURLGenerationBasic1", testURLGenerationBasic1),
        ("testURLGenerationBasic2", testURLGenerationBasic2),
        ("testKeychainStore", testKeychainStore),
    ]
    
}
