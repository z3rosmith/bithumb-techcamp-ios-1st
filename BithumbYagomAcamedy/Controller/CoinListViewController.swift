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
        case allByKRW
        
        var description: String {
            switch self {
            case .favorite:
                return "관심"
            case .allByKRW:
                return "원화"
            }
        }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var coinListCollectionView: UICollectionView!
    
    // MARK: - Property
    
    private let coinListDataManager = CoinListDataManager()
    private var dataSource: UICollectionViewDiffableDataSource<Section, CoinListDataManager.Coin>?
    private var coinSortAction: CoinSortAction? {
        didSet {
            guard let coinSortAction = coinSortAction else { return }
            applySnapshot(by: coinSortAction)
        }
    }
    
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
            coinSortAction = { $0.callingName > $1.callingName }
        } else {
            coinSortAction = { $0.callingName < $1.callingName }
        }
        sender.isSelected.toggle()
    }
    
    @IBAction func priceButtonTapped(_ sender: UIButton) {
        if sender.isSelected {
            coinSortAction = { $0.currentPrice > $1.currentPrice }
        } else {
            coinSortAction = { $0.currentPrice < $1.currentPrice }
        }
        sender.isSelected.toggle()
    }
    
    @IBAction func changeRateButtonTapped(_ sender: UIButton) {
        if sender.isSelected {
            coinSortAction = { $0.changeRate > $1.changeRate }
        } else {
            coinSortAction = { $0.changeRate < $1.changeRate }
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
        let coinCellRegistration = UICollectionView.CellRegistration<CoinListCollectionViewCell, CoinListDataManager.Coin>(cellNib: cellNib) { cell, indexPath, item in
            cell.update(item: item)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, CoinListDataManager.Coin>(collectionView: coinListCollectionView) { collectionView, indexPath, item in
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
    func applySnapshot(by areInIncreasingOrder: CoinSortAction) {
        let allCoinList = coinListDataManager.sortedCoinList(by: areInIncreasingOrder)
        var snapshot = NSDiffableDataSourceSnapshot<Section, CoinListDataManager.Coin>()
        snapshot.appendSections([.allByKRW])
        snapshot.appendItems(allCoinList, toSection: .allByKRW)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - CoinListDataSourceDelegate

extension CoinListViewController: CoinListDataManagerDelegate {
    func coinListDataManagerDidSetCoinList() {
        if let coinSortAction = coinSortAction {
            applySnapshot(by: coinSortAction)
        } else {
            applySnapshot { $0.currentPrice > $1.currentPrice }
        }
    }
}
