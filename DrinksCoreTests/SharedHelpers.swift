//
//  SharedHelpers.swift
//  DrinksCoreTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 14/06/22.
//

import Foundation
import DrinksCore

let anyError = NSError(domain: "error from shared helpers", code: 111)
let anyURL = URL(string: "https://www.any-url.com")!
let anyHTTPURLResponse =  HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: "", headerFields: [:])
let anyData = Data()

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
