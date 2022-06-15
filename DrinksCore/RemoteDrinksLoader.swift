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

    public func load(completion: @escaping (Result<[Drink], Swift.Error>) -> Void) {
        httpClient.get(from: url) { result in
            switch (result) {
            case .failure:
                completion(.failure(CoreError.request))
            case .success(let data):
                do {
                    let apiResult = try JSONDecoder().decode(ApiDrinksResult.self, from: data)
                    let drinks = apiResult.drinks.map { Drink(id: Int($0.idDrink)!, name: $0.strDrink, thumb: URL(string: $0.strDrinkThumb)!) }

                    completion(.success(drinks))
                } catch {
                    completion(.failure(CoreError.decoder))
                }
            }
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
