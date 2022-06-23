//
//  DrinksAppTests.swift
//  DrinksAppTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import XCTest
import DrinksCore
@testable import DrinksiOS

class DrinksViewControllerTests: XCTestCase {

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

    func test_viewDidLoad_displaysAnErrorMessageOnFailure() {
        let sut = makeSUT()
        sut.getDrinks = { completion in completion(.failure(anyError)) }

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.errorView()?.text, "Something went wrong...")
    }

    func test_pullToRefresh_reloadsDrinks() {
        let sut = makeSUT()

        var count = 0
        sut.getDrinks = { _ in count += 1 }

        sut.loadViewIfNeeded()

        sut.simulatePullToRefresh()

        XCTAssertEqual(count, 2)
    }

    func test_viewDidLoad_displaysAvailableDrinksAndDownloadsImages() {
        let sut = makeSUT()

        let (drink1, drink1Image) = makeFakeDrink(id: 1, url: URL(string: "https://www.image-1.com")!)
        let (drink2, drink2Image) = makeFakeDrink(id: 2, url: URL(string: "https://www.image-2.com")!)
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
            let drinkCell = sut.displayCell(atRow: i)

            XCTAssertFalse(drinkCell.isRetryButtonVisible())
            XCTAssertEqual(drinkCell.name(), expectedDrinks[i].name)
            XCTAssertEqual(drinkCell.image(), expectedImages[i])
        }

        XCTAssertEqual(imagesRequests, [drink1.thumb, drink2.thumb])
    }

    func test_drinkCellImage_displaySpinnerWhileLoading() {
        let sut = makeSUT()
        let (drink,_) = makeFakeDrink()
        sut.getDrinks = { completion in completion(.success([drink])) }

        sut.loadViewIfNeeded()

        let drinkCell = sut.displayCell(atRow: 0)

        XCTAssertFalse(drinkCell.isLoadingHidden())
        XCTAssertTrue(drinkCell.isloadingAnimating())
    }

    func test_drinkCellImage_allowRetryOnLoadFailure() {
        let sut = makeSUT()
        let (drink,_) = makeFakeDrink()
        sut.getDrinks = { completion in completion(.success([drink])) }

        var imageLoadCount = 0
        sut.getImage = { _, completion in
            imageLoadCount += 1
            completion(.failure(anyError))
        }

        sut.loadViewIfNeeded()

        let drinkCell = sut.displayCell(atRow: 0)
        XCTAssertTrue(drinkCell.isRetryButtonVisible())

        drinkCell.retryButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(imageLoadCount, 2)
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

    private func makeFakeDrink(id: Int = 0, url: URL = anyURL) -> (Drink, Data) {
        let drink = Drink(id: id, name: "name \(id)", thumb: url)
        let drinkImage = UIImage.make(withColor: .green).pngData()!
        return (drink, drinkImage)
    }
}

private extension DrinksViewController {
    func numberOfDrinks() -> Int { tableView.numberOfRows(inSection: drinksSection) }

    func isLoading() -> Bool {
        guard let refreshControl = try? XCTUnwrap(tableView.refreshControl, "View is missing UIRefreshControl") else { return false }
        return refreshControl.isRefreshing
    }

    func errorView() -> UILabel? {
        guard let errorView = try? XCTUnwrap(tableView.backgroundView as? UILabel, "Tableview background view is missing an error state") else { return nil }
        return errorView
    }

    func displayCell(atRow row: Int) -> DrinkListItem {
        return tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! DrinkListItem
    }

    func simulatePullToRefresh() {
        tableView.refreshControl?.sendActions(for: .valueChanged)
    }

    private var drinksSection: Int { 0 }
}

private extension DrinkListItem {
    func name() -> String? {
        return nameLabel.text
    }

    func isRetryButtonVisible() -> Bool {
        return !retryButton!.isHidden
    }

    func image() -> Data? {
        return thumbnailImage.image?.pngData()
    }

    func isLoadingHidden() -> Bool {
        return loadingIndicator!.isHidden
    }

    func isloadingAnimating() -> Bool {
        return loadingIndicator!.isAnimating
    }
}

private extension UIImage {
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
