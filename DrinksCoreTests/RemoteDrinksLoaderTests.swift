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
        let expectedUrl = URL(string: "https://www.specific-url.com")!

        let (sut, httpClient) = makeSUT(url: expectedUrl)

        sut.load { _ in }

        XCTAssertEqual(httpClient.requests, [expectedUrl])
    }

    func test_load_returnsRequestErrorOnHTTPClientFailure() {
        let (sut, httpClient) = makeSUT()
        httpClient.failing = true

        assertResult(sut, result: .failure(CoreError.request))
    }

    func test_load_returnsDecoderErrorOnInvalidJSON() {
        let (sut, httpClient) = makeSUT()
        httpClient.response = "invalid json".data(using: .utf8)!

        assertResult(sut, result: .failure(CoreError.decoder))
    }

    func test_load_returnsEmptyArrayOnEmptyJSON() {
        let (sut, _) = makeSUT()

        assertResult(sut, result: .success([Drink]()))
    }

    func test_load_returnsDrinksOnValidNonEmptyResponse() {
        let (drinks, json) = makeDrinkSubject(size: 3)

        let (sut, httpClient) = makeSUT()
        httpClient.response = json

        assertResult(sut, result: .success(drinks))
    }

    func makeSUT(url: URL = anyURL) -> (sut: RemoteDrinksLoader, httpClient: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteDrinksLoader(url: url, httpClient: httpClient)

        return (sut, httpClient)
    }

    func assertResult(_ sut: RemoteDrinksLoader, result expectedResult: Result<[Drink], CoreError>) {
        var capturedResult: Result<[Drink], Error>? = nil
        sut.load { capturedResult = $0 }

        switch (capturedResult, expectedResult) {
        case let (.failure(capturedError), .failure(expectedError)):
            XCTAssertEqual(capturedError as? CoreError, expectedError)
        case let (.success(capturedDrinks), .success(expectedDrinks)):
            XCTAssertEqual(capturedDrinks, expectedDrinks)
        default:
            XCTFail("Captured and expected results should be same, instead got captured: \(String(describing: capturedResult)), expected: \(String(describing: expectedResult))")
        }
    }

    func makeDrinkSubject(size: Int = 2) -> ([Drink], Data) {
        var models = [Drink]()
        var partialJSON = ""

        for i in 1...size {
            let model = Drink(id: i, name: "name \(i)", thumb: URL(string: "https://www.any-url.com/image\(i)")!)
            models.append(model)
            partialJSON += "{\"strDrink\":\"\(model.name)\",\"strDrinkThumb\":\"\(model.thumb)\",\"idDrink\":\"\(model.id)\"}"

            if (i < size) {
                partialJSON += ","
            }
        }

        let responseJSON = "{\"drinks\":[\(partialJSON)]}"

        return (models, json: responseJSON.data(using: .utf8)!)
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
