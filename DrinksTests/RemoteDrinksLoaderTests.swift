//
//  DrinksTests.swift
//  DrinksTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import XCTest
import Drinks

protocol HTTPClient {
    func get(_ url: URL) async throws -> Data
}

class RemoteDrinksLoader {
    private let url: URL
    private let httpClient: HTTPClient

    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }

    enum Error: Swift.Error {
        case request
    }

    func load() async throws -> [Drink] {
        do {
            let data = try await httpClient.get(url)
            let result = try JSONDecoder().decode(ApiDrinksResult.self, from: data)
            return result.drinks.map { Drink(id: Int($0.idDrink)!, name: $0.strDrink, thumb: URL(string: $0.strDrinkThumb)!) }
        } catch {
            throw Error.request
        }
    }
}

struct ApiDrink: Decodable {
  var strDrink: String
  var strDrinkThumb: String
  var idDrink: String
}

struct ApiDrinksResult: Decodable {
    let drinks: [ApiDrink]

    init(drinks: [ApiDrink]) {
        self.drinks = drinks
    }
}

class RemoteDrinksLoaderTests: XCTestCase {
    func testDoesNotMakeRequestsOnInit() {
        let httpClientSpy = HTTPClientSpy()
        let _ = makeSUT()

        XCTAssertEqual(httpClientSpy.requests.count, 0)
    }

    func testMakeRequestsWithProvidedUrlOnLoad() async throws {
        let expectedUrl = URL(string: "https://www.any-url.com")!
        let (sut, httpClient) = makeSUT(url: expectedUrl)

        let _ = try await sut.load()

        XCTAssertEqual(httpClient.requests, [expectedUrl])
    }

    func testReturnsErrorOnRequestFailure() async {
        let (sut, httpClient) = makeSUT()
        httpClient.failing = true

        do {
            let _ = try await sut.load()
        } catch {
            let capturedError = error as? RemoteDrinksLoader.Error
            XCTAssertEqual(capturedError, .request)
        }
    }

    func testReturnsEmptyArrayOnRequestSuccess() async throws {
        let (sut,_) = makeSUT()

        let result = try await sut.load()

        XCTAssertEqual(result.count, 0)
    }

    func testReturnsDrinksArrayWhenRequestCompletesWithData() async throws {
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

        let result = try await sut.load()

        XCTAssertEqual(result, [drink1, drink2])
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

    func get(_ url: URL) throws -> Data {
        requests.append(url)
        if (failing) { throw NSError(domain: "any domain", code: 1) }
        return response
    }
}
