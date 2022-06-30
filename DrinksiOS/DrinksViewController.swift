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
    var currentDrinkId: Int? = nil
    var getDrinks: DrinksLoader!
    var getImage: ((URL, @escaping (Result<Data, Error>) -> Void) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Drinks 🥴🍸"

        let refreshControler = UIRefreshControl()
        refreshControler.addTarget(self, action: #selector(loadData), for: .valueChanged)
        refreshControl = refreshControler

        loadData()
    }

    @objc private func loadData() {
        tableView.refreshControl?.beginRefreshing()

        getDrinks { result in
            switch (result) {
            case .success(let drinks):
                self.drinks = drinks
                self.tableView.reloadData()
            case .failure:
                let errorLabel = UILabel()
                errorLabel.textAlignment = .center
                errorLabel.text = "Something went wrong..."
                self.tableView.backgroundView = errorLabel
            }

            self.tableView.refreshControl?.endRefreshing()
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bundle = Bundle(for: DrinkDetailsViewController.self)
        let sb = UIStoryboard(name: "Main", bundle: bundle)
        let vc = sb.instantiateViewController(withIdentifier: "DrinkDetailsViewController") as! DrinkDetailsViewController
        vc.drinkId = drinks[indexPath.row].id

        navigationController?.pushViewController(vc, animated: true)
    }
}

