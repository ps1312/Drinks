//
//  DrinkDetailsViewController.swift
//  DrinksiOS
//
//  Created by Paulo Sergio da Silva Rodrigues on 28/06/22.
//

import Foundation
import UIKit
import DrinksCore

class DrinkDetailsViewController: UIViewController {
    static let headerReuseIdentifier = "section-header-element-kind"

    var drinkId: Int? = nil
    var getDrinkDetail: ((Int, () -> Void) -> Void)? = nil

    var screenCollectionView: UICollectionView! = nil
    var screenDiffableDataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil

    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureDataSource()

        getDrinkDetail?(drinkId!) {}
    }

    func configureView() {
        let collectionView = createCollectionView()
        screenCollectionView = collectionView

        view.addSubview(collectionView)
    }

    func createCollectionView() -> UICollectionView {
        let collectionViewLayout = createCollectionViewLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: collectionViewLayout)
        collectionView.allowsSelection = false

        return collectionView
    }

    func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.40), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .estimated(100))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: DrinkDetailsViewController.headerReuseIdentifier, alignment: .top)

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging

        return UICollectionViewCompositionalLayout(section: section)
    }

    func configureDataSource() {
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <DrinkDetailsSupplementaryView>(elementKind: DrinkDetailsViewController.headerReuseIdentifier) {
            (supplementaryView, string, indexPath) in
        }

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Int> { cell, indexPath, item in
            var viewCell = cell.defaultContentConfiguration()
            viewCell.image = UIImage(systemName: "star")
            viewCell.text = "ingredient: \(item)"

            cell.contentConfiguration = viewCell
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: screenCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.screenCollectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }

        screenDiffableDataSource = dataSource

        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<5))

        screenDiffableDataSource.apply(snapshot, animatingDifferences: true)
    }

}

class DrinkDetailsSupplementaryView: UICollectionReusableView {
    let image = UIImage()
    let name = UILabel()
    let category = UILabel()
    let glass = UILabel()
    let instructionsTitle = UILabel()
    let instructions = UILabel()

    var drink: Drink! = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func configureView() {
        name.text = "drink name"
        name.translatesAutoresizingMaskIntoConstraints = false

        addSubview(name)

        category.text = "drink category"
        category.translatesAutoresizingMaskIntoConstraints = false
        glass.text = "drink glass"
        glass.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = UIStackView()
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        subtitle.addSubview(category)
        subtitle.addSubview(glass)

        addSubview(subtitle)

        instructionsTitle.text = "Instructions:"
        instructionsTitle.translatesAutoresizingMaskIntoConstraints = false

        instructions.text = "Drink instructions as follows"
        instructions.translatesAutoresizingMaskIntoConstraints = false

        let instructionsView = UIStackView()
        instructionsView.translatesAutoresizingMaskIntoConstraints = false
        instructionsView.addSubview(instructionsTitle)
        instructionsView.addSubview(instructions)

        addSubview(instructionsView)

        let insets = CGFloat(10)
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo: topAnchor),
            name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets),
            subtitle.topAnchor.constraint(equalTo: topAnchor, constant: insets * 3),
            subtitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: trailingAnchor),
            category.leadingAnchor.constraint(equalTo: subtitle.leadingAnchor, constant: insets),
            glass.trailingAnchor.constraint(equalTo: subtitle.trailingAnchor, constant: -insets),
            instructionsView.leadingAnchor.constraint(equalTo: subtitle.leadingAnchor, constant: insets),
            instructionsView.topAnchor.constraint(equalTo: subtitle.topAnchor, constant: insets * 3)
        ])
    }
}
