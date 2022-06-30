//
//  DrinksDetailsViewControllerTests.swift
//  DrinksiOSTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 28/06/22.
//

import XCTest
@testable import DrinksiOS

class DrinkDetailsViewControllerTests: XCTestCase {
    func test_init_makeRequestToDrinkDetails() {
        let sut = makeSUT()

        var requestsCount = 0
        sut.getDrinkDetail = { _, _ in requestsCount += 1 }

        sut.loadViewIfNeeded()

        XCTAssertEqual(requestsCount, 1)
    }

    func test_drinkImage_downloadsImage() {
        let sut = makeSUT()

    }

    private func makeSUT() -> DrinkDetailsViewController {
        let bundle = Bundle(for: DrinkDetailsViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let sut = storyboard.instantiateViewController(identifier: "DrinksDetailsViewController") as! DrinkDetailsViewController

        return sut
    }
}
