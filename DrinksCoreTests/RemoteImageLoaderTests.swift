//
//  RemoteImageLoaderTests.swift
//  DrinksCoreTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 15/06/22.
//

import XCTest
import DrinksCore

class RemoteImageLoader {
    private let httpClient: HTTPClient

    init (httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func load(imageFromURL url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        httpClient.get(from: url) { result in
            switch (result) {
            case .failure:
                completion(.failure(CoreError.request))
            case .success(let imageData):
                completion(.success(imageData))
            }
        }
    }
}

class RemoteImageLoaderTests: XCTestCase {
    func test_imageLoader_makesRequestForImage() {
        let (sut, httpClient) = makeSUT()

        let expectedImageURL = URL(string: "https://image-url.com")!
        sut.load(imageFromURL: expectedImageURL) { _ in }

        XCTAssertEqual(httpClient.requests, [expectedImageURL])
    }

    func test_load_returnsErrorOnLoadFailure() {
        let (sut, httpClient) = makeSUT()
        httpClient.failing = true

        assertResult(sut, expectedResult: .failure(CoreError.request))
    }

    func test_load_returnsImageDataOnSuccess() {
        let expectedData = "Some specific data".data(using: .utf8)!
        let (sut, httpClient) = makeSUT()
        httpClient.response = expectedData

        assertResult(sut, expectedResult: .success(expectedData))
    }

    func assertResult(_ sut: RemoteImageLoader, expectedResult: Result<Data, Error>) {
        var capturedResult: Result<Data, Error>? = nil
        sut.load(imageFromURL: anyURL) { capturedResult = $0 }

        switch (capturedResult, expectedResult) {
        case let (.failure(capturedError), .failure(expectedError)):
            XCTAssertEqual(capturedError as? CoreError, expectedError as? CoreError)
        case let (.success(capturedData), .success(expectedData)):
            XCTAssertEqual(capturedData, expectedData)
        default:
            XCTFail("capturedResult and expectedResult should've been equal, instead got \(String(describing: capturedResult)) and \(String(describing: expectedResult)) respectively")
        }
    }

    func makeSUT() -> (RemoteImageLoader, HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteImageLoader(httpClient: httpClient)

        return (sut, httpClient)
    }
}
