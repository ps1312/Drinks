//
//  RemoteImageLoader.swift
//  DrinksCore
//
//  Created by Paulo Sergio da Silva Rodrigues on 15/06/22.
//

import Foundation

public class RemoteImageLoader {
    private let httpClient: HTTPClient

    public init (httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    public func load(imageFromURL url: URL, completion: @escaping (DataResult) -> Void) {
        httpClient.get(from: url) { result in
            switch (result) {
            case .failure:
                completion(.failure(CoreError.request))
            case .success(let imageData):
                completion(.success(imageData))
            }
        }
    }
}
