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

    public func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(data ?? Data()))
        }

        task.resume()
    }
}
