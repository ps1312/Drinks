//
//  DrinkListItem.swift
//  DrinksApp
//
//  Created by Paulo Sergio da Silva Rodrigues on 11/06/22.
//

import UIKit
import DrinksCore

class DrinkListItem: UITableViewCell {
    var imageLoader: ((URL, @escaping (Result<Data, Error>) -> Void) -> Void)!

    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    func configureView(url: URL) {
        imageLoader(url) { [weak self] result in
            switch (result) {
            case .success(let imageData):
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)
                    self?.thumbnailImage.image = image
                }
            default:
                break
            }
        }
    }
}
