//
//  CoinListViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController

final class CoinListViewController: UIViewController, NetworkFailAlertPresentable {
    
    // MARK: - Nested Type
    
    enum Section: Int {
        case favorite
        case all
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var balloonSpeakView: BallonSpeakView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var coinListMenuStackView: CoinListMenuStackView!
    @IBOutlet private weak var sortButtonStackView: UIStackView!
    @IBOutlet private weak var coinListCollectionView: UICollectionView!
    @IBOutlet private var sortButtons: [SortButton]!
    @IBOutlet private weak var infoButton: UIButton!
    
    // MARK: - Property
    
    private var disposeBag: DisposeBag = .init()
    private lazy var viewModel: CoinListViewModel = .init(
        sortButtons: sortButtons,
        sortButtonTypes: [.popularity, .name, .price, .changeRate]
    )
    private let coinListDataManager: CoinListDataManager = .init()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Coin>?
//    private lazy var activityIndicator: UIActivityIndicatorView = {
//        let indicator = UIActivityIndicatorView()
//        indicator.center = view.center
//        indicator.startAnimating()
//        return indicator
//    }()
    private var excludedAtVisibleCells: UICollectionViewCell?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionViewCell()
        configureCollectionViewLayout()
        configureBalloonSpeakView()
        configureViewBindings()
        configureViewModelBindings()
//        configureDataSource()
//        configureActivityIndicator()
//        coinListDataManager.fetchCoinList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
//        coinListDataManager.fetchCurrentPriceWebSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
//        coinListDataManager.stopFetchCurrentPriceWebSocket()
    }
    
    // MARK: - IBAction
    
    @IBAction func favoriteCoinButtonTapped(_ sender: UIButton) {
        coinListCollectionView.setContentOffset(.zero, animated: false)
    }
    
    @IBAction func allCoinButtonTapped(_ sender: UIButton) {
        scrollToAllSectionHeader()
    }
}

extension CoinListViewController {
    // MARK: - Binding

    private func configureViewModelBindings() {
        // 처음 로딩될 떄
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        firstLoad
            .bind(to: viewModel.input.fetchCoinList)
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .bind(to: viewModel.input.filterCoin)
            .disposed(by: disposeBag)
        
        viewModel.output.coinList
            .bind(to: coinListCollectionView.rx.items(cellIdentifier: CoinListCollectionViewCell.identifier, cellType: CoinListCollectionViewCell.self)) { index, coin, cell in
                cell.update(from: coin)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureViewBindings() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.animateBalloonSpeakView(isHidden: true)
            })
            .disposed(by: disposeBag)
        
        infoButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.animateBalloonSpeakView(isHidden: false)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Helper

extension CoinListViewController {
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
    
    private func animateBalloonSpeakView(isHidden: Bool) {
        UIView.transition(with: balloonSpeakView, duration: 0.5, options: .transitionCrossDissolve) {
            self.balloonSpeakView.isHidden = isHidden
        }
    }
    
//    private func endActivityIndicator() {
//        DispatchQueue.main.async { [weak self] in
//            self?.activityIndicator.stopAnimating()
//            self?.activityIndicator.isHidden = true
//        }
//    }
}

// MARK: - Configuration

extension CoinListViewController {
    private func configureBalloonSpeakView() {
        balloonSpeakView.isHidden = true
    }
    
//    private func configureActivityIndicator() {
//        view.addSubview(activityIndicator)
//    }
    
//    private func configureDataSource() {
//        let cellNib = UINib(nibName: "CoinListCollectionViewCell", bundle: nil)
//        let coinCellRegistration = UICollectionView.CellRegistration<CoinListCollectionViewCell, Coin>(cellNib: cellNib) { cell, indexPath, item in
//            cell.delegate = self
//            cell.update(item: item)
//            cell.toggleFavorite = { [weak self] in
//                self?.coinListDataManager.toggleFavorite(
//                    coinSymbolName: item.symbolName,
//                    isAlreadyFavorite: item.isFavorite
//                )
//                self?.coinListDataManager.sortCoinList(filteredBy: self?.searchBar.text)
//            }
//        }
//        dataSource = UICollectionViewDiffableDataSource<Section, Coin>(collectionView: coinListCollectionView) { collectionView, indexPath, item in
//            return collectionView.dequeueConfiguredReusableCell(using: coinCellRegistration, for: indexPath, item: item)
//        }
//        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
//            var configuration = headerView.defaultContentConfiguration()
//            configuration.text = self?.coinListDataManager.nameOfSectionHeader(index: indexPath.section)
//            configuration.textProperties.font = .preferredFont(forTextStyle: .largeTitle)
//            configuration.textProperties.color = .label
//            headerView.contentConfiguration = configuration
//            headerView.backgroundColor = .white
//        }
//        dataSource?.supplementaryViewProvider = { collectionView, elementKind, indexPath in
//            if elementKind == UICollectionView.elementKindSectionHeader {
//                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
//            } else {
//                return nil
//            }
//        }
//    }
    
