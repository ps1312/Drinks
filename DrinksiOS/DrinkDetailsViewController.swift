//
//  DrinkDetailsViewController.swift
//  DrinksiOS
//
//  Created by Paulo Sergio da Silva Rodrigues on 28/06/22.
//

import Foundation
import UIKit

class DrinkDetailsViewController: UIViewController {
    var drinkId: Int? = nil
    var getDrinkDetail: ((Int, () -> Void) -> Void)? = nil

    var screenCollectionView: UICollectionView! = nil
    var screenDiffableDataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil

    enum Section {
        case main
        case image
        case details
        case ingredients
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureDataSource()

        getDrinkDetail?(drinkId!) {}
    }

    func configureView() {
        let collectionViewLayout = createCollectionViewLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: collectionViewLayout)
        collectionView.allowsSelection = false
        screenCollectionView = collectionView
        view.addSubview(collectionView)
    }

    func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.40), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging

        return UICollectionViewCompositionalLayout(section: section)
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Int> { cell, indexPath, item in
            var viewCell = cell.defaultContentConfiguration()
            viewCell.image = UIImage(systemName: "star")
            viewCell.text = "ingredient: \(item)"

            cell.contentConfiguration = viewCell
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: screenCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        screenDiffableDataSource = dataSource

        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<5))

        screenDiffableDataSource.apply(snapshot, animatingDifferences: true)
    }

}
