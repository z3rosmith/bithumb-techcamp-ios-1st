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
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<CoinListSectionModel>
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var balloonSpeakView: BallonSpeakView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var coinListMenuStackView: CoinListMenuStackView!
    @IBOutlet private weak var sortButtonStackView: UIStackView!
    @IBOutlet private weak var coinListCollectionView: UICollectionView!
    @IBOutlet private var sortButtons: [SortButton]!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var favoriteSectionButton: UIButton!
    @IBOutlet private weak var allSectionButton: UIButton!
    
    // MARK: - Property
    
    private var disposeBag: DisposeBag = .init()
    private lazy var viewModel: CoinListViewModel = .init()
    private lazy var coinSortButtons: [CoinSortButton] = configureCoinSortButtons(
        sortButtons: sortButtons,
        sortButtonTypes: [.popularity, .name, .price, .changeRate]
    )
    private var activityIndicator: UIActivityIndicatorView = .init()
    private let refreshControl: UIRefreshControl = .init()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureCollectionView()
        bind()
    }
}

// MARK: - Binding

extension CoinListViewController {
    private func bind() {
        // MARK: - Input To ViewModel
        
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in }
        
        /// 처음 로딩될 떄 fetchCoinList에 이벤트 전달
        firstLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.input.fetchCoinList.onNext(())
            })
            .disposed(by: disposeBag)
        
        /// searchBar의 text가 바뀌면 filterCoin에 text 전달
        searchBar.rx.text
            .bind(to: viewModel.input.filterCoin)
            .disposed(by: disposeBag)
        
        let viewWillAppear = rx.viewWillAppear.map { _ in }
        
        /// skip(1).take(1)를 한 이유는 coinList가 처음 방출될 때는 아직 CoinController가 nil이기 때문
        let coinFetchedSecondEvent = viewModel.output.coinList.skip(1).take(1).map { _ in }
        
        Observable.merge(viewWillAppear, coinFetchedSecondEvent)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.openWebSocket()
            })
            .disposed(by: disposeBag)
        
        coinListCollectionView.rx.didEndScroll
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                if owner.refreshControl.isRefreshing { return }
                owner.viewModel.openWebSocket()
            })
            .disposed(by: disposeBag)
        
        rx.viewWillDisappear
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.closeWebSocket()
            })
            .disposed(by: disposeBag)
        
        coinListCollectionView.rx.willBeginDragging
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.closeWebSocket()
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(with: self, onNext: { owner, _ in
                owner.searchBar.text = nil
                owner.viewModel.closeWebSocket()
                owner.viewModel.input.fetchCoinList.onNext(())
            })
            .disposed(by: disposeBag)
        
        let coinAccepted = viewModel.output.coinList.map { _ in }
        let didEndScroll = coinListCollectionView.rx.didEndScroll.map { _ in }
        let didScrollToTop = coinListCollectionView.rx.didScrollToTop.map { _ in }
        let favoriteSectionButtonTapped = favoriteSectionButton.rx.tap.map { _ in }
        let allSectionButtonTapped = allSectionButton.rx.tap.map { _ in }
        
        /// coinList에 보이는 코인이 업데이트 될 떄, scroll 이 끝났을 때, status bar를 눌러서 위로 끝까지 올라갔을 때
        /// 그리고 관심/원화 탭이 눌렸을 때
        /// visible cells의 indexPath를 viewModel로 전달시켜 줌
        /// 정확히 collectionView가 cell들을 표시하는 시점을 파악하기 어려우므로 500ms의 delay를 주었음
        Observable.merge(
            coinAccepted,
            didEndScroll,
            didScrollToTop,
            favoriteSectionButtonTapped,
            allSectionButtonTapped
        )
        .delay(.milliseconds(500), scheduler: MainScheduler.instance)
        .observe(on: MainScheduler.instance)
        .withUnretained(self)
        .subscribe(onNext: { owner, _ in
            let indexPaths = owner.coinListCollectionView.indexPathsForVisibleItems
            owner.viewModel.indexPathsForVisibleCells = indexPaths
        })
        .disposed(by: disposeBag)
        
        /// 처음 Coin Fetch되었을 때 selectedButton을 설정해 주어야 하고
        /// 인기순 기준으로 Sort 해주어야 함
        coinFetchedSecondEvent
            .withUnretained(self)
            .map { owner, _ in
                owner.coinSortButtons.first
            }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, coinSortButton in
                guard let coinSortButton else { return }
                owner.viewModel.selectedButton = coinSortButton
                owner.viewModel.input.anyButtonTapped.onNext(coinSortButton)
            })
            .disposed(by: disposeBag)
        
        coinSortButtons.forEach { coinSortButton in
            let button = coinSortButton.button
            let sortType = coinSortButton.sortType
            
            button.rx.tap
                .map { coinSortButton }
                .withUnretained(self)
                .subscribe(onNext: { owner, coinSortButton in
                    owner.viewModel.selectedButton = coinSortButton
                })
                .disposed(by: disposeBag)
            
            button.rx.tap
                .withUnretained(self)
                .flatMap { owner, _ in
                    Observable.from(owner.coinSortButtons)
                }
                .bind(to: viewModel.input.anyButtonTapped)
                .disposed(by: disposeBag)
            
            sortType
                .asDriver()
                .drive(with: self, onNext: { owner, type in
                    let imageName = type.rawValue
                    button.setImage(UIImage(named: imageName), for: .normal)
                })
                .disposed(by: disposeBag)
        }
        
        // MARK: - Output From ViewModel
        
        let dataSource = configureDataSource()
        
        /// coinList와 collection view 바인딩
        viewModel.output.coinList
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
        
        coinFetchedSecondEvent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { owner, _ in
                owner.setInitialUnderLineLocation()
            })
            .disposed(by: disposeBag)
        
        let fetchCoinListStarted = viewModel.output.fetchCoinListStarted
        
        fetchCoinListStarted
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.activityIndicator.startAnimating()
            })
            .disposed(by: disposeBag)
        
        coinAccepted
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.activityIndicator.stopAnimating()
                owner.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        // MARK: - View Related
        
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
        
        favoriteSectionButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { owner, _ in
                owner.scrollToFavoriteCoinsSection()
            })
            .disposed(by: disposeBag)
        
        allSectionButton.rx.tap
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
}

