//
//  Services.swift
//  Drinks
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import Foundation

public class RemoteDrinksLoader {
    private let url: URL
    private let httpClient: HTTPClient

    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }

    public enum Error: Swift.Error {
        case request
    }

    public func load() async throws -> [Drink] {
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
