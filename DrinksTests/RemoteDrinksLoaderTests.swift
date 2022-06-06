//
//  DrinksTests.swift
//  DrinksTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import XCTest

protocol HTTPClient {
    func get(_ url: URL) -> Void
}

class RemoteDrinksLoader {
    private let url: URL
    private let httpClient: HTTPClient

    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }

    func load() {
        httpClient.get(url)
    }
}

class RemoteDrinksLoaderTests: XCTestCase {
    func testDoesNotMakeRequestsOnInit() {
        let httpClientSpy = HTTPClientSpy()
        let _ = RemoteDrinksLoader(url: URL(string: "https://www.any-url.com")!, httpClient: httpClientSpy)

        XCTAssertEqual(httpClientSpy.requests.count, 0)
    }

    func testMakeRequestsWithProvidedUrlOnLoad() {
        let httpClientSpy = HTTPClientSpy()
        let expectedUrl = URL(string: "https://www.any-url.com")!

        let sut = RemoteDrinksLoader(url: expectedUrl, httpClient: httpClientSpy)

        sut.load()

        XCTAssertEqual(httpClientSpy.requests, [expectedUrl])
    }
}

class HTTPClientSpy: HTTPClient {
    var requests: [URL] = []

    func get(_ url: URL) {
        requests.append(url)
    }
}
