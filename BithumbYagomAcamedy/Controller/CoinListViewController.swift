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
    
    @IBOutlet weak private var coinListCollectionView: UICollectionView!
    
    // MARK: - Property
    
    #warning("의견필요 - 네이밍")
    private let coinListController = CoinListDataSource() // 의견 필요... 인스턴스를 생성해야하는데 CoinListDataSource보단 CoinListController가 낫지않을까
    private var dataSource: UICollectionViewDiffableDataSource<Section, CoinListDataSource.Coin>?
    private var coinSortType: CoinSortType = .priceDescending(true) {
        didSet {
            applySnapshot(by: coinSortType)
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        configureCoinListController()
        coinListController.fetchCoinList()
    }
    
    @IBAction func 이름탭(_ sender: Any) {
        coinSortType = .nameDescending(true)
    }
    
    @IBAction func 현재가탭(_ sender: Any) {
        coinSortType = .priceDescending(true)
    }
    
    @IBAction func 변동률탭(_ sender: Any) {
        coinSortType = .changeRateDescending(true)
    }
}

// MARK: - Configuration

extension CoinListViewController {
    func configureCoinListController() {
        coinListController.delegate = self
    }
    
    func configureDataSource() {
        let cellNib = UINib(nibName: "CoinListCollectionViewCell", bundle: nil)
        let coinCellRegistration = UICollectionView.CellRegistration<CoinListCollectionViewCell, CoinListDataSource.Coin>(cellNib: cellNib) { cell, indexPath, item in
            cell.update(item: item)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, CoinListDataSource.Coin>(collectionView: coinListCollectionView) { collectionView, indexPath, item in
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
    func applySnapshot(by sortType: CoinSortType) {
        let allCoinList = coinListController.sortedCoinList(by: sortType)
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, CoinListDataSource.Coin>()
        snapshot.appendSections([.allByKRW])
        snapshot.appendItems(allCoinList, toSection: .allByKRW)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - CoinListDataSourceDelegate

extension CoinListViewController: CoinListDataSourceDelegate {
    func didSetCoinList() {
        applySnapshot(by: coinSortType)
    }
}
