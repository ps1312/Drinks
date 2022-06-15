//
//  RemoteImageLoaderTests.swift
//  DrinksCoreTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 15/06/22.
//

import XCTest
import DrinksCore

class RemoteImageLoader {
    private let httpClient: HTTPClient

    init (httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    enum Error: Swift.Error {
        case request
    }

    func load(imageFromURL url: URL, completion: @escaping (Swift.Error) -> Void) {
        httpClient.get(from: url) { result in
            switch (result) {
            case .failure:
                completion(Error.request)
            default:
                return
            }
        }
    }
}

class RemoteImageLoaderTests: XCTestCase {
    func test_imageLoader_makesRequestForImage() {
        let imageURL = URL(string: "https://image-url.com")!
        let httpClient = HTTPClientSpy()
        let sut = RemoteImageLoader(httpClient: httpClient)

        sut.load(imageFromURL: imageURL) { _ in }

        XCTAssertEqual(httpClient.requests, [imageURL])
    }

    func test_load_returnsErrorOnLoadFailure() {
        let httpClient = HTTPClientSpy()
        httpClient.failing = true
        let sut = RemoteImageLoader(httpClient: httpClient)

        var capturedError: Error? = nil
        sut.load(imageFromURL: anyURL) { capturedError = $0 }


        XCTAssertEqual(capturedError as? RemoteImageLoader.Error, RemoteImageLoader.Error.request)
    }
}
