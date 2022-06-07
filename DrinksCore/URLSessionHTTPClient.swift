//
//  URLSessionHTTPClient.swift
//  DrinksCore
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSession

    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    public func get(_ url: URL) async throws -> Data {
        let (data, _) = try await urlSession.data(from: url)
        return data
    }
}
