//
//  Account.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation


struct Account {
    var label: String
    var otp: OTP
    var issuer: String?
    var imageURL: URL?

    
    init(label: String, otp: OTP, issuer: String? = nil, imageURL: URL? = nil) {
        self.label = label
        self.otp = otp
        self.issuer = issuer
        self.imageURL = imageURL
    }
    
    init?(from url: URL) {
        // otpauth://TYPE/LABEL?PARAMETERS
        
        guard url.scheme == "otpauth" else { return nil }
        
        guard let type = url.host else {
            return nil
        }
        
        let components = url.pathComponents.dropFirst().first?.split(separator: ":")
        
                
        guard let label = components?.last else {
            return nil
        }
        self.label = String(label)
        
        if let issuer = components?.dropLast().last {
            self.issuer = String(issuer)
        }
        
        if let imageURLString = url.queryParameters?["image"] {
            self.imageURL = URL(string: imageURLString)
        }
        
        switch type {
        case "totp":
            guard let totp = TOTP(from: url) else { return nil }
            self.otp = totp
        case "hotp":
            guard let hotp = HOTP(from: url) else { return nil }
                self.otp = hotp
        default:
            return nil
        }
    }
    
}
