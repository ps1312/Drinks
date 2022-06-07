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

    override func setUp() {
        URLProtocolStub.request = nil
        URLProtocolStub.mockData = nil
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

    func testMakesRequestWithCorrectURL() async {
        let expectedUrl = URL(string: "https://www.specific-url.com")!
        let client = URLSessionHTTPClient()

        let _ = try? await client.get(expectedUrl)

        XCTAssertEqual(URLProtocolStub.request?.url, expectedUrl)
    }

    func testReturnsDataWhenRequestCompletes() async {
        let expectedResult = String("expected response data").data(using: .utf8)!
        URLProtocolStub.mockData = expectedResult

        let client = URLSessionHTTPClient()

        let result = try? await client.get(URL(string: "https://www.any-url.com")!)

        XCTAssertEqual(result, expectedResult)
    }

}


class URLProtocolStub: URLProtocol {
    static var request: URLRequest? = nil
    static var mockData: Data? = nil

    override class func canInit(with request: URLRequest) -> Bool { return true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        URLProtocolStub.request = request

        if (URLProtocolStub.mockData != nil) {
            client?.urlProtocol(self, didReceive: URLResponse(url: request.url!, mimeType: "", expectedContentLength: 0, textEncodingName: ""), cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: URLProtocolStub.mockData!)
        } else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "any domain", code: 1))
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
