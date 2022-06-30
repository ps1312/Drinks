//
//  DrinkListItem.swift
//  DrinksApp
//
//  Created by Paulo Sergio da Silva Rodrigues on 11/06/22.
//

import UIKit
import DrinksCore

public class DrinkListItem: UITableViewCell {
    var url: URL? = nil
    var imageLoader: ((URL, @escaping (Result<Data, Error>) -> Void) -> Void)!
    var displayDrinkDetails: (() -> Void)? = nil

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!

    func configureView(url: URL) {
        self.url = url

        loadImage()
    }

    @IBAction func retry(_ sender: Any) {
        loadImage()
    }

    func loadImage() {
        retryButton.isHidden = true
        loadingIndicator.startAnimating()

        imageLoader(self.url!) { [weak self] result in
            self?.loadingIndicator.stopAnimating()

            switch (result) {
            case .success(let imageData):
                let image = UIImage(data: imageData)
                self?.thumbnailImage.image = image
            case .failure:
                self?.retryButton.isHidden = false
            }
        }
    }
}
