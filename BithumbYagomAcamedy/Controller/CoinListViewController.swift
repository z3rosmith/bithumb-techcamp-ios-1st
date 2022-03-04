//
//  CoinListViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import UIKit

final class CoinListViewController: UIViewController {
    
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
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var coinListCollectionView: UICollectionView!
    
    // MARK: - Property
    
    private let coinListDataManager = CoinListDataManager()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Coin>?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureCollectionView()
        configureDataSource()
        configureCoinListController()
        coinListDataManager.fetchCoinList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - IBAction
    
    @IBAction func nameButtonTapped(_ sender: UIButton) {
        coinListDataManager.sortCoinList(what: .sortAll, by: .name(isDescend: sender.isSelected), filteredBy: searchBar.text)
        sender.isSelected.toggle()
    }
    
    @IBAction func priceButtonTapped(_ sender: UIButton) {
        coinListDataManager.sortCoinList(what: .sortAll, by: .price(isDescend: sender.isSelected), filteredBy: searchBar.text)
        sender.isSelected.toggle()
    }
    
    @IBAction func changeRateButtonTapped(_ sender: UIButton) {
        coinListDataManager.sortCoinList(what: .sortAll, by: .changeRate(isDescend: sender.isSelected), filteredBy: searchBar.text)
        sender.isSelected.toggle()
    }
    
    @IBAction func popularityButtonTapped(_ sender: UIButton) {
        coinListDataManager.sortCoinList(what: .sortAll, by: .popularity(isDescend: sender.isSelected), filteredBy: searchBar.text)
        sender.isSelected.toggle()
    }
}

// MARK: - Configuration

extension CoinListViewController {
    private func configureCoinListController() {
        coinListDataManager.delegate = self
    }
    
    private func configureDataSource() {
        let cellNib = UINib(nibName: "CoinListCollectionViewCell", bundle: nil)
        let coinCellRegistration = UICollectionView.CellRegistration<CoinListCollectionViewCell, Coin>(cellNib: cellNib) { cell, indexPath, item in
            cell.update(item: item)
            cell.toggleFavorite = { [weak self] in
                self?.coinListDataManager.toggleFavorite(
                    coinCallingName: item.callingName,
                    isAlreadyFavorite: item.isFavorite,
                    filteredBy: self?.searchBar.text
                )
            }
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
    
    private func configureSearchBar() {
        searchBar.delegate = self
    }
    
    private func configureCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        configuration.headerMode = .supplementary
        coinListCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        coinListCollectionView.delegate = self
    }
}

// MARK: - Snapshot

extension CoinListViewController {
    func applySnapshot(favoriteCoinList: [Coin], allCoinList: [Coin]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Coin>()
        snapshot.appendSections([.favorite, .all])
        snapshot.appendItems(favoriteCoinList, toSection: .favorite)
        snapshot.appendItems(allCoinList, toSection: .all)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - CoinListDataSourceDelegate

extension CoinListViewController: CoinListDataManagerDelegate {
    func coinListDataManager(didChangeCoinList favoriteCoinList: [Coin], allCoinList: [Coin]) {
        applySnapshot(favoriteCoinList: favoriteCoinList, allCoinList: allCoinList)
    }
}

extension CoinListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let coin = dataSource?.itemIdentifier(for: indexPath)
        
        let coinDetailStoryBoard = UIStoryboard(name: "CoinDetail", bundle: nil)
        guard let coinDetailViewController = coinDetailStoryBoard.instantiateViewController(
            withIdentifier: "CoinDetailViewController"
        ) as? CoinDetailViewController else {
            return
        }
        coinDetailViewController.coin = coin
        
        navigationController?.show(coinDetailViewController, sender: nil)
    }
}

// MARK: - UISearchBarDelegate

extension CoinListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        coinListDataManager.filterCoinList(by: searchText)
    }
}
