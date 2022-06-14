//
//  URLSessionHTTPClientTests.swift
//  DrinksCoreTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import XCTest
import DrinksCore

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        URLProtocolStub.request = nil
        URLProtocolStub.mockData = nil
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

    func testMakesRequestWithCorrectURL() {
        let exp = XCTestExpectation(description: "Waiting for client completion to be called...")

        let expectedUrl = URL(string: "https://www.specific-url.com")!
        let client = URLSessionHTTPClient()

        client.get(from: expectedUrl) { _ in exp.fulfill() }

        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(URLProtocolStub.request?.url, expectedUrl)
    }

    func testReturnsDataWhenRequestCompletes() async {
        let exp = XCTestExpectation(description: "Waiting for client completion to be called...")

        let expectedResult = String("expected response data").data(using: .utf8)!
        URLProtocolStub.mockData = expectedResult

        let client = URLSessionHTTPClient()

        var capturedResult: Result<Data, Error>? = nil
        client.get(from: URL(string: "https://www.any-url.com")!) { result in
            capturedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)

        switch (capturedResult) {
        case .success(let data):
            XCTAssertEqual(data, expectedResult)
        default:
            XCTFail("Expected result to be a success with specific data")
        }
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
            let urlResponse = URLResponse(url: request.url!, mimeType: "", expectedContentLength: 0, textEncodingName: "")
            client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: URLProtocolStub.mockData!)
        } else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "any domain", code: 1))
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
