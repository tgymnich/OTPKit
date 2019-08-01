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
    
    @available(OSX 10.15, *)
    func testPublisher() {
        let notificationReceived = XCTestExpectation(description: "receive notification")
        let totp = TOTP(algorithm: .sha256, secret: "01234567890".data(using: .ascii)!, digits: 6, period: TOTPPublisherTests.period)
        let pub = TOTP.TOTPPublisher(totp: totp)
        _ = pub.sink { code in
            XCTAssertEqual(code, totp.code())
            notificationReceived.fulfill()
        }
        wait(for: [notificationReceived], timeout: TimeInterval(TOTPPublisherTests.period * 2))
    }
    
    static var allTests = [
        ("testNotificationCenter", testNotificationCenter),
    ]
    
}
