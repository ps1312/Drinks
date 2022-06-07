//
//  DrinksCoreIntegrationTests.swift
//  DrinksCoreIntegrationTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import XCTest
import DrinksCore

class DrinksCoreIntegrationTests: XCTestCase {

    let expectedResult = [
        Drink(id: 15395, name: "1-900-FUK-MEUP", thumb: URL(string: "https://www.thecocktaildb.com/images/media/drink/uxywyw1468877224.jpg")!),
        Drink(id: 15423, name: "110 in the shade", thumb: URL(string: "https://www.thecocktaildb.com/images/media/drink/xxyywq1454511117.jpg")!),
        Drink(id: 14588, name: "151 Florida Bushwacker", thumb: URL(string: "https://www.thecocktaildb.com/images/media/drink/rvwrvv1468877323.jpg")!),
        Drink(id: 15346, name: "155 Belmont", thumb: URL(string: "https://www.thecocktaildb.com/images/media/drink/yqvvqs1475667388.jpg")!),
        Drink(id: 17060, name: "24k nightmare", thumb: URL(string: "https://www.thecocktaildb.com/images/media/drink/yyrwty1468877498.jpg")!),
        Drink(id: 15288, name: "252", thumb: URL(string: "https://www.thecocktaildb.com/images/media/drink/rtpxqw1468877562.jpg")!),
        Drink(id: 13899, name: "3 Wise Men", thumb: URL(string: "https://www.thecocktaildb.com/images/media/drink/wxqpyw1468877677.jpg")!),
        Drink(id: 15300, name: "3-Mile Long Island Iced Tea", thumb: URL(string: "https://www.thecocktaildb.com/images/media/drink/rrtssw1472668972.jpg")!),
        Drink(id: 13581, name: "410 Gone", thumb: URL(string: "https://www.thecocktaildb.com/images/media/drink/xtuyqv1472669026.jpg")!),
    ]

    func testExample() async throws {
        let httpClient = URLSessionHTTPClient()
        let url = URL(string: "https://pssr.dev/drinks.json")!
        let remoteDrinksLoader = RemoteDrinksLoader(url: url, httpClient: httpClient)

        let result = try await remoteDrinksLoader.load()

        for index in 0...8 {
            XCTAssertEqual(result[index], expectedResult[index])
        }
    }


}