// MARK: - Configuration

extension CoinListViewController {
    private func configureViews() {
        configureBalloonSpeakView()
        configureRefreshControl()
        configureActivityIndicator()
    }
    
    private func configureCollectionView() {
        coinListCollectionView.register(
            UINib(nibName: "CoinListCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: CoinListCollectionViewCell.identifier
        )
        coinListCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        configureCollectionViewLayout()
    }
    
    private func configureDataSource() -> DataSource {
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = self?.viewModel.nameOfSectionHeader(index: indexPath.section)
            configuration.textProperties.font = .preferredFont(forTextStyle: .largeTitle)
            configuration.textProperties.color = .label
            headerView.contentConfiguration = configuration
            headerView.backgroundColor = .white
        }
        
        let dataSource = DataSource(configureCell: { _, collectionView, indexPath, item in
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
        
        return dataSource
    }
    
    private func configureCoinSortButtons(
        sortButtons: [SortButton],
        sortButtonTypes: [CoinSortButton.ButtonType]
    ) -> [CoinSortButton] {
        return sortButtons.enumerated().map { index, sortButton in
            CoinSortButton(button: sortButton, buttonType: sortButtonTypes[index])
        }
    }
    
    private func configureBalloonSpeakView() {
        balloonSpeakView.isHidden = true
    }
    
    private func configureRefreshControl() {
        coinListCollectionView.refreshControl = refreshControl
    }
    
    private func configureActivityIndicator() {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
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
