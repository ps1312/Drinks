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

    func test_get_returnsErrorOnInvalidCases() {
        assertInvalidCase(stub: (data: nil, response: nil, error: nil))
        assertInvalidCase(stub: (data: anyData, response: nil, error: nil))
        assertInvalidCase(stub: (data: nil, response: anyHTTPURLResponse, error: anyError))
        assertInvalidCase(stub: (data: anyData, response: nil, error: anyError))
        assertInvalidCase(stub: (data: anyData, response: anyHTTPURLResponse, error: anyError))
        assertInvalidCase(stub: (data: nil, response: nil, error: anyError))
    }

    func test_get_returnsDataWhenRequestSucceeds() {
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

    func assertInvalidCase(stub: URLProtocolStub.Stub) {
        let exp = XCTestExpectation(description: "Waiting for client completion to be called...")

        URLProtocolStub.stub = (data: stub.data, response: stub.response, error: stub.error)

        let sut = URLSessionHTTPClient()

        var capturedResult: Result<Data, Error>? = nil
        sut.get(from: anyURL) { result in
            capturedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)

        switch (capturedResult) {
        case .failure(let error):
            XCTAssertEqual(error as? CoreError, CoreError.request)
        default:
            XCTFail("Expected result to be a failure with \(CoreError.request)")
        }
    }
}


class URLProtocolStub: URLProtocol {
    typealias Stub = (data: Data?, response: URLResponse?, error: Error?)

    static var stub: Stub? = nil
    static var lastRequest: URLRequest? = nil

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
