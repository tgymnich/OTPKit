//
//  URLDecodingError.swift
//  
//
//  Created by Tim Gymnich on 25.08.20.
//

import Foundation

public enum URLDecodingError: LocalizedError {
    case invalidURLScheme(String?)
    case invalidURLLabel(String?)
    case invalidOTPType(String?)
    case invalidURLQueryParamters
    case invalidSecret
    case invalidAlgorithm(String?)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURLScheme:
            return "Invalid URL scheme"
        case .invalidOTPType:
            return "Invalid OTP type"
        case .invalidURLQueryParamters:
            return "Invalid URL query paramters"
        case .invalidSecret:
            return "Invalid secret"
        case .invalidAlgorithm:
            return "Invalid algorithm"
        case .invalidURLLabel:
            return "Invalid label"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case let .invalidURLScheme(scheme):
            if let scheme = scheme {
                return "The URL scheme \"\(scheme)\" is not supported"
            } else {
                return "The URL scheme is missing or not supported"
            }
        case let .invalidOTPType(type):
            if let type = type {
                return "The OTP type \"\(type)\" is not supported"
            } else {
                return "The OTP type is missing or not supported"
            }
        case .invalidURLQueryParamters:
            return nil
        case .invalidSecret:
            return  nil
        case let .invalidAlgorithm(algorithm):
            if let algorithm = algorithm {
                return "The algorithm \"\(algorithm)\" is not supported"
            } else {
                return "The algorithm is missing or not supported"
            }
        case .invalidURLLabel:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidURLScheme:
            return "Try using one of the supported URL schemes. Supported URL schemes are: otpauth"
        case .invalidOTPType:
            return "Try using one of the supported OTP types"
        case .invalidURLQueryParamters:
            return nil
        case .invalidSecret:
            return nil
        case .invalidAlgorithm:
            return "Try using one of the supported algorithms. Supported algorithms are: \(Algorithm.allCases.map { $0.string }.joined(separator: ","))"
        case .invalidURLLabel:
            return nil
        }
    }
}
