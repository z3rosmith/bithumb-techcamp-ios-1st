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
//    private var dataSource: UICollectionViewDiffableDataSource<CoinListViewModel.Section, ViewCoin>?
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
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
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in }
        
        // 처음 로딩될 떄 fetchCoinList에 이벤트 전달
        firstLoad
            .bind(to: viewModel.input.fetchCoinList)
            .disposed(by: disposeBag)
        
        // searchBar의 text가 바뀌면 filterCoin에 text 전달
        searchBar.rx.text
            .bind(to: viewModel.input.filterCoin)
            .disposed(by: disposeBag)
        
        // coinList와 collection view 바인딩
        viewModel.output.coinList
            .debug("🔵 coinList", trimOutput: true)
            .bind(to: coinListCollectionView.rx.items(cellIdentifier: CoinListCollectionViewCell.identifier, cellType: CoinListCollectionViewCell.self)) { index, coin, cell in
                cell.update(from: coin)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.updateCell
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, value in
                let (index, coin) = value
                if ViewDisplaySelector.shared.canDisplay(index: index) == false { return }
                let indexPath = IndexPath(item: index, section: 0) // section이 항상 0 이 아니므로 나중에 수정!!
                guard let cell = owner.coinListCollectionView.cellForItem(at: indexPath) as? CoinListCollectionViewCell else { return }
                print("⚠️ cell update and animate")
                cell.updateAndAnimate(from: coin)
            })
            .disposed(by: disposeBag)
        
        let viewWillAppear = rx.viewWillAppear.map { _ in }
        let coinFetchedFirstTwo = viewModel.output.coinList.take(2).map { _ in }
        
        // viewWillAppear일때와 초기에 coinList에 accept됐을때 openWebSocket
        Observable.merge(viewWillAppear, coinFetchedFirstTwo)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.openWebSocket()
            })
            .disposed(by: disposeBag)
        
        // viewWillDisappear일때 closeWebSocket
        rx.viewWillDisappear
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.closeWebSocket()
            })
            .disposed(by: disposeBag)
        
        // willBeginDragging일때 closeWebSocket
        coinListCollectionView.rx.willBeginDragging
            .debug("🟢 willBeginDragging")
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.closeWebSocket()
            })
            .disposed(by: disposeBag)
        
        // didEndScroll일때 openWebSocket
        coinListCollectionView.rx.didEndScroll
            .debug("🔴 didEndScroll")
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.openWebSocket()
            })
            .disposed(by: disposeBag)
        
        let coinChanged = viewModel.output.coinChanged
        let didEndScroll = coinListCollectionView.rx.didEndScroll.map { _ in }
        
        // coinList에 새 코인이 업데이트 될 떄, scroll 이 끝났을 때 visible cells의 indexPath를 viewModel로 전달시켜 줌
        Observable.merge(coinChanged, didEndScroll)
            .observe(on: MainScheduler.instance)
            .debug("✅ visible cell set")
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                print("✅: ", owner.coinListCollectionView.indexPathsForVisibleItems.map { $0.row })
                let indexPaths = owner.coinListCollectionView.indexPathsForVisibleItems.map { $0.row }
                if indexPaths.isEmpty {
                    // 초기(처음 코인이 fetch되었을 때)에 비어있으면 안되므로 넉넉히 잡아 0~10까지 index를 줌
                    owner.viewModel.indexForVisibleCells = Array(0...10)
                } else {
                    owner.viewModel.indexForVisibleCells = owner.coinListCollectionView
                        .indexPathsForVisibleItems
                        .map { $0.row }
                }
            })
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
            at: IndexPath(item: 0, section: CoinListViewModel.Section.all.rawValue)
            ) {
            coinListCollectionView.scrollToItem(
                at: IndexPath(item: 0, section: CoinListViewModel.Section.all.rawValue),
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
//        let coinCellRegistration = UICollectionView.CellRegistration<CoinListCollectionViewCell, ViewCoin>(cellNib: cellNib) { cell, indexPath, item in
//            cell.delegate = self
//            cell.update(item: item)
//            cell.update(from: item)
//            cell.toggleFavorite = { [weak self] in
//                self?.coinListDataManager.toggleFavorite(
//                    coinSymbolName: item.symbolName,
//                    isAlreadyFavorite: item.isFavorite
//                )
//                self?.coinListDataManager.sortCoinList(filteredBy: self?.searchBar.text)
//            }
//        }
//        dataSource = UICollectionViewDiffableDataSource<CoinListViewModel.Section, ViewCoin>(collectionView: coinListCollectionView) { collectionView, indexPath, item in
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
    
//    private func getVisibleCellsForCoinListDataManager() {
//        let visibleCellsSymbols = coinListCollectionView
//            .visibleCells
//            .filter { $0 != excludedAtVisibleCells }
//            .compactMap { coinListCollectionView.indexPath(for: $0) }
//            .compactMap { dataSource?.itemIdentifier(for: $0)?.symbolName }
//        coinListDataManager.visibleCellsSymbols = visibleCellsSymbols
//    }
}

// MARK: - Snapshot

extension CoinListViewController {
//    func applySnapshot(favoriteCoinList: [Coin], allCoinList: [Coin]) {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Coin>()
//
//        if favoriteCoinList.isEmpty == false {
//            snapshot.appendSections([.favorite])
//            snapshot.appendItems(favoriteCoinList, toSection: .favorite)
//        }
//
//        if allCoinList.isEmpty == false {
//            snapshot.appendSections([.all])
//            snapshot.appendItems(allCoinList, toSection: .all)
//        }
//
//        DispatchQueue.main.async { [weak self] in
//            self?.checkCoinListMenuStackViewUnderLineShouldMove(favoriteCoinListIsEmpty: favoriteCoinList.isEmpty)
//            self?.dataSource?.applySnapshot(snapshot, animated: false) {
//                self?.getVisibleCellsForCoinListDataManager()
//            }
//        }
//    }
    
//    private func checkCoinListMenuStackViewUnderLineShouldMove(favoriteCoinListIsEmpty isEmpty: Bool) {
//        if isEmpty {
//            coinListMenuStackView.moveUnderLine(index: CoinListViewModel.Section.all.rawValue)
//        } else if let oldSnapshot = dataSource?.snapshot(), oldSnapshot.sectionIdentifiers.contains(.favorite) == false {
//            coinListMenuStackView.moveUnderLine(index: CoinListViewModel.Section.favorite.rawValue)
//        }
//    }
}

// MARK: - CoinListDataManagerDelegate

extension CoinListViewController: CoinListDataManagerDelegate {
    func coinListDataManager(didChangeCoinList favoriteCoinList: [Coin], allCoinList: [Coin]) {
//        applySnapshot(favoriteCoinList: favoriteCoinList, allCoinList: allCoinList)
//        endActivityIndicator()
    }
    
    func coinListDataManager(didSetCurrentPriceInAllCoinList favoriteCoinList: [Coin], allCoinList: [Coin]) {
//        applySnapshot(favoriteCoinList: favoriteCoinList, allCoinList: allCoinList)
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
//    func collectionView(
//        _ collectionView: UICollectionView,
//        didSelectItemAt indexPath: IndexPath
//    ) {
//        collectionView.deselectItem(at: indexPath, animated: false)
//        
//        let coin = dataSource?.itemIdentifier(for: indexPath)
//        let instantiater = ViewControllerInstantiater()
//        
//        guard let coinDetailViewController = instantiater.instantiate(
//            CoinDetailViewInstantiateInformation()
//        ) as? CoinDetailViewController else {
//            return
//        }
//        
////        coinDetailViewController.coin = coin // coin.asCoin이런식으로 바꾸기
//        navigationController?.show(coinDetailViewController, sender: nil)
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let headerAttributes = coinListCollectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: CoinListViewModel.Section.all.rawValue)
           ),
           let firstCellOfAllSection = coinListCollectionView.cellForItem(at: IndexPath(item: 0, section: CoinListViewModel.Section.all.rawValue)) {
            let allSectionHeaderHeight = headerAttributes.frame.height
            let allSectionHeaderOrigin = CGPoint(
                x: firstCellOfAllSection.frame.origin.x,
                y: firstCellOfAllSection.frame.origin.y - allSectionHeaderHeight + 1
            )
            if coinListCollectionView.contentOffset.y >= allSectionHeaderOrigin.y - 1 {
                coinListMenuStackView.moveUnderLine(index: CoinListViewModel.Section.all.rawValue)
            } else {
                coinListMenuStackView.moveUnderLine(index: CoinListViewModel.Section.favorite.rawValue)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if decelerate {
//            print("decelerate")
//            return
//        }
        print("scrollViewDidEndDragging")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("scrollViewWillEndDragging")
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDecelerating")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
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
