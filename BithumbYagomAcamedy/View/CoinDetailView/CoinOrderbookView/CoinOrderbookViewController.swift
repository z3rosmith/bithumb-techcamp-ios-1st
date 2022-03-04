//
//  CoinOrderbookViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import UIKit

final class CoinOrderbookViewController: UIViewController {

    // MARK: - Typealias
    
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, Orderbook>
    
    // MARK: - Section
    
    enum Section: CaseIterable {
        case ask
        case bid
        
        var description: String {
            switch self {
            case .ask:
                return "매도"
            case .bid:
                return "매수"
            }
        }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var coinOrderbookCollectionView: UICollectionView!
    
    // MARK: - Property
    
    private let coinOrderbookDataManager = CoinOrderbookDataManager()
    private var dataSource: DiffableDataSource?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataManager()
        configureCollectionViewDataSource()
        configureCollectionViewLayout()
    }
}

// MARK: - CoinTransaction CollectionView Configure

extension CoinOrderbookViewController {
    private func configureCollectionViewDataSource() {
        typealias CellRegistration = UICollectionView.CellRegistration<CoinOrderbookCollectionViewCell, Orderbook>
        
        let cellNib = UINib(
            nibName: CoinOrderbookCollectionViewCell.identifier,
            bundle: nil
        )
        
        let coinTransacionCellRegistration = CellRegistration(cellNib: cellNib) { cell, _, item in
            cell.update(item)
        }
        
        dataSource = DiffableDataSource(collectionView: coinOrderbookCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: coinTransacionCellRegistration,
                for: indexPath,
                item: item
            )
        }
        
//        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, elementKind, indexPath in
//            var configuration = headerView.defaultContentConfiguration()
//            configuration.text = Section.allCases[indexPath.section].description
//            configuration.textProperties.font = .preferredFont(forTextStyle: .largeTitle)
//            configuration.textProperties.color = .label
//            headerView.contentConfiguration = configuration
//        }
//
//        dataSource?.supplementaryViewProvider = { collectionView, elementKind, indexPath in
//            if elementKind == UICollectionView.elementKindSectionHeader {
//                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
//            } else {
//                return nil
//            }
//        }
    }
    
    private func configureCollectionViewLayout() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
//        configuration.headerMode = .supplementary
        configuration.showsSeparators = false
        coinOrderbookCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

// MARK: - Snapshot

extension CoinOrderbookViewController {
    private func applySnapshot(_ askOrderbooks: [Orderbook], _ bidOrderbooks: [Orderbook]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Orderbook>()
        
        snapshot.appendSections([.ask, .bid])
        snapshot.appendItems(askOrderbooks, toSection: .ask)
        snapshot.appendItems(bidOrderbooks, toSection: .bid)
        
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
}


// MARK: - CoinOrderbook DataManager

extension CoinOrderbookViewController {
    private func configureDataManager() {
        coinOrderbookDataManager.delegate = self
        coinOrderbookDataManager.fetchOrderbook()
    }
}

// MARK: - CoinTransaction DataManager Delegate

extension CoinOrderbookViewController: CoinOrderbookDataManagerDelegate {
    func coinOrderbookDataManager(didChange askOrderbooks: [Orderbook], bidOrderbooks: [Orderbook]) {
        applySnapshot(askOrderbooks, bidOrderbooks)
    }
}
