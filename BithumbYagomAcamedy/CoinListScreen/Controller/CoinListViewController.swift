//
//  CoinListViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
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
    @IBOutlet private weak var favoriteCoinsButton: UIButton!
    @IBOutlet private weak var allCoinsButton: UIButton!
    
    // MARK: - Property
    
    private var disposeBag: DisposeBag = .init()
    private lazy var viewModel: CoinListViewModel = .init(
        sortButtons: sortButtons,
        sortButtonTypes: [.popularity, .name, .price, .changeRate]
    )
    private let coinListDataManager: CoinListDataManager = .init()
//    private lazy var activityIndicator: UIActivityIndicatorView = {
//        let indicator = UIActivityIndicatorView()
//        indicator.center = view.center
//        indicator.startAnimating()
//        return indicator
//    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        registerCollectionViewCell()
        configureCollectionViewLayout()
        configureBalloonSpeakView()
        configureViewBindings()
        configureViewModelBindings()
    }
}

// MARK: - Binding

extension CoinListViewController {
    private func configureViewModelBindings() {
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in }
        
        /// 처음 로딩될 떄 fetchCoinList에 이벤트 전달
        firstLoad
            .bind(to: viewModel.input.fetchCoinList)
            .disposed(by: disposeBag)
        
        /// searchBar의 text가 바뀌면 filterCoin에 text 전달
        searchBar.rx.text
            .bind(to: viewModel.input.filterCoin)
            .disposed(by: disposeBag)
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = self?.viewModel.nameOfSectionHeader(index: indexPath.section)
            configuration.textProperties.font = .preferredFont(forTextStyle: .largeTitle)
            configuration.textProperties.color = .label
            headerView.contentConfiguration = configuration
            headerView.backgroundColor = .white
        }
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<CoinListSectionModel>(configureCell: { _, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CoinListCollectionViewCell.identifier, for: indexPath) as? CoinListCollectionViewCell else { fatalError() }
            cell.update(from: item)
            cell.toggleFavorite = { [weak self] in
                self?.viewModel.input.favoriteCoin.onNext(indexPath)
                self?.moveUnderLine(contentOffsetY: collectionView.contentOffset.y)
            }
            return cell
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            default:
                fatalError()
            }
        })
        
        /// coinList와 collection view 바인딩
        viewModel.output.coinList
            .debug("🔵 coinList", trimOutput: true)
            .bind(to: coinListCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.updateCell
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, value in
                let (indexPath, coin) = value
                if ViewDisplaySelector.shared.canDisplay(indexPath: indexPath) == false { return }
                guard let cell = owner.coinListCollectionView.cellForItem(at: indexPath) as? CoinListCollectionViewCell else { return }
                cell.updateAndAnimate(from: coin)
            })
            .disposed(by: disposeBag)
        
        let viewWillAppear = rx.viewWillAppear.map { _ in }
        let coinFetchedFirstTwo = viewModel.output.coinList.take(2).map { _ in }
        
        /// viewWillAppear일때와 초기에 coinList에 accept됐을때 WebSocket open
        Observable.merge(viewWillAppear, coinFetchedFirstTwo)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.openWebSocket()
            })
            .disposed(by: disposeBag)
        
        coinFetchedFirstTwo
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { owner, _ in
                owner.setInitialUnderLineLocation()
            })
            .disposed(by: disposeBag)
        
        /// viewWillDisappear일때 WebSocket close
        rx.viewWillDisappear
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.closeWebSocket()
            })
            .disposed(by: disposeBag)
        
        /// willBeginDragging일때 closeWebSocket
        coinListCollectionView.rx.willBeginDragging
            .debug("🟢 willBeginDragging")
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.closeWebSocket()
            })
            .disposed(by: disposeBag)
        
        /// didEndScroll일때 openWebSocket
        coinListCollectionView.rx.didEndScroll
            .debug("🔴 didEndScroll")
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.openWebSocket()
            })
            .disposed(by: disposeBag)
        
        let coinDisplayed = viewModel.output.coinDisplayed
        let didEndScroll = coinListCollectionView.rx.didEndScroll.map { _ in }
        
        /// coinList에 보이는 코인이 업데이트 될 떄, scroll 이 끝났을 때
        /// visible cells의 indexPath를 viewModel로 전달시켜 줌
        /// 정확히 collectionView가 cell들을 표시하는 시점을 파악하기 어려우므로 500ms의 delay를 주었음
        Observable.merge(coinDisplayed, didEndScroll)
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .debug("✅ visible cell set")
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let indexPaths = owner.coinListCollectionView.indexPathsForVisibleItems
                print(indexPaths)
                owner.viewModel.indexPathsForVisibleCells = indexPaths
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
        
        if let navigationController {
            Observable.merge(
                rx.viewWillAppear.map { _ in true },
                rx.viewWillDisappear.map { _ in false }
            )
            .bind(to: navigationController.rx.isNavigationBarHidden)
            .disposed(by: disposeBag)
        }
        
        favoriteCoinsButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { owner, _ in
                owner.scrollToFavoriteCoinsSection()
            })
            .disposed(by: disposeBag)
        
        allCoinsButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { owner, _ in
                owner.scrollToAllCoinsSection()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Helper

extension CoinListViewController {
    private func scrollToFavoriteCoinsSection() {
        if viewModel.isFavoriteCoinEmpty == false {
            coinListCollectionView.setContentOffset(.zero, animated: false)
            coinListMenuStackView.moveUnderLineToFavoriteCoinsButton()
        }
    }
    
    private func scrollToAllCoinsSection() {
        guard let allCoinsSectionFirstIndexPath = viewModel.allCoinsSectionFirstIndexPath else { return }
        coinListCollectionView.scrollToItem(
            at: allCoinsSectionFirstIndexPath,
            at: .top,
            animated: false
        )
        coinListMenuStackView.moveUnderLineToAllCoinsButton()
    }
    
    private func setInitialUnderLineLocation() {
        guard let isFavoriteCoinEmpty = viewModel.isFavoriteCoinEmpty else { return }
        
        if isFavoriteCoinEmpty {
            coinListMenuStackView.moveUnderLineToAllCoinsButton()
        } else {
            coinListMenuStackView.moveUnderLineToFavoriteCoinsButton()
        }
    }
    
    private func animateBalloonSpeakView(isHidden: Bool) {
        UIView.transition(with: balloonSpeakView, duration: 0.5, options: .transitionCrossDissolve) {
            self.balloonSpeakView.isHidden = isHidden
        }
    }
    
    private func moveUnderLine(contentOffsetY: CGFloat) {
        let favoriteSectionContentSizeHeight = getFavoriteSectionContentSizeHeight()
        
        if contentOffsetY < favoriteSectionContentSizeHeight {
            coinListMenuStackView.moveUnderLineToFavoriteCoinsButton()
        } else {
            coinListMenuStackView.moveUnderLineToAllCoinsButton()
        }
    }
    
    private func getFavoriteSectionContentSizeHeight() -> CGFloat {
        guard let favoriteCoinsCount = viewModel.favoriteCoinsCount,
              favoriteCoinsCount > 0
        else { return 0 }
        
        var contentSizeHeight: CGFloat = 0
        
        if let headerAttributes = coinListCollectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) {
            contentSizeHeight += headerAttributes.frame.height
        }
        
        for index in 0..<favoriteCoinsCount {
            let indexPath = IndexPath(item: index, section: 0)
            if let cell = coinListCollectionView.cellForItem(at: indexPath) {
                contentSizeHeight += cell.frame.height
            }
        }
        
        return contentSizeHeight
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
    
    private func registerCollectionViewCell() {
        coinListCollectionView.register(UINib(nibName: "CoinListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CoinListCollectionViewCell.identifier)
    }
    
    private func configureCollectionViewLayout() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.headerMode = .supplementary
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            let favoriteAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                self?.viewModel.input.favoriteCoin.onNext(indexPath)
                if let collecionView = self?.coinListCollectionView {
                    self?.moveUnderLine(contentOffsetY: collecionView.contentOffset.y)
                }
                completion(true)
            }
            
            let isFavorite = self?.viewModel.isFavoriteCoin(for: indexPath)
            
            if isFavorite == true {
                favoriteAction.image = UIImage(systemName: "heart.slash.fill")?.withTintColor(.white)
            } else {
                favoriteAction.image = UIImage(systemName: "heart.fill")?.withTintColor(.white)
            }
            favoriteAction.backgroundColor = .systemOrange

            return UISwipeActionsConfiguration(actions: [favoriteAction])
        }
        coinListCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        coinListCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func configureCollectionView() {
        coinListCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate

extension CoinListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let instantiater = ViewControllerInstantiater()
        
        guard let coinDetailViewController = instantiater.instantiate(
            CoinDetailViewInstantiateInformation()
        ) as? CoinDetailViewController,
              let coin = viewModel.item(for: indexPath)
        else {
            return
        }
        
        coinDetailViewController.coin = coin.asCoin()
        navigationController?.show(coinDetailViewController, sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        
        moveUnderLine(contentOffsetY: contentOffsetY)
    }
}
