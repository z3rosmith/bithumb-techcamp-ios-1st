//
//  CoinTransactionViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/02.
//

import UIKit

final class CoinTransactionViewController: UIViewController, PageViewControllerable, NetworkFailAlertPresentable {
        
    // MARK: - Typealias
    
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, Transaction>
    
    // MARK: - Section
    
    private enum Section {
        case main
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var coinTransactionCollectionView: UICollectionView!
    @IBOutlet private weak var coinQuantityLabel: UILabel!
    
    // MARK: - Property
    var completion: (() -> Void)?
    private var coinTransactionDataManager: CoinTransactionDataManager?
    private var dataSource: DiffableDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        completion?()
        configureCollectionViewDataSource()
        configureCollectionViewLayout()
    }
    
    private func configureQuantityLabel(coinSymbol: String) {
        coinQuantityLabel.text = "체결량(\(coinSymbol))"
    }
    
    func configureDataManager(coin: Coin) {
        coinTransactionDataManager = CoinTransactionDataManager(symbol: coin.symbolName)
        coinTransactionDataManager?.delegate = self
        coinTransactionDataManager?.fetchTransaction()
        coinTransactionDataManager?.fetchTransactionWebSocket()
        configureQuantityLabel(coinSymbol: coin.symbolName)
    }
}

// MARK: - CoinTransaction CollectionView Configure

extension CoinTransactionViewController {
    private func configureCollectionViewDataSource() {
        typealias CellRegistration = UICollectionView.CellRegistration<CoinTransactionCollectionViewCell, Transaction>
        
        let cellNib = UINib(
            nibName: CoinTransactionCollectionViewCell.identifier,
            bundle: nil
        )
        
        let coinTransacionCellRegistration = CellRegistration(cellNib: cellNib) { cell, _, item in
            cell.update(item)
        }
        
        dataSource = DiffableDataSource(collectionView: coinTransactionCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: coinTransacionCellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func configureCollectionViewLayout() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        coinTransactionCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

// MARK: - Snapshot

extension CoinTransactionViewController {
    private func applySnapshot(_ transactions: [Transaction]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Transaction>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(transactions)
        
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
}

// MARK: - CoinTransaction DataManager Delegate

extension CoinTransactionViewController: CoinTransactionDataManagerDelegate {
    func coinTransactionDataManager(didChange transactions: [Transaction]) {
        applySnapshot(transactions)
    }
    
    func coinTransactionDataManagerDidFetchFail() {
        DispatchQueue.main.async { [weak self] in
            self?.showFetchFailAlert(viewController: self) { _ in
                self?.coinTransactionDataManager?.fetchTransaction()
            }
        }
    }
}
