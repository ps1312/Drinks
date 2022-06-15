//
//  RemoteImageLoaderTests.swift
//  DrinksCoreTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 15/06/22.
//

import Foundation
import XCTest
import DrinksCore

class RemoteImageLoader {
    private let httpClient: HTTPClient

    init (httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func load(imageFromURL url: URL) {
        httpClient.get(from: url) { _ in }
    }
}

class RemoteImageLoaderTests: XCTestCase {
    func test_imageLoader_makesRequestForImage() {
        let imageURL = URL(string: "https://image-url.com")!
        let httpClient = HTTPClientSpy()
        let sut = RemoteImageLoader(httpClient: httpClient)

        sut.load(imageFromURL: imageURL)

        XCTAssertEqual(httpClient.requests, [imageURL])
    }
}
