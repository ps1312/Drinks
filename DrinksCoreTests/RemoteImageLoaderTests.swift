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

    func load(imageFromURL url: URL, completion: @escaping (Swift.Error) -> Void) {
        httpClient.get(from: url) { result in
            switch (result) {
            case .failure:
                completion(CoreError.request)
            default:
                return
            }
        }
    }
}

class RemoteImageLoaderTests: XCTestCase {
    func test_imageLoader_makesRequestForImage() {
        let (sut, httpClient) = makeSUT()

        let expectedImageURL = URL(string: "https://image-url.com")!
        sut.load(imageFromURL: expectedImageURL) { _ in }

        XCTAssertEqual(httpClient.requests, [expectedImageURL])
    }

    func test_load_returnsErrorOnLoadFailure() {
        let (sut, httpClient) = makeSUT()
        httpClient.failing = true

        var capturedError: Error? = nil
        sut.load(imageFromURL: anyURL) { capturedError = $0 }

        XCTAssertEqual(capturedError as? CoreError, CoreError.request)
    }

    func makeSUT() -> (RemoteImageLoader, HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteImageLoader(httpClient: httpClient)

        return (sut, httpClient)
    }
}
