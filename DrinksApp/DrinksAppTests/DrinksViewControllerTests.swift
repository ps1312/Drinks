//
//  DrinksAppTests.swift
//  DrinksAppTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import XCTest
import DrinksCore
@testable import DrinksApp

class DrinksAppTests: XCTestCase {

    func testMakeDrinksRequestOnViewDidLoad() throws {
        let vc = UIStoryboard(name: "Main", bundle: nil)

        let exp = expectation(description: "Waiting for loader to be called...")
        let remoteDrinksLoaderSpy = RemoteDrinksLoaderSpy()
        remoteDrinksLoaderSpy.onLoad = { exp.fulfill() }

        let sut = vc.instantiateViewController(withIdentifier: "DrinksViewController") as! DrinksViewController
        sut.drinksLoader = remoteDrinksLoaderSpy

        sut.viewDidLoad()

        wait(for: [exp], timeout: 0.01)
    }

}

class RemoteDrinksLoaderSpy: DrinksLoader {
    var onLoad: (() -> Void)? = nil

    func load() async throws -> [Drink] {
        onLoad?()
        return []
    }
}


class HTTPClientSpy: HTTPClient {
    var requests: [URL] = []
    var failing: Bool = false
    var response = String("{\"drinks\": []}").data(using: .utf8)!

    func get(_ url: URL) throws -> Data {
        requests.append(url)
        if (failing) { throw NSError(domain: "any domain", code: 1) }
        return response
    }
}
