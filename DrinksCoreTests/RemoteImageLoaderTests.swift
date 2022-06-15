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

        var capturedResult: Result<Data, Error>? = nil
        sut.load(imageFromURL: anyURL) { capturedResult = $0 }

        switch (capturedResult) {
        case .failure(let capturedError):
            XCTAssertEqual(capturedError as? CoreError, CoreError.request)
        default:
            XCTFail("Expected a failure, instead got \(String(describing: capturedResult))")
        }
    }

    func test_load_returnsImageDataOnSuccess() {
        let expectedData = "Some specific data".data(using: .utf8)!

        let (sut, httpClient) = makeSUT()
        httpClient.response = expectedData

        var capturedResult: Result<Data, Error>? = nil
        sut.load(imageFromURL: anyURL) { capturedResult = $0 }

        switch (capturedResult) {
        case .success(let capturedData):
            XCTAssertEqual(capturedData, expectedData)
        default:
            XCTFail("Expected a success, instead got \(String(describing: capturedResult))")
        }
    }

    func makeSUT() -> (RemoteImageLoader, HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteImageLoader(httpClient: httpClient)

        return (sut, httpClient)
    }
}
