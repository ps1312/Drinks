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
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

    func test_get_makesRequestWithCorrectURL() {
        let exp = XCTestExpectation(description: "Waiting for client completion to be called...")

        let expectedUrl = URL(string: "https://www.specific-url.com")!
        let sut = URLSessionHTTPClient()

        sut.get(from: expectedUrl) { _ in exp.fulfill() }

        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(URLProtocolStub.lastRequest?.url, expectedUrl)
    }

    func test_get_returnsUnexpectedErrorOnRequestFailure() {
        let exp = XCTestExpectation(description: "Waiting for client completion to be called...")

        URLProtocolStub.stub = (data: nil, response: nil, error: anyError)

        let sut = URLSessionHTTPClient()

        var capturedResult: Result<Data, Error>? = nil
        sut.get(from: anyURL) { result in
            capturedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)

        switch (capturedResult) {
        case .failure(let error):
            XCTAssertEqual(error as? URLSessionHTTPClient.Error, .unexpected)
        default:
            XCTFail("Expected result to be a failute with \(URLSessionHTTPClient.Error.unexpected)")
        }
    }

    func test_get_returnsDataOnTaskSuccess() {
        let exp = XCTestExpectation(description: "Waiting for client completion to be called...")

        let expectedResult = String("expected response data").data(using: .utf8)!

        URLProtocolStub.stub = (data: expectedResult, response: nil, error: nil)

        let sut = URLSessionHTTPClient()

        var capturedResult: Result<Data, Error>? = nil
        sut.get(from: anyURL) { result in
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
    static var lastRequest: URLRequest? = nil

    public typealias Stub = (data: Data?, response: URLResponse?, error: Error?)

    static var stub: Stub? = nil

    override class func canInit(with request: URLRequest) -> Bool { return true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        URLProtocolStub.lastRequest = request

        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
