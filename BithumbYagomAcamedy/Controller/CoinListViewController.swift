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
    @IBOutlet weak var coinListCollectionView: UICollectionView!
    
    // MARK: - Property
    var dataSource: UICollectionViewDiffableDataSource<Section, CoinListDataSource.Coin>!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
    }
}

// MARK: - Configuration
extension CoinListViewController {
    func configureDataSource() {
        let coinCellRegistration = UICollectionView.CellRegistration<CoinListCollectionViewCell, CoinListDataSource.Coin>(cellNib: UINib(nibName: "CoinListCollectionViewCell", bundle: nil)) { cell, indexPath, item in
            cell.nameLabel.text = item.callingName
            cell.symbolPerCurrencyLabel.text = item.symbolName + "/KRW"
            cell.coinPriceLabel.text = "\(item.price)"
            cell.changeRateLabel.text = "+ \(item.changeRate)%"
            cell.changePriceLabel.text = "+ \(item.changePrice)"
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
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
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
        let favoriteCoins = [
            CoinListDataSource.Coin(callingName: "비트코인", symbolName: "BTC", price: 11111101111111, changeRate: 3.3, changePrice: 3333),
            CoinListDataSource.Coin(callingName: "코인", symbolName: "BTC", price: 430, changeRate: 3.3, changePrice: 3333)
        ]
        
        let allCoins = [
            CoinListDataSource.Coin(callingName: "비트코인", symbolName: "BTC", price: 10, changeRate: 3.3, changePrice: 3333),
            CoinListDataSource.Coin(callingName: "코인", symbolName: "BTC", price: 430, changeRate: 3.3, changePrice: 3333),
            CoinListDataSource.Coin(callingName: "ㅋㅋ코인", symbolName: "BTC", price: 11, changeRate: 3.3, changePrice: 3333),
            CoinListDataSource.Coin(callingName: "ㅇㅇ코인", symbolName: "BTC", price: 710, changeRate: 3.3, changePrice: 3333),
            CoinListDataSource.Coin(callingName: "ㅌㅌ코인", symbolName: "BTC", price: 190, changeRate: 3.3, changePrice: 3333),
            CoinListDataSource.Coin(callingName: "ㅎㅎ코인", symbolName: "BTC", price: 100, changeRate: 3.3, changePrice: 3333),
        ]
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, CoinListDataSource.Coin>()
        snapshot.appendSections([.favorite, .allByKRW])
        snapshot.appendItems(favoriteCoins, toSection: .favorite)
        snapshot.appendItems(allCoins, toSection: .allByKRW)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
