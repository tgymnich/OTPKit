//
//  Extensions.swift
//  OTPKit
//
//  Created by Tim Gymnich on 7/4/19.
//

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        return components?.queryParameters ?? [:]
    }
}

extension URLComponents {
    public var queryParameters: [String: String]? {
        guard let queryItems = self.queryItems else { return [:] }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            let name = item.name.lowercased()
            let value = item.value?.lowercased() ?? ""
            result[name] = value
        }
    }
}
