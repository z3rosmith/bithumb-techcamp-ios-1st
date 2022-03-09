//
//  CoinListViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import UIKit

final class CoinListViewController: UIViewController {
    
    // MARK: - Nested Type
    
    enum Section: Int {
        case favorite
        case all
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var coinListMenuStackView: CoinListMenuStackView!
    @IBOutlet private weak var sortButtonStackView: UIStackView!
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
        configureButton()
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
    
    @IBAction func favoriteCoinButtonTapped(_ sender: UIButton) {
//        coinListMenuStackView.moveUnderLine(index: Section.favorite.rawValue)
        coinListCollectionView.setContentOffset(.zero, animated: false)
    }
    
    @IBAction func allCoinButtonTapped(_ sender: UIButton) {
//        coinListMenuStackView.moveUnderLine(index: Section.all.rawValue)
        scrollToAllSectionHeader()
    }
    
    @IBAction func popularityButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        coinListDataManager.sortCoinList(
            by: .popularity(isDescend: sender.isSelected),
            filteredBy: searchBar.text
        )
        restoreSortButtons(exclude: sender)
    }
    
    @IBAction func nameButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        coinListDataManager.sortCoinList(
            by: .name(isDescend: sender.isSelected),
            filteredBy: searchBar.text
        )
        restoreSortButtons(exclude: sender)
    }
    
    @IBAction func priceButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        coinListDataManager.sortCoinList(
            by: .price(isDescend: sender.isSelected),
            filteredBy: searchBar.text
        )
        restoreSortButtons(exclude: sender)
    }
    
    @IBAction func changeRateButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        coinListDataManager.sortCoinList(
            by: .changeRate(isDescend: sender.isSelected),
            filteredBy: searchBar.text
        )
        restoreSortButtons(exclude: sender)
    }
    
    // MARK: - Helper
    
    private func scrollToAllSectionHeader() {
        if let headerAttributes = coinListCollectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: Section.all.rawValue)
            ) {
            coinListCollectionView.scrollToItem(
                at: IndexPath(item: 0, section: Section.all.rawValue),
                at: .top,
                animated: false
            )
            coinListCollectionView.layoutIfNeeded()
            let currentContentOffsetY = coinListCollectionView.contentOffset.y
            let point = CGPoint(x: 0, y: currentContentOffsetY - headerAttributes.frame.height + 1)
            coinListCollectionView.setContentOffset(point, animated: false)
        }
    }
    
    private func restoreSortButtons(exclude button: UIButton) {
        sortButtonStackView
            .subviews
            .compactMap { $0 as? UIButton }
            .filter { $0 != button }
            .forEach {
                $0.isSelected = false
            }
    }
}

// MARK: - Configuration

extension CoinListViewController {
    private func configureCoinListController() {
        coinListDataManager.delegate = self
    }
    
    private func configureButton() {
        if let sortByPopularityButton = sortButtonStackView.subviews.first as? UIButton {
            sortByPopularityButton.isSelected = true
        }
    }
    
    private func configureDataSource() {
        let cellNib = UINib(nibName: "CoinListCollectionViewCell", bundle: nil)
        let coinCellRegistration = UICollectionView.CellRegistration<CoinListCollectionViewCell, Coin>(cellNib: cellNib) { cell, indexPath, item in
            cell.update(item: item)
            cell.toggleFavorite = { [weak self] in
                self?.coinListDataManager.toggleFavorite(
                    coinSymbolName: item.symbolName,
                    isAlreadyFavorite: item.isFavorite
                )
                self?.coinListDataManager.sortCoinList(filteredBy: self?.searchBar.text)
            }
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Coin>(collectionView: coinListCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: coinCellRegistration, for: indexPath, item: item)
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = self?.coinListDataManager.nameOfSectionHeader(index: indexPath.section)
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
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.headerMode = .supplementary
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let item = self?.dataSource?.itemIdentifier(for: indexPath) else {
                return nil
            }
            let favoriteAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                self?.coinListDataManager.toggleFavorite(
                    coinSymbolName: item.symbolName,
                    isAlreadyFavorite: item.isFavorite
                )
                self?.coinListDataManager.sortCoinList(filteredBy: self?.searchBar.text)
                completion(true)
            }
            favoriteAction.backgroundColor = .systemOrange
            if item.isFavorite {
                favoriteAction.image = UIImage(systemName: "heart.slash.fill")?.withTintColor(.white)
            } else {
                favoriteAction.image = UIImage(systemName: "heart.fill")?.withTintColor(.white)
            }
            return UISwipeActionsConfiguration(actions: [favoriteAction])
        }
        coinListCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        coinListCollectionView.delegate = self
        coinListCollectionView.keyboardDismissMode = .onDrag
    }
}

// MARK: - Snapshot

extension CoinListViewController {
    func applySnapshot(favoriteCoinList: [Coin], allCoinList: [Coin]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Coin>()
        if favoriteCoinList.isEmpty == false {
            snapshot.appendSections([.favorite])
            snapshot.appendItems(favoriteCoinList, toSection: .favorite)
        }
        if allCoinList.isEmpty == false {
            snapshot.appendSections([.all])
            snapshot.appendItems(allCoinList, toSection: .all)
        }
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
}

// MARK: - CoinListDataManagerDelegate

extension CoinListViewController: CoinListDataManagerDelegate {
    func coinListDataManager(didChangeCoinList favoriteCoinList: [Coin], allCoinList: [Coin]) {
        applySnapshot(favoriteCoinList: favoriteCoinList, allCoinList: allCoinList)
    }
    
    func coinListDataManager(didToggleFavorite favoriteCoinList: [Coin], allCoinList: [Coin]) {
        applySnapshot(favoriteCoinList: favoriteCoinList, allCoinList: allCoinList)
    }
    
    func coinListDataManager(didSetCurrentPriceInAllCoinList favoriteCoinList: [Coin], allCoinList: [Coin]) {
        applySnapshot(favoriteCoinList: favoriteCoinList, allCoinList: allCoinList)
    }
}

// MARK: - UICollectionViewDelegate

extension CoinListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let headerAttributes = coinListCollectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: Section.all.rawValue)
           ),
           let firstCellOfAllSection = coinListCollectionView.cellForItem(at: IndexPath(item: 0, section: Section.all.rawValue)) {
            let allSectionHeaderHeight = headerAttributes.frame.height
            let allSectionHeaderOrigin = CGPoint(
                x: firstCellOfAllSection.frame.origin.x,
                y: firstCellOfAllSection.frame.origin.y - allSectionHeaderHeight + 1
            )
            if coinListCollectionView.contentOffset.y >= allSectionHeaderOrigin.y - 1 {
                coinListMenuStackView.moveUnderLine(index: Section.all.rawValue)
            } else {
                coinListMenuStackView.moveUnderLine(index: Section.favorite.rawValue)
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension CoinListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        coinListDataManager.filterCoinList(by: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
