//
//  Account.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/17/19.
//

import Foundation
import KeychainAccess

public struct Account<OTPType: OTP>: Codable, Hashable, Identifiable {
    private let keychainKey: String
    /// The label is used to identify which account a key is associated with
    public var id: URL { url }
    public let label: String
    /// OTP Generator instance used by the account. Responsible for all cryptograhic operations.
    public let otpGenerator: OTPType
    /// String identifying the provider or service managing that account
    public let issuer: String?
    /// URL refering to the image for the account.
    public let imageURL: URL?
    /// All the account information encoded in a otpauth URL
    public var url: URL {
        let queryItemImageURL = URLQueryItem(name: "image", value: imageURL?.absoluteString)
        // otpauth://TYPE/ISSUER:LABEL?PARAMETERS
        let issuerString = issuer?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        guard let labelString = label.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
              var components = URLComponents(string: "otpauth://\(OTPType.typeString)/\(issuerString)\(issuerString.isEmpty ? "" : ":")\(labelString)") else {
            fatalError("Error encoding URL")
        }
        var queryItems = [queryItemImageURL] + otpGenerator.urlQueryItems
        // remove query items with no value (optional parameters)
        queryItems = queryItems.filter { $0.value != nil }
        components.queryItems = queryItems
        return components.url!
    }

    public enum Error: LocalizedError {
        case accountAlreadyExists
        
        public var errorDescription: String? {
            switch self {
            case .accountAlreadyExists:
                return "The account already exists"
            }
        }

        public var failureReason: String? {
            switch self {
            case .accountAlreadyExists:
                return "Accounts cannot share the same label and issuer"
            }
        }
    }
    
    /// - Parameter label: The label is used to identify which account a key is associated with. It contains an account name, which is a URI-encoded string, optionally prefixed by an issuer string identifying the provider or service managing that account. This issuer prefix can be used to prevent collisions between different accounts with different providers that might be identified using the same account name, e.g. the user's email address.
    /// - Parameter otp: OTP instance used by this account.
    /// - Parameter issuer: The issuer parameter is a string value indicating the provider or service this account is associated with, URL-encoded according to RFC 3986. If the issuer parameter is absent, issuer information may be taken from the issuer prefix of the label. If both issuer parameter and issuer label prefix are present, they should be equal.
    /// - Parameter imageURL: URL refering to the image for the account.
    public init(label: String, otp: OTPType, issuer: String? = nil, imageURL: URL? = nil) {
        self.label = label
        self.otpGenerator = otp
        self.issuer = issuer
        self.imageURL = imageURL

        if let issuer = issuer {
            self.keychainKey = "\(issuer)-\(label)"
        } else {
            self.keychainKey = "\(label)"
        }
    }
    
    
    /// Used to initalize a account from a URL.
    /// - Parameter url: A url encoded like this: otpauth://TYPE/ISSUER:LABEL?PARAMETERS
    public init(from url: URL) throws {
        // otpauth://TYPE/LABEL?PARAMETERS
        guard url.scheme == "otpauth" else { throw URLDecodingError.invalidURLScheme(url.scheme) }
                
        let components = url.pathComponents.dropFirst().first?.split(separator: ":")
        
        guard let labelComponent = components?.last else { throw URLDecodingError.invalidURLLabel(nil) }
        let label = String(labelComponent)

        var issuer: String?
        if let issuerComponent = components?.dropLast().last {
            issuer = String(issuerComponent)
        }

        var imageURL: URL?
        if let imageURLString = url.queryParameters?["image"] {
            imageURL = URL(string: imageURLString)
        }
        
        let otp = try OTPType(from: url)

        self.init(label: label, otp: otp, issuer: issuer, imageURL: imageURL)
    }
    
    // MARK: - Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let url = try container.decode(URL.self)
        try self.init(from: url)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url)
    }
    
    // MARK: - Keychain
    
    /// Saves the account to a keychain
    /// - Parameter keychain
    public func save(to keychain: Keychain) throws {
        guard try keychain.get(keychainKey) == nil else { throw Error.accountAlreadyExists }

        try keychain
            .label(label)
            .comment("otp access token")
            .set(url.absoluteString, key: keychainKey)
    }

    public func remove(from keychain: Keychain) throws {
        try keychain.remove(keychainKey)
    }
    
    
    /// Loads all the accounts from a keychain
    /// - Parameter keychain
    public static func loadAll(from keychain: Keychain) throws -> [Account] {
        let items = keychain.allKeys()
        let accounts = try items.compactMap { key throws -> Account? in
            guard let urlString = try keychain.get(key), let url = URL(string: urlString) else { return nil }
            return try Account(from: url)
        }
        return accounts
    }
    
}
