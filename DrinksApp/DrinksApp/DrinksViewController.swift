//
//  ViewController.swift
//  DrinksApp
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import UIKit
import DrinksCore

class DrinksViewController: UITableViewController {
    var getDrinks: (() async throws -> [Drink])?
    var drinks = [Drink]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.startAnimating()
        tableView.backgroundView = loadingIndicator

        Task {
            guard let getDrinks = getDrinks else { return }

            drinks = try await getDrinks()
            tableView.backgroundView = nil
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicStyle", for: indexPath)
        cell.textLabel!.text = drinks[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return drinks.count }
}

