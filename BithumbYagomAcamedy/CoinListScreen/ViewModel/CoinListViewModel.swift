//
//  CoinListViewModel.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/07/10.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources

typealias CoinListSectionModel = SectionModel<String, ViewCoin>
typealias CellUpdateData = (IndexPath, ViewCoin)

final class CoinListViewModel: ViewModelType {
    struct Input {
        let fetchCoinList: AnyObserver<Void>
        let filterCoin: AnyObserver<String?>
        let favoriteCoin: AnyObserver<IndexPath>
        let anyButtonTapped: AnyObserver<CoinSortButton>
    }
    
    struct Output {
        let coinList: Observable<[CoinListSectionModel]>
        let updateCell: Observable<CellUpdateData>
        let fetchCoinListStarted: Observable<Void>
    }
    
    var disposeBag: DisposeBag = .init()
    var webSocketDisposeBag: DisposeBag = .init()
    
    var indexPathsForVisibleCells: [IndexPath] = []
    var selectedButton: CoinSortButton?
    
    private let webSocketService: WebSocketService
    private var coinController: CoinController?
    private let coinList: BehaviorRelay<[CoinListSectionModel]>
    private let updateCell: PublishRelay<CellUpdateData>
    
    let input: Input
    let output: Output
    
    init(
        httpNetworkService: HTTPNetworkService = .init(),
        webSocketService: WebSocketService = .init()
    ) {
        let fetching = PublishSubject<Void>()
        let sort = PublishSubject<CoinSortButton>()
        let filter = PublishSubject<String?>()
        let favorite = PublishSubject<IndexPath>()
        let anyButtonTapped = PublishSubject<CoinSortButton>()
        
        self.webSocketService = webSocketService
        self.selectedButton = nil
        self.coinList = .init(value: [])
        self.updateCell = .init()
        
        self.input = Input(
            fetchCoinList: fetching.asObserver(),
            filterCoin: filter.asObserver(),
            favoriteCoin: favorite.asObserver(),
            anyButtonTapped: anyButtonTapped.asObserver()
        )
        
        self.output = Output(
            coinList: coinList.asObservable(),
            updateCell: updateCell.asObservable(),
            fetchCoinListStarted: fetching
        )
        
        fetching
            .flatMap { httpNetworkService.fetchRx(api: TickerAPI(), type: TickersValueObject.self) }
            .map { $0.asViewCoinList() }
            .withUnretained(self)
            .subscribe(onNext: { owner, coinList in
                owner.coinController = CoinController(fetchedCoinList: coinList)
                owner.displayCoins()
            })
            .disposed(by: disposeBag)
        
        sort
            .withUnretained(self)
            .subscribe(onNext: { owner, coinSortButton in
                owner.coinController?.sort(using: coinSortButton)
                owner.displayCoins()
            })
            .disposed(by: disposeBag)
        
        filter
            .withUnretained(self)
            .subscribe(onNext: { owner, filterText in
                owner.coinController?.filter(by: filterText)
                owner.displayCoins()
            })
            .disposed(by: disposeBag)
        
        favorite
            .withUnretained(self)
            .subscribe(onNext: { owner, indexPath in
                owner.coinController?.favorite(indexPath: indexPath)
                owner.displayCoins()
            })
            .disposed(by: disposeBag)
        
        anyButtonTapped
            .withUnretained(self)
            .map { owner, eachButton -> (CoinSortType, CoinSortButton?) in
                guard let selectedButton = owner.selectedButton else {
                    return (.none, nil)
                }
                let isSelected = eachButton.button == selectedButton.button
                let sortType: CoinSortType
                if isSelected == false {
                    sortType = .none
                } else if eachButton.sortType.value == .descend {
                    sortType = .ascend
                } else {
                    sortType = .descend
                }
                return (sortType, eachButton)
            }
            .subscribe(onNext: { sortType, eachButton in
                guard let eachButton else { return }
                eachButton.sortType.accept(sortType)
                if sortType != .none {
                    sort.onNext(eachButton)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Helpers

extension CoinListViewModel {
    var isFavoriteCoinEmpty: Bool? {
        coinController?.isFavoriteCoinsEmpty
    }
    
    var favoriteCoinsCount: Int? {
        coinController?.favoriteCoinsCount
    }
    
    var allCoinsSectionFirstIndexPath: IndexPath? {
        guard let coinController else { return nil }
        
        let isFavoriteCoinsEmpty = coinController.isFavoriteCoinsEmpty
        let isAllCoinsEmpty = coinController.isAllCoinsEmpty
        
        guard isAllCoinsEmpty == false else { return nil }
        
        if isFavoriteCoinsEmpty {
            return IndexPath(item: 0, section: 0)
        } else {
            return IndexPath(item: 0, section: 1)
        }
    }
    
    private func displayCoins() {
        guard let sectionModel = coinController?.getSectionModel() else { return }
        coinList.accept(sectionModel)
    }
    
    func isFavoriteCoin(for indexPath: IndexPath) -> Bool? {
        return coinController?.isFavoriteCoin(for: indexPath)
    }
    
    func item(for indexPath: IndexPath) -> ViewCoin? {
        return coinController?.item(for: indexPath)
    }
    
    func nameOfSectionHeader(index: Int) -> String? {
        guard let coinController else { return nil }
        
        let isFavoriteCoinsEmpty = coinController.isFavoriteCoinsEmpty
        let isAllCoinsEmpty = coinController.isAllCoinsEmpty
        
        guard !isAllCoinsEmpty else { return nil }
        
        if isFavoriteCoinsEmpty {
            if index == 0 {
                return "원화"
            }
        } else {
            if index == 0 {
                return "관심"
            } else if index == 1 {
                return "원화"
            }
        }
        
        return nil
    }
}

// MARK: - WebSocket

extension CoinListViewModel {
    func openWebSocket() {
        closeWebSocket()
        
        guard let symbols = coinController?.symbolsInAllCoins else { return }
        
        let api = TransactionWebSocket(symbols: symbols)
        webSocketService
            .openRx(webSocketAPI: api)
            .withUnretained(self)
            .subscribe(onNext: { owner, transactionData in
                owner.updateCell(transactionData: transactionData)
            })
            .disposed(by: webSocketDisposeBag)
    }
    
    func closeWebSocket() {
        webSocketDisposeBag = .init()
    }
    
    private func updateCell(transactionData: WebSocketTransactionData.WebSocketTransaction) {
        let data = coinController?.update(
            transactionData: transactionData,
            indexPathsForVisibleCells: indexPathsForVisibleCells
        )
        data?.forEach {
            updateCell.accept($0)
        }
    }
}
