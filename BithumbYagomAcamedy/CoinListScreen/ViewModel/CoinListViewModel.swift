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
        let sortCoin: AnyObserver<CoinSortButton>
        let filterCoin: AnyObserver<String?>
        let favoriteCoin: AnyObserver<IndexPath>
    }
    
    struct Output {
        let coinList: Observable<[CoinListSectionModel]>
        let coinDisplayed: Observable<Void>
        let updateCell: Observable<CellUpdateData>
    }
    
    var disposeBag: DisposeBag = .init()
    var webSocketDisposeBag: DisposeBag = .init()
    var indexPathsForVisibleCells: [IndexPath] = []
    
    private let webSocketService: WebSocketService
    private let coinSortButtons: [CoinSortButton]
    private var coinListController: CoinListController?
    private var selectedButton: CoinSortButton?
    
    private let anyButtonTapped: BehaviorRelay<CoinSortButton?>
    private let displayCoinsRelay: BehaviorRelay<[CoinListSectionModel]>
    private let updateCell: PublishRelay<CellUpdateData>
    private let coinDisplayed: PublishSubject<Void>
    
    let input: Input
    let output: Output
    
    init(
        httpNetworkService: HTTPNetworkService = .init(),
        webSocketService: WebSocketService = .init(),
        sortButtons: [SortButton],
        sortButtonTypes: [CoinSortButton.ButtonType]
    ) {
        let fetching = PublishSubject<Void>()
        let sort = PublishSubject<CoinSortButton>()
        let filter = PublishSubject<String?>()
        let favorite = PublishSubject<IndexPath>()
        
        self.webSocketService = webSocketService
        self.coinSortButtons = sortButtons.enumerated().map { index, sortButton in
            CoinSortButton(button: sortButton, buttonType: sortButtonTypes[index])
        }
        self.selectedButton = coinSortButtons.first
        self.anyButtonTapped = .init(value: coinSortButtons.first)
        self.displayCoinsRelay = .init(value: [])
        self.updateCell = .init()
        self.coinDisplayed = .init()
        
        self.input = Input(
            fetchCoinList: fetching.asObserver(),
            sortCoin: sort.asObserver(),
            filterCoin: filter.asObserver(),
            favoriteCoin: favorite.asObserver()
        )
        
        self.output = Output(
            coinList: displayCoinsRelay.asObservable(),
            coinDisplayed: coinDisplayed,
            updateCell: updateCell.asObservable()
        )
        
        fetching
            .flatMap { httpNetworkService.fetchRx(api: TickerAPI(), type: TickersValueObject.self) }
            .map { $0.asViewCoinList() }
            .withUnretained(self)
            .subscribe(onNext: { owner, coinList in
                owner.coinListController = CoinListController(fetchedCoinList: coinList, selectedButton: owner.selectedButton)
                owner.displayCoins()
            })
            .disposed(by: disposeBag)
        
        sort
            .withUnretained(self)
            .subscribe(onNext: { owner, coinSortButton in
                owner.coinListController?.sort(using: coinSortButton)
                owner.displayCoins()
            })
            .disposed(by: disposeBag)
        
        filter
            .withUnretained(self)
            .subscribe(onNext: { owner, filterText in
                owner.coinListController?.filter(by: filterText)
                owner.displayCoins()
            })
            .disposed(by: disposeBag)
        
        favorite
            .withUnretained(self)
            .subscribe(onNext: { owner, indexPath in
                owner.coinListController?.favorite(indexPath: indexPath)
                owner.displayCoins()
            })
            .disposed(by: disposeBag)
        
        coinSortButtons.forEach { coinSortButton in
            let button = coinSortButton.button
            let sortType = coinSortButton.sortType
            
            button.rx.tap
                .asDriver()
                .map { coinSortButton }
                .drive(with: self, onNext: { owner, coinSortButton in
                    owner.selectedButton = coinSortButton
                })
                .disposed(by: disposeBag)
            
            button.rx.tap
                .withUnretained(self)
                .flatMap { owner, _ in
                    Observable.from(owner.coinSortButtons)
                }
                .bind(to: anyButtonTapped)
                .disposed(by: disposeBag)
            
            sortType
                .asDriver()
                .drive(with: self, onNext: { owner, type in
                    let imageName = type.rawValue
                    button.setImage(UIImage(named: imageName), for: .normal)
                })
                .disposed(by: disposeBag)
        }
        
        anyButtonTapped
            .withUnretained(self)
            .map { owner, eachButton -> (CoinSortType, CoinSortButton?) in
                let isSelected = eachButton?.button == owner.selectedButton?.button
                let sortType: CoinSortType
                if isSelected == false {
                    sortType = .none
                } else if eachButton?.sortType.value == .descend {
                    sortType = .ascend
                } else {
                    sortType = .descend
                }
                return (sortType, eachButton)
            }
            .subscribe(onNext: { sortType, eachButton in
                eachButton?.sortType.accept(sortType)
                if sortType != .none {
                    guard let eachButton = eachButton else { return }
                    sort.onNext(eachButton)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Helpers

extension CoinListViewModel {
    private func displayCoins() {
        guard let sectionModel = coinListController?.getSectionModel() else { return }
        displayCoinsRelay.accept(sectionModel)
        coinDisplayed.onNext(())
    }
    
    func isFavoriteCoin(for indexPath: IndexPath) -> Bool? {
        return coinListController?.isFavoriteCoin(for: indexPath)
    }
    
    func item(for indexPath: IndexPath) -> ViewCoin? {
        return coinListController?.item(for: indexPath)
    }
    
    func nameOfSectionHeader(index: Int) -> String? {
        let isFavoriteCoinsEmpty = coinListController?.isFavoriteCoinsEmpty
        let isAllCoinsEmpty = coinListController?.isAllCoinsEmpty
        
        guard let isFavoriteCoinsEmpty, let isAllCoinsEmpty else { return nil }

        if isFavoriteCoinsEmpty && isAllCoinsEmpty {
            return nil
        } else if isFavoriteCoinsEmpty {
            return "원화"
        } else if isAllCoinsEmpty {
            return nil
        } else {
            if index == 0 {
                return "관심"
            } else {
                return "원화"
            }
        }
    }
}

// MARK: - WebSocket

extension CoinListViewModel {
    func openWebSocket() {
        closeWebSocket()
        
        guard let symbols = coinListController?.symbolsInAllCoins else { return }
        
        print("📃 symbols", symbols)
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
        let data = coinListController?.update(
            transactionData: transactionData,
            indexPathsForVisibleCells: indexPathsForVisibleCells
        )
        data?.forEach {
            updateCell.accept($0)
        }
    }
}

// MARK: - Nested Types

extension CoinListViewModel {
    enum CoinSortType: String {
        case none = "chevron_all_gray"
        case descend = "chevron_under_black"
        case ascend = "chevron_up_black"
    }
    
    struct CoinSortButton {
        enum ButtonType {
            case popularity
            case name
            case price
            case changeRate
        }
        let button: SortButton
        let buttonType: ButtonType
        let sortType: BehaviorRelay<CoinSortType> = .init(value: .none)
    }
    
    final fileprivate class CoinListController {
        private var favoriteCoins: CoinListWithBackup
        private var allCoins: CoinListWithBackup
        private let favoriteCoinCoreDataManager: FavoriteCoinCoreDataManager
        
        var isFavoriteCoinsEmpty: Bool {
            favoriteCoins.list.isEmpty
        }
        
        var isAllCoinsEmpty: Bool {
            allCoins.list.isEmpty
        }
        
        var symbolsInAllCoins: [String] {
            allCoins.list.map { $0.symbolName }
        }
        
        var sectionOfFavoriteCoins: Int? {
            isFavoriteCoinsEmpty ? nil : 0
        }
        
        var sectionOfAllCoins: Int? {
            isFavoriteCoinsEmpty ? 0 : 1
        }
        
        init(
            fetchedCoinList: [ViewCoin],
            selectedButton: CoinSortButton?,
            favoriteCoinCoreDataManager: FavoriteCoinCoreDataManager = .init()
        ) {
            let favoriteCoinsSymbols = favoriteCoinCoreDataManager.fetch()
            let acoins = fetchedCoinList.map { coin in
                if favoriteCoinsSymbols.contains(coin.symbolName) {
                    var copy = coin.copy()
                    copy.toggleFavorite()
                    return copy
                }
                return coin
            }
            let fcoins = acoins.filter { $0.isFavorite }
            
            allCoins = CoinListWithBackup(coins: acoins)
            self.favoriteCoinCoreDataManager = favoriteCoinCoreDataManager
            favoriteCoins = CoinListWithBackup(coins: fcoins)
            
            if let selectedButton {
                allCoins.sort(using: selectedButton)
                favoriteCoins.sort(using: selectedButton)
            }
        }
        
        func getSectionModel() -> [CoinListSectionModel] {
            var sectionModel: [CoinListSectionModel] = []
            
            if favoriteCoins.list.isEmpty == false {
                sectionModel.append(CoinListSectionModel(model: "관심", items: favoriteCoins.list))
            }
            
            if allCoins.list.isEmpty == false {
                sectionModel.append(CoinListSectionModel(model: "원화", items: allCoins.list))
            }
            
            return sectionModel
        }
        
        func sort(using coinSortButton: CoinSortButton) {
            favoriteCoins.sort(using: coinSortButton)
            allCoins.sort(using: coinSortButton)
        }
        
        func filter(by text: String?) {
            favoriteCoins.filter(by: text)
            allCoins.filter(by: text)
        }
        
        func favorite(indexPath: IndexPath) {
            let index = indexPath.item
            
            /// favoriteCoinList가 비어있는 경우는 무조건 좋아요 하는 경우임
            if favoriteCoins.list.isEmpty {
                let coin = allCoins.toggleFavorite(index: index)
                favoriteCoins.append(coin)
                favoriteCoinCoreDataManager.save(symbol: coin.symbolName)
                return
            }
            
            /// favoriteCoinList가 비어있지 않은 경우는
            /// indexPath.section == 0이면 무조건 좋아요 취소 하는 경우
            /// indexPath.section == 1이면 isFavorite == true이면 좋아요 취소, 그렇지 않으면 좋아요 하는 경우
            if indexPath.section == 0 {
                let coin = favoriteCoins.remove(at: index)
                favoriteCoinCoreDataManager.delete(symbol: coin.symbolName)
                
                if let index = allCoins.list.searchIndex(with: coin.symbolName) {
                    allCoins.toggleFavorite(index: index)
                }
                
                return
            }
            
            let isFavorite = allCoins.list[index].isFavorite
            let coin = allCoins.toggleFavorite(index: index)
            
            if isFavorite {
                if let index = favoriteCoins.list.searchIndex(with: coin.symbolName) {
                    favoriteCoins.remove(at: index)
                    favoriteCoinCoreDataManager.delete(symbol: coin.symbolName)
                }
            } else {
                favoriteCoins.append(coin)
                favoriteCoinCoreDataManager.save(symbol: coin.symbolName)
            }
        }
        
        func item(for indexPath: IndexPath) -> ViewCoin {
            let index = indexPath.item
            let section = indexPath.section
            if favoriteCoins.list.isEmpty == false {
                if section == 0 {
                    return favoriteCoins.list[index]
                } else {
                    return allCoins.list[index]
                }
            }
            return allCoins.list[index]
        }
        
        func isFavoriteCoin(for indexPath: IndexPath) -> Bool {
            return item(for: indexPath).isFavorite
        }
        
        func update(
            transactionData: WebSocketTransactionData.WebSocketTransaction,
            indexPathsForVisibleCells: [IndexPath]
        ) -> [CellUpdateData] {
            let data1 = updateCell(
                from: favoriteCoins,
                section: sectionOfFavoriteCoins,
                transactionData: transactionData,
                indexPathsForVisibleCells: indexPathsForVisibleCells
            )
            let data2 = updateCell(
                from: allCoins,
                section: sectionOfAllCoins,
                transactionData: transactionData,
                indexPathsForVisibleCells: indexPathsForVisibleCells
            )
            var dataList: [CellUpdateData] = []
            if let data1 {
                dataList.append(data1)
            }
            if let data2 {
                dataList.append(data2)
            }
            return dataList
        }
        
        private func updateCell(
            from coins: CoinListWithBackup,
            section: Int?,
            transactionData: WebSocketTransactionData.WebSocketTransaction,
            indexPathsForVisibleCells: [IndexPath]
        ) -> CellUpdateData? {
            let symbol = transactionData.symbol.components(separatedBy: "_")[0]
            
            guard let index = coins.list.firstIndex(where: { $0.symbolName == symbol }),
                  let section
            else { return nil }
            
            let indexPath = IndexPath(item: index, section: section)
            
            guard indexPathsForVisibleCells.contains(indexPath),
                  let newPrice = Double(transactionData.price)
            else { return nil }
            
            let oldCoin = coins.list[index]
            let (newChangePrice, newChangeRate) = calculateChange(
                pivotPrice: oldCoin.closingPrice,
                newPrice: newPrice
            )
            let oldPrice = oldCoin.currentPrice
            let changePriceStyle: ViewCoin.ChangeStyle
            
            if newPrice > oldPrice {
                changePriceStyle = .up
            } else if newPrice < oldPrice {
                changePriceStyle = .down
            } else {
                changePriceStyle = .none
            }
            
            let newCoin = oldCoin.updated(
                newPrice: newPrice,
                newChangeRate: newChangeRate,
                newChangePrice: newChangePrice,
                changePriceStyle: changePriceStyle
            )
            coins.remove(at: index)
            coins.append(newCoin)
            
            return (indexPath, newCoin)
        }
        
        private func calculateChange(
            pivotPrice: Double,
            newPrice: Double
        ) -> (changePrice: Double, changeRate: Double) {
            let changePrice = newPrice - pivotPrice
            let changeRate = (changePrice / pivotPrice * 10000).rounded() / 100
            return (changePrice, changeRate)
        }
    }
}

// MARK: - Extension Of CoinListController

extension CoinListViewModel.CoinListController {
    final private class CoinListWithBackup {
        private var backup: [ViewCoin]
        private(set) var list: [ViewCoin]
        
        var currentSortButton: CoinListViewModel.CoinSortButton?
        var currentFilterText: String?
        
        init(coins: [ViewCoin]) {
            list = coins
            backup = list
        }
        
        func sort(using coinSortButton: CoinListViewModel.CoinSortButton) {
            backup.sort(using: coinSortButton)
            list.sort(using: coinSortButton)
            
            currentSortButton = coinSortButton
        }
        
        func filter(by text: String?) {
            list = backup.filter(by: text)
            
            currentFilterText = text
        }
        
        @discardableResult
        func toggleFavorite(index: Int) -> ViewCoin {
            let coin = list[index].toggleFavorite()
            if let indexInBackup = backup.searchIndex(with: coin.symbolName) {
                backup[indexInBackup].toggleFavorite()
            }
            return coin
        }
        
        func append(_ coin: ViewCoin) {
            list.append(coin)
            backup.append(coin)
            
            if let currentSortButton {
                sort(using: currentSortButton)
            }
        }
        
        @discardableResult
        func remove(at index: Int) -> ViewCoin {
            let removedCoin = list.remove(at: index)
            if let indexInBackup = backup.searchIndex(with: removedCoin.symbolName) {
                backup.remove(at: indexInBackup)
            }
            return removedCoin
        }
    }
}

// MARK: - Extension Of Array

fileprivate extension Array where Element == ViewCoin {
    func sorted(using coinSortButton: CoinListViewModel.CoinSortButton) -> [Element] {
        let sortedCoinList: [Element]
        let coinSortType = coinSortButton.sortType.value
        switch coinSortButton.buttonType {
        case .popularity:
            if coinSortType == .ascend {
                sortedCoinList = self.sorted { $0.popularity < $1.popularity }
            } else {
                sortedCoinList = self.sorted { $0.popularity > $1.popularity }
            }
        case .name:
            if coinSortType == .ascend {
                sortedCoinList = self.sorted { $0.callingName < $1.callingName }
            } else {
                sortedCoinList = self.sorted { $0.callingName > $1.callingName }
            }
        case .price:
            if coinSortType == .ascend {
                sortedCoinList = self.sorted { $0.currentPrice < $1.currentPrice }
            } else {
                sortedCoinList = self.sorted { $0.currentPrice > $1.currentPrice }
            }
        case .changeRate:
            if coinSortType == .ascend {
                sortedCoinList = self.sorted { $0.changeRate < $1.changeRate }
            } else {
                sortedCoinList = self.sorted { $0.changeRate > $1.changeRate }
            }
        }
        return sortedCoinList
    }
    
    mutating func sort(using coinSortButton: CoinListViewModel.CoinSortButton) {
        self = self.sorted(using: coinSortButton)
    }
    
    func filter(by text: String?) -> [Element] {
        guard let text = text,
              text.isEmpty == false
        else { return self }
        
        return self.filter {
            $0.callingName.localizedStandardContains(text) ||
                $0.symbolName.localizedStandardContains(text)
        }
    }
    
    func searchIndex(with symbolName: String) -> Int? {
        return self.firstIndex { $0.symbolName == symbolName }
    }
}
