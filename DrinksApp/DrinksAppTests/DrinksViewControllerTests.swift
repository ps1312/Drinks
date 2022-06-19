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
        let drink1Image = UIImage.make(withColor: .green).pngData()!
        let drink2 = Drink(id: 1, name: "name 1", thumb: URL(string: "https://url1.com")!)
        let drink2Image = UIImage.make(withColor: .yellow).pngData()!
        let expectedDrinks = [drink1, drink2]
        let expectedImages = [drink1Image, drink2Image]

        sut.getDrinks = { $0(.success(expectedDrinks)) }

        sut.loadViewIfNeeded()

        var imagesRequests = [URL]()
        sut.getImage = { url, completion in
            imagesRequests.append(url)
            completion(.success(expectedImages[imagesRequests.count - 1]))
        }

        XCTAssertEqual(sut.numberOfDrinks(), expectedDrinks.count)

        for i in 0...expectedDrinks.count - 1 {
            let drinkCell = sut.renderDrinkCell(atRow: i)
            XCTAssertEqual(drinkCell.name(), expectedDrinks[i].name)
            XCTAssertEqual(drinkCell.imageData(), expectedImages[i])
        }

        XCTAssertEqual(imagesRequests, [drink1.thumb, drink2.thumb])
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

    func renderDrinkCell(atRow row: Int) -> DrinkListItem {
        return tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! DrinkListItem
    }

    func name(atRow row: Int) -> String {
        let cell = tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as? DrinkListItem
        return cell?.nameLabel.text ?? ""
    }

    func image(atRow row: Int) -> UIImage? {
        let cell = tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as? DrinkListItem
        return cell?.thumbnailImage.image
    }

    private var drinksSection: Int { 0 }
}

private extension DrinkListItem {
    func name() -> String? {
        return nameLabel.text
    }

    func imageData() -> Data? {
        return thumbnailImage.image?.pngData()
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

