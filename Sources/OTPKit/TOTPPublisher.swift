//
//  TOTPPublisher.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/25/19.
//

import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension TOTP {

    var publisher: TOTPPublisher { TOTPPublisher(totp: self) }

    struct TOTPToken {
        public let code: String
        public let timeRemaining: TimeInterval
    }

    struct TOTPPublisher: Publisher {
        public typealias Output = TOTPToken
        public typealias Failure = Never
        
        let totp: TOTP
        
        public init(totp: TOTP) {
            self.totp = totp
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, TOTP.TOTPPublisher.Failure == S.Failure, TOTP.TOTPPublisher.Output == S.Input {
            let subscription  = TOTPSubscription(subscriber: subscriber, totp: totp)
            subscriber.receive(subscription: subscription)
        }
        
    }
    
    class TOTPSubscription<SubscriberType: Subscriber>: Subscription where SubscriberType.Input == TOTPToken {
        private var subscriber: SubscriberType?
        private let totp: TOTP
        private lazy var timer: Timer = {
            let timeForNextPeriod = Date(timeIntervalSince1970: TimeInterval((totp.counter + 1) * totp.period))
            let timer = Timer(fire: timeForNextPeriod, interval: TimeInterval(totp.period), repeats: true) { [weak self] _ in
                guard let self = self else { return }
                let timeForNextPeriod = Date(timeIntervalSince1970: TimeInterval((self.totp.counter + 1) * self.totp.period))
                let timeRemaining = timeForNextPeriod.timeIntervalSince(Date())
                let token = TOTPToken(code: self.totp.code(), timeRemaining: timeRemaining)
                _ = self.subscriber?.receive(token)
            }
            timer.tolerance = 1
            return timer
        }()
        
        init(subscriber: SubscriberType, totp: TOTP) {
            self.subscriber = subscriber
            self.totp = totp
            RunLoop.main.add(timer, forMode: .default)
        }
        
        public func request(_ demand: Subscribers.Demand) {
            let timeForNextPeriod = Date(timeIntervalSince1970: TimeInterval((totp.counter + 1) * totp.period))
            let timeRemaining = timeForNextPeriod.timeIntervalSince(Date())
            let token = TOTPToken(code: self.totp.code(), timeRemaining: timeRemaining)
            _ = subscriber?.receive(token)
        }
        
        public func cancel() {
            self.timer.invalidate()
            self.subscriber = nil
        }
        
    }
}
