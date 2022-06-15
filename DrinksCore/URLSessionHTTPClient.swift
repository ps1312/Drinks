//
//  URLSessionHTTPClient.swift
//  DrinksCore
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSession

    public enum Error: Swift.Error {
        case unexpected
    }

    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    public func get(from url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void) {
        let task = urlSession.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(URLSessionHTTPClient.Error.unexpected))
                return
            }

            completion(.success(data ?? Data()))
        }

        task.resume()
    }
}
