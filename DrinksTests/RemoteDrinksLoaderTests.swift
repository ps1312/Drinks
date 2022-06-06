//
//  DrinksTests.swift
//  DrinksTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import XCTest

protocol HTTPClient {
    func get(_ url: URL) async throws -> Void
}

class RemoteDrinksLoader {
    private let url: URL
    private let httpClient: HTTPClient

    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }

    enum Error: Swift.Error {
        case request
    }

    func load() async throws {
        do {
            try await httpClient.get(url)
        } catch {
            throw Error.request
        }
    }
}

class RemoteDrinksLoaderTests: XCTestCase {
    func testDoesNotMakeRequestsOnInit() {
        let httpClientSpy = HTTPClientSpy()
        let _ = makeSUT(httpClient: httpClientSpy)

        XCTAssertEqual(httpClientSpy.requests.count, 0)
    }

    func testMakeRequestsWithProvidedUrlOnLoad() async throws {
        let httpClientSpy = HTTPClientSpy()
        let expectedUrl = URL(string: "https://www.any-url.com")!
        let sut = makeSUT(url: expectedUrl, httpClient: httpClientSpy)

        try await sut.load()

        XCTAssertEqual(httpClientSpy.requests, [expectedUrl])
    }

    func testReturnsErrorOnRequestFailure() async {
        let sut = makeSUT(httpClient: HTTPClientSpy(failing: true))

        do {
            try await sut.load()
        } catch {
            let capturedError = error as? RemoteDrinksLoader.Error
            XCTAssertEqual(capturedError, .request)
        }
    }

    func makeSUT(url: URL = URL(string: "https://www.any-url.com")!, httpClient: HTTPClientSpy) -> RemoteDrinksLoader {
        let sut = RemoteDrinksLoader(url: url, httpClient: httpClient)
        return sut
    }
}

class HTTPClientSpy: HTTPClient {
    var requests: [URL] = []
    private let failing: Bool

    init(failing: Bool = false) {
        self.failing = failing
    }

    func get(_ url: URL) throws {
        requests.append(url)

        if (failing) { throw NSError(domain: "any domain", code: 1) }
    }
}
