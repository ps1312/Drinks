//
//  DrinksTests.swift
//  DrinksTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import XCTest
import DrinksCore

class RemoteDrinksLoaderTests: XCTestCase {
    func test_init_doesNotMakeRequests() {
        let httpClientSpy = HTTPClientSpy()

        let _ = makeSUT()

        XCTAssertEqual(httpClientSpy.requests.count, 0)
    }

    func test_load_makeRequestWithUrl() {
        let expectedUrl = URL(string: "https://www.any-url.com")!

        let (sut, httpClient) = makeSUT(url: expectedUrl)

        sut.load { _ in }

        XCTAssertEqual(httpClient.requests, [expectedUrl])
    }

    func test_load_returnsRequestErrorOnHTTPClientFailure() {
        let (sut, httpClient) = makeSUT()
        httpClient.failing = true

        var result: Result<[Drink], RemoteDrinksLoader.Error>? = nil
        sut.load { result = $0 }

        switch (result) {
        case .failure(let err):
            XCTAssertEqual(err, .request)
        default:
            XCTFail("Expected result to be a failure with .request error")
        }
    }

    func test_load_returnsDecoderErrorOnInvalidJSON() {
        let (sut, httpClient) = makeSUT()
        httpClient.response = "invalid json".data(using: .utf8)!

        var result: Result<[Drink], RemoteDrinksLoader.Error>? = nil
        sut.load { result = $0 }

        switch (result) {
        case .failure(let err):
            XCTAssertEqual(err, .decoder)
        default:
            XCTFail("Expected result to be a failure with .request error")
        }
    }

    func test_load_returnsEmptyArrayOnEmptyJSON() {
        let (sut,_) = makeSUT()

        var result: Result<[Drink], RemoteDrinksLoader.Error>? = nil
        sut.load { result = $0 }

        switch (result) {
        case .success(let drinks):
            XCTAssertEqual(drinks, [Drink]())
        default:
            XCTFail("Expected result to be a success with an empty array")
        }
    }

    func test_load_returnsDrinksOnValidNonEmptyResponse() async throws {
        let drink1 = Drink(id: 0, name: "name 1", thumb: URL(string: "https://www.any-url.com/image1")!)
        let drink2 = Drink(id: 1, name: "name 2", thumb: URL(string: "https://www.any-url.com/image2")!)
        let (sut, httpClient) = makeSUT()
        httpClient.response = """
        {
            "drinks": [
                {"strDrink":"name 1","strDrinkThumb":"https://www.any-url.com/image1","idDrink":"0"},
                {"strDrink":"name 2","strDrinkThumb":"https://www.any-url.com/image2","idDrink":"1"}
            ]
        }
        """.data(using: .utf8)!

        var result: Result<[Drink], RemoteDrinksLoader.Error>? = nil
        sut.load { result = $0 }

        switch (result) {
        case .success(let drinks):
            XCTAssertEqual(drinks, [drink1, drink2])
        default:
            XCTFail("Expected result to be a success with an empty array")
        }
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
    var response = String("{\"drinks\": []}").data(using: .utf8)!

    func get(from url: URL, completion: (Result<Data, Error>) -> Void) {
        requests.append(url)

        if (failing) {
            completion(.failure(anyError))
            return
        }

        completion(.success(response))
    }
}
