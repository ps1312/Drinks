//
//  DrinksTests.swift
//  DrinksTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import XCTest

protocol HTTPClient {}

class RemoteDrinksLoader {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
}

class RemoteDrinksLoaderTests: XCTestCase {
    func testDoesNotMakeRequestsOnInit() {
        let httpClientSpy = HTTPClientSpy()
        let _ = RemoteDrinksLoader(httpClient: httpClientSpy)

        XCTAssertEqual(httpClientSpy.requestsCount, 0)
    }
}

class HTTPClientSpy: HTTPClient {
    var requestsCount = 0
}
