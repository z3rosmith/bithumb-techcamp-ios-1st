//
//  CoinOrderbookViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import UIKit

final class CoinOrderbookViewController: UIViewController, PageViewControllerable, NetworkFailAlertPresentable {
    
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
    @IBOutlet private weak var totalAsksQuantityLabel: UILabel!
    @IBOutlet private weak var totalBidsQuantityLabel: UILabel!
    
    // MARK: - Property
    
    var completion: (() -> Void)?
    private var coinOrderbookDataManager: CoinOrderbookDataManager?
    private var dataSource: DiffableDataSource?
    private var isFirstScrollCenter: Bool = false
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        completion?()
        configureCollectionViewDataSource()
        configureCollectionViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToCollectionViewCenter()
    }
    
    func configureDataManager(coin: Coin) {
        coinOrderbookDataManager = CoinOrderbookDataManager(symbol: coin.symbolName)
        coinOrderbookDataManager?.delegate = self
        coinOrderbookDataManager?.fetchOrderbook()
        coinOrderbookDataManager?.fetchOrderbookWebSocket()
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
    }
    
    private func configureCollectionViewLayout() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        coinOrderbookCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    private func scrollToCollectionViewCenter() {
        let centerY = coinOrderbookCollectionView.contentSize.height / 2 - coinOrderbookCollectionView.frame.height / 2
        
        coinOrderbookCollectionView.setContentOffset(CGPoint(x: 0, y: centerY), animated: false)
    }
}

// MARK: - Snapshot

extension CoinOrderbookViewController {
    private func applySnapshot(_ askOrderbooks: [Orderbook], _ bidOrderbooks: [Orderbook]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Orderbook>()
        
        snapshot.appendSections([.ask, .bid])
        snapshot.appendItems(askOrderbooks, toSection: .ask)
        snapshot.appendItems(bidOrderbooks, toSection: .bid)
        
        DispatchQueue.main.async { [weak self] in
            self?.dataSource?.apply(snapshot, animatingDifferences: false) {
                if askOrderbooks.count + bidOrderbooks.count == 60,
                   self?.isFirstScrollCenter == false {
                    self?.coinOrderbookCollectionView.layoutIfNeeded()
                    self?.isFirstScrollCenter = true
                    self?.scrollToCollectionViewCenter()
                }
            }
        }
    }
}

// MARK: - CoinTransaction DataManager Delegate

extension CoinOrderbookViewController: CoinOrderbookDataManagerDelegate {
    func coinOrderbookDataManager(
        didCalculate totalQuantity: String,
        type: OrderbookType
    ) {
        DispatchQueue.main.async { [weak self] in
            if type == .ask {
                self?.totalAsksQuantityLabel.text = totalQuantity
            } else {
                self?.totalBidsQuantityLabel.text = totalQuantity
            }
        }
    }
    
    func coinOrderbookDataManager(
        didChange askOrderbooks: [Orderbook],
        and bidOrderbooks: [Orderbook]
    ) {
        applySnapshot(askOrderbooks, bidOrderbooks)
    }
    
    func coinOrderbookDataManagerDidFetchFail() {
        DispatchQueue.main.async { [weak self] in
            self?.showFetchFailAlert(viewController: self) { _ in
                self?.coinOrderbookDataManager?.fetchOrderbook()
            }
        }
    }
}
