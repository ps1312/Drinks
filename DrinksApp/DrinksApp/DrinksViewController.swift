//
//  ViewController.swift
//  DrinksApp
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import UIKit
import DrinksCore

class DrinksViewController: UITableViewController {
    var drinks = [Drink]()
    var getDrinks: DrinksLoader!
    var getImage: ((URL, @escaping (Result<Data, Error>) -> Void) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Drinks 🥴🍸"

        let refreshControler = UIRefreshControl()
        refreshControl = refreshControler
        refreshControler.beginRefreshing()

        getDrinks { [weak self] result in
            switch (result) {
            case .success(let drinks):
                self?.drinks = drinks
                self?.tableView.reloadData()
            case .failure:
                let errorLabel = UILabel()
                errorLabel.text = "Something went wrong..."
                self?.tableView.backgroundView = errorLabel
            }

            refreshControler.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let drink = drinks[indexPath.row]

        let drinkCell = tableView.dequeueReusableCell(withIdentifier: "DrinkListItem", for: indexPath) as! DrinkListItem
        drinkCell.nameLabel.text = drink.name
        drinkCell.imageLoader = getImage

        drinkCell.configureView(url: drink.thumb)

        return drinkCell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return drinks.count }
}

