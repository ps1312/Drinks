//
//  URLSessionHTTPClientTests.swift
//  DrinksCoreTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import XCTest
import DrinksCore

class URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func get(_ url: URL) async throws -> Data {
        let (data, _) = try await urlSession.data(from: url)
        return data
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func testMakesRequestWithCorrectURL() async {
        URLProtocol.registerClass(URLProtocolStub.self)

        let expectedUrl = URL(string: "https://www.specific-url.com")!
        let client = URLSessionHTTPClient()

        let _ = try? await client.get(expectedUrl)

        XCTAssertEqual(URLProtocolStub.request?.url, expectedUrl)
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

}


class URLProtocolStub: URLProtocol {
    static var request: URLRequest? = nil

    override class func canInit(with request: URLRequest) -> Bool { return true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        URLProtocolStub.request = request
        
        client?.urlProtocol(self, didFailWithError: NSError(domain: "any domain", code: 1))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
