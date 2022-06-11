//
//  ViewController.swift
//  DrinksApp
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import UIKit
import DrinksCore

let SCREEN_TITLE = "Drinks 🍸"

class DrinksViewController: UITableViewController {
    var drinks = [Drink]()
    var getDrinks: (() async throws -> [Drink])!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = SCREEN_TITLE
        
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.startAnimating()
        tableView.backgroundView = loadingIndicator

        Task {
            drinks = try await getDrinks()
            tableView.backgroundView = nil
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let drink = drinks[indexPath.row]
        let drinkCell = tableView.dequeueReusableCell(withIdentifier: "DrinkListItem", for: indexPath) as! DrinkListItem
        drinkCell.nameLabel.text = drink.name
        drinkCell.thumbnailImage.image = UIImage.imageWithColor(color: .cyan, size: CGSize(width: 200, height: 200))
        return drinkCell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return drinks.count }
}

extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
