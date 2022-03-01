//
//  CoinListViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import UIKit

class CoinListViewController: UIViewController {
    
    // MARK: - Nested Type
    
    enum Section: CaseIterable {
        case favorite
        case all
        
        var description: String {
            switch self {
            case .favorite:
                return "관심"
            case .all:
                return "원화"
            }
        }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var coinListCollectionView: UICollectionView!
    
    // MARK: - Property
    
    private let coinListDataManager = CoinListDataManager()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Coin>?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        configureCoinListController()
        coinListDataManager.fetchCoinList()
    }
    
    @IBAction func nameButtonTapped(_ sender: UIButton) {
        if sender.isSelected {
            coinListDataManager.coinSortAction = { $0.callingName > $1.callingName }
        } else {
            coinListDataManager.coinSortAction = { $0.callingName < $1.callingName }
        }
        sender.isSelected.toggle()
    }
    
    @IBAction func priceButtonTapped(_ sender: UIButton) {
        if sender.isSelected {
            coinListDataManager.coinSortAction = {
                let first = $0.currentPrice ?? -Double.greatestFiniteMagnitude
                let second = $1.currentPrice ?? -Double.greatestFiniteMagnitude
                return first > second
            }
        } else {
            coinListDataManager.coinSortAction = {
                let first = $0.currentPrice ?? Double.greatestFiniteMagnitude
                let second = $1.currentPrice ?? Double.greatestFiniteMagnitude
                return first < second
            }
        }
        sender.isSelected.toggle()
    }
    
    @IBAction func changeRateButtonTapped(_ sender: UIButton) {
        if sender.isSelected {
            coinListDataManager.coinSortAction = {
                let first = $0.changeRate ?? -Double.greatestFiniteMagnitude
                let second = $1.changeRate ?? -Double.greatestFiniteMagnitude
                return first > second
            }
        } else {
            coinListDataManager.coinSortAction = {
                let first = $0.changeRate ?? Double.greatestFiniteMagnitude
                let second = $1.changeRate ?? Double.greatestFiniteMagnitude
                return first < second
            }
        }
        sender.isSelected.toggle()
    }
    
    @IBAction func popularityButtonTapped(_ sender: UIButton) {
        if sender.isSelected {
            coinListDataManager.coinSortAction = {
                let first = $0.popularity ?? -Double.greatestFiniteMagnitude
                let second = $1.popularity ?? -Double.greatestFiniteMagnitude
                return first > second
            }
        } else {
            coinListDataManager.coinSortAction = {
                let first = $0.popularity ?? Double.greatestFiniteMagnitude
                let second = $1.popularity ?? Double.greatestFiniteMagnitude
                return first < second
            }
        }
        sender.isSelected.toggle()
    }
}

// MARK: - Configuration

extension CoinListViewController {
    func configureCoinListController() {
        coinListDataManager.delegate = self
    }
    
    func configureDataSource() {
        let cellNib = UINib(nibName: "CoinListCollectionViewCell", bundle: nil)
        let coinCellRegistration = UICollectionView.CellRegistration<CoinListCollectionViewCell, Coin>(cellNib: cellNib) { cell, indexPath, item in
            cell.update(item: item)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Coin>(collectionView: coinListCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: coinCellRegistration, for: indexPath, item: item)
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, elementKind, indexPath in
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = Section.allCases[indexPath.section].description
            configuration.textProperties.font = .preferredFont(forTextStyle: .largeTitle)
            configuration.textProperties.color = .label
            headerView.contentConfiguration = configuration
        }
        dataSource?.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            } else {
                return nil
            }
        }
    }
    
    func configureCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        configuration.headerMode = .supplementary
        coinListCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

// MARK: - Snapshot

extension CoinListViewController {
    func applySnapshot() {
        let allCoinList = coinListDataManager.sortedCoinList()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Coin>()
        snapshot.appendSections([.all])
        snapshot.appendItems(allCoinList, toSection: .all)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - CoinListDataSourceDelegate

extension CoinListViewController: CoinListDataManagerDelegate {
    func coinListDataManagerDidSetCoinSortAction() {
        applySnapshot()
    }
    
    func coinListDataManagerDidFetchCurrentPrice() {
        applySnapshot()
    }
}
