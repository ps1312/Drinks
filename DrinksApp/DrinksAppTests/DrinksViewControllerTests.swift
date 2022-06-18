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

    func test_viewDidLoad_getDrinks() {
        let sut = makeSUT()

        var count = 0
        sut.getDrinks = { _ in count += 1 }

        sut.loadViewIfNeeded()

        XCTAssertEqual(count, 1)
    }

    func test_viewDidLoad_displaysLoadingWhileGettingDrinks() {
        let sut = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isLoading())
    }

    func test_viewDidLoad_displaysAvailableDrinksAndDownloadsImages() {
        let sut = makeSUT()

        let drink1 = Drink(id: 0, name: "name 0", thumb: URL(string: "https://url0.com")!)
        let drink2 = Drink(id: 1, name: "name 1", thumb: URL(string: "https://ur1.com")!)
        let expectedDrinks = [drink1, drink2]

        sut.getDrinks = { completion in completion(.success(expectedDrinks)) }

        var imagesRequests = [URL]()
        sut.getImage = { url, _ in imagesRequests.append(url) }

        sut.loadViewIfNeeded()

        XCTAssertFalse(sut.isLoading())

        for i in 0...expectedDrinks.count - 1 {
            XCTAssertEqual(sut.name(atRow: i), expectedDrinks[i].name)
        }
        XCTAssertEqual(imagesRequests, [drink1.thumb, drink2.thumb])
        XCTAssertEqual(sut.numberOfDrinks(), expectedDrinks.count)
    }

    private func makeSUT() -> DrinksViewController {
        let bundle = Bundle(for: DrinksViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let sut = navController.topViewController as! DrinksViewController

        sut.getDrinks = { _ in }
        sut.getImage = { _, _ in }

        return sut
    }
}

private extension DrinksViewController {
    func numberOfDrinks() -> Int { tableView.numberOfRows(inSection: drinksSection) }

    func isLoading() -> Bool {
        guard let refreshControl = try? XCTUnwrap(tableView.refreshControl, "View is missing UIRefreshControl") else { return false }
        return refreshControl.isRefreshing
    }

    func name(atRow row: Int) -> String {
        let cell = tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as? DrinkListItem
        return cell?.nameLabel.text ?? ""
    }

    private var drinksSection: Int { 0 }
}
