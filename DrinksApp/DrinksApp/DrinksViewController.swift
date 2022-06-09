//
//  ViewController.swift
//  DrinksApp
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import UIKit
import DrinksCore

class DrinksViewController: UITableViewController {
    var drinksLoader: DrinksLoader?

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            try? await drinksLoader?.load()
        }
    }

}

