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
    var getDrinks: DrinksLoader?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Drinks 😁🍸"

        let refreshControler = UIRefreshControl()
        refreshControl = refreshControler
        refreshControler.beginRefreshing()

        getDrinks? { [weak self] items in
            self?.drinks = try! items.get()
            self?.tableView.reloadData()
            refreshControler.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let drink = drinks[indexPath.row]
        let drinkCell = tableView.dequeueReusableCell(withIdentifier: "DrinkListItem", for: indexPath) as! DrinkListItem
        drinkCell.nameLabel.text = drink.name
        return drinkCell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return drinks.count }
}

