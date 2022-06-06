//
//  DrinksTests.swift
//  DrinksTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import XCTest
import Drinks

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

    func load() async throws -> [Drink] {
        do {
            try await httpClient.get(url)

            return []
        } catch {
            throw Error.request
        }
    }
}

class RemoteDrinksLoaderTests: XCTestCase {
    func testDoesNotMakeRequestsOnInit() {
        let httpClientSpy = HTTPClientSpy()
        let _ = makeSUT()

        XCTAssertEqual(httpClientSpy.requests.count, 0)
    }

    func testMakeRequestsWithProvidedUrlOnLoad() async throws {
        let expectedUrl = URL(string: "https://www.any-url.com")!
        let (sut, httpClient) = makeSUT(url: expectedUrl)

        let _ = try await sut.load()

        XCTAssertEqual(httpClient.requests, [expectedUrl])
    }

    func testReturnsErrorOnRequestFailure() async {
        let (sut, httpClient) = makeSUT()
        httpClient.failing = true

        do {
            let _ = try await sut.load()
        } catch {
            let capturedError = error as? RemoteDrinksLoader.Error
            XCTAssertEqual(capturedError, .request)
        }
    }

    func testReturnsEmptyArrayOnRequestSuccess() async throws {
        let (sut,_) = makeSUT()

        let result = try await sut.load()

        XCTAssertEqual(result.count, 0)
    }

    func makeSUT(url: URL = URL(string: "https://www.any-url.com")!) -> (sut: RemoteDrinksLoader, httpClient: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteDrinksLoader(url: url, httpClient: httpClient)

        return (sut, httpClient)
    }
}

class HTTPClientSpy: HTTPClient {
    var requests: [URL] = []
    var failing: Bool = false

    func get(_ url: URL) throws {
        requests.append(url)

        if (failing) { throw NSError(domain: "any domain", code: 1) }
    }
}
