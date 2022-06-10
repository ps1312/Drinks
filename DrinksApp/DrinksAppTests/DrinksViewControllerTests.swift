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

    func testMakeDrinksRequestOnViewDidLoad() {
        let exp = XCTestExpectation(description: "Wait for getDrinks to be called...")

        let sut = makeSUT()

        sut.getDrinks = {
            exp.fulfill()
            return []
        }

        sut.loadViewIfNeeded()

        wait(for: [exp], timeout: 0.01)
    }

    func testDisplayLoadingWhileFetchingDrinks() throws {
        let exp = XCTestExpectation(description: "Wait for getDrinks to be called...")

        let sut = makeSUT()

        sut.getDrinks = {
            exp.fulfill()
            return []
        }

        sut.loadViewIfNeeded()

        let loadingIndicator = try? XCTUnwrap(sut.tableView.backgroundView as? UIActivityIndicatorView)
        XCTAssertTrue(loadingIndicator!.isAnimating)

        wait(for: [exp], timeout: 0.01)

        XCTAssertNil(sut.tableView.backgroundView)

    }

    private func makeSUT() -> DrinksViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(withIdentifier: "DrinksViewController") as! DrinksViewController

        return sut
    }

}
