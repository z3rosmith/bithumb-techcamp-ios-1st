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
    
    private enum Section {
        case ask
        case bid
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
            cell.priceLabel.text = item.price
            cell.askQuantityLabel.text = item.quantity
        }
        
        dataSource = DiffableDataSource(collectionView: coinOrderbookCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: coinTransacionCellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func configureCollectionViewLayout() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        coinOrderbookCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

// MARK: - Snapshot

extension CoinOrderbookViewController {
    private func applySnapshot(_ orderbook: [Orderbook]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Orderbook>()
        
        snapshot.appendSections([.ask, .bid])
        snapshot.appendItems(orderbook)
        
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
    func coinOrderbookDataManager(didChange orderbook: [Orderbook]) {
        applySnapshot(orderbook)
    }
}