    private func registerCollectionViewCell() {
        coinListCollectionView.register(UINib(nibName: "CoinListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CoinListCollectionViewCell.identifier)
    }
    
    private func configureCollectionViewLayout() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
//        configuration.headerMode = .supplementary
//        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
//            guard let item = self?.dataSource?.itemIdentifier(for: indexPath) else {
//                return nil
//            }
//            let favoriteAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
//                self?.coinListDataManager.toggleFavorite(
//                    coinSymbolName: item.symbolName,
//                    isAlreadyFavorite: item.isFavorite
//                )
//                self?.coinListDataManager.sortCoinList(filteredBy: self?.searchBar.text)
//                completion(true)
//            }
//            favoriteAction.backgroundColor = .systemOrange
//            if item.isFavorite {
//                favoriteAction.image = UIImage(systemName: "heart.slash.fill")?.withTintColor(.white)
//            } else {
//                favoriteAction.image = UIImage(systemName: "heart.fill")?.withTintColor(.white)
//            }
//            return UISwipeActionsConfiguration(actions: [favoriteAction])
//        }
        coinListCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
//        coinListCollectionView.delegate = self
        coinListCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func getVisibleCellsForCoinListDataManager() {
        let visibleCellsSymbols = coinListCollectionView
            .visibleCells
            .filter { $0 != excludedAtVisibleCells }
            .compactMap { coinListCollectionView.indexPath(for: $0) }
            .compactMap { dataSource?.itemIdentifier(for: $0)?.symbolName }
        coinListDataManager.visibleCellsSymbols = visibleCellsSymbols
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
        
        DispatchQueue.main.async { [weak self] in
            self?.checkCoinListMenuStackViewUnderLineShouldMove(favoriteCoinListIsEmpty: favoriteCoinList.isEmpty)
            self?.dataSource?.applySnapshot(snapshot, animated: false) {
                self?.getVisibleCellsForCoinListDataManager()
            }
        }
    }
    
    private func checkCoinListMenuStackViewUnderLineShouldMove(favoriteCoinListIsEmpty isEmpty: Bool) {
        if isEmpty {
            coinListMenuStackView.moveUnderLine(index: Section.all.rawValue)
        } else if let oldSnapshot = dataSource?.snapshot(), oldSnapshot.sectionIdentifiers.contains(.favorite) == false {
            coinListMenuStackView.moveUnderLine(index: Section.favorite.rawValue)
        }
    }
}

// MARK: - CoinListDataManagerDelegate

extension CoinListViewController: CoinListDataManagerDelegate {
    func coinListDataManager(didChangeCoinList favoriteCoinList: [Coin], allCoinList: [Coin]) {
        applySnapshot(favoriteCoinList: favoriteCoinList, allCoinList: allCoinList)
//        endActivityIndicator()
    }
    
    func coinListDataManager(didSetCurrentPriceInAllCoinList favoriteCoinList: [Coin], allCoinList: [Coin]) {
        applySnapshot(favoriteCoinList: favoriteCoinList, allCoinList: allCoinList)
    }
    
    func coinListDataManagerDidFetchFail() {
        DispatchQueue.main.async { [weak self] in
            self?.showFetchFailAlert(viewController: self) { _ in
                self?.coinListDataManager.fetchCoinList()
            }
        }
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
        let instantiater = ViewControllerInstantiater()
        
        guard let coinDetailViewController = instantiater.instantiate(
            CoinDetailViewInstantiateInformation()
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
        getVisibleCellsForCoinListDataManager()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        getVisibleCellsForCoinListDataManager()
    }
}

// MARK: - CoinListCollectionViewCellDelegate

extension CoinListViewController: CoinListCollectionViewCellDelegate {
    func coinListCollectionViewCellDelegate(didUserSwipe cell: UICollectionViewListCell, isSwiped: Bool) {
        if isSwiped {
            excludedAtVisibleCells = cell
        } else if cell == excludedAtVisibleCells {
            excludedAtVisibleCells = nil
        }
    }
}
