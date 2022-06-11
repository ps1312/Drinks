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

    func testDisplayEachDrinkOnList() {
        let exp = XCTestExpectation(description: "Wait for getDrinks to be called...")
        let drinks = [
            Drink(id: 0, name: "name 0", thumb: URL(string: "https://image0.com")!),
            Drink(id: 1, name: "name 1", thumb: URL(string: "https://image1.com")!),
            Drink(id: 2, name: "name 2", thumb: URL(string: "https://image2.com")!),
        ]

        let sut = makeSUT()

        sut.getDrinks = {
            exp.fulfill()
            return drinks
        }

        sut.loadViewIfNeeded()

        let loadingIndicator = try! XCTUnwrap(sut.tableView.backgroundView as? UIActivityIndicatorView)
        XCTAssertTrue(loadingIndicator.isAnimating)

        wait(for: [exp], timeout: 0.01)

        for i in 0...drinks.count - 1 {
            let cell = try! XCTUnwrap(sut.tableView.cellForRow(at: IndexPath(row: i, section: 0)))
            XCTAssertEqual(cell.textLabel!.text, drinks[i].name)
        }
    }

    private func makeSUT() -> DrinksViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(withIdentifier: "DrinksViewController") as! DrinksViewController

        return sut
    }

}
