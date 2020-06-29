//
//  TOTPPublisherTests.swift
//  OTPKitTests
//
//  Created by Tim Gymnich on 7/25/19.
//

import XCTest
@testable import OTPKit

class TOTPPublisherTests: XCTestCase {
    
    static let period: UInt64 = 5
    
    func testNotificationCenter() {
        let notificationReceived = XCTestExpectation(description: "receive notification")
        let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: TOTPPublisherTests.period)
        NotificationCenter.default.addObserver(forName: .didGenerateNewOTPCode, object: totp, queue: .main) { notification in
            let code = notification.userInfo?[TOTP.UserInfoKeys.code] as? String
            XCTAssertNotNil(code)
            XCTAssertEqual(code, totp.code())
            notificationReceived.fulfill()
        }
        wait(for: [notificationReceived], timeout: TimeInterval(TOTPPublisherTests.period * 2))
    }
    
    func testNotificationCenterCollect5Notifications() {
        let recieved5Notifications = XCTestExpectation(description: "receive 5 notifications")
        let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: 1)
        var codes: [String] = [] {
            didSet {
                if codes.count == 5 {
                    recieved5Notifications.fulfill()
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .didGenerateNewOTPCode, object: totp, queue: .main) { notification in
            let code = notification.userInfo?[TOTP.UserInfoKeys.code] as? String
            XCTAssertNotNil(code)
            XCTAssertEqual(code, totp.code())
            codes.append(code!)
        }
        wait(for: [recieved5Notifications], timeout: TimeInterval(2 * 5))
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testPublisher() {
        let notificationReceived = XCTestExpectation(description: "receive notification")
        let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: TOTPPublisherTests.period)
        let pub = TOTP.TOTPPublisher(totp: totp)
            .sink { token in
                XCTAssertEqual(token.code, totp.code())
                notificationReceived.fulfill()
        }
        wait(for: [notificationReceived], timeout: TimeInterval(TOTPPublisherTests.period * 2))
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testPublisherCollect5Codes() {
        let received5Codes = XCTestExpectation(description: "receive 5 otp codes")
        let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: 1)
        let pub = TOTP.TOTPPublisher(totp: totp)
            .collect(5).sink { tokens in
                XCTAssertEqual(tokens.count, 5)
                received5Codes.fulfill()
        }
        wait(for: [received5Codes], timeout: TimeInterval(2 * 5))
    }
    
    static var allTests = [
        ("testNotificationCenter", testNotificationCenter),
        ("testNotificationCenterCollect5Notifications", testNotificationCenterCollect5Notifications),
    ]
    
}
