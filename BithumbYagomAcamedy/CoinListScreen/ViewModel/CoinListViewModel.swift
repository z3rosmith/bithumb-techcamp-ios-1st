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

final class CoinListViewModel: ViewModelType {
    enum ListKind: Int {
        case favorite
        case all
    }
    
    struct Input {
        let fetchCoinList: AnyObserver<Void>
        let sortCoin: AnyObserver<CoinSortButton>
        let filterCoin: AnyObserver<String?>
        let favoriteCoin: AnyObserver<IndexPath>
    }
    
    struct Output {
        let coinList: Observable<[CoinListSectionModel]>
        let coinDisplayed: Observable<Void>
        let updateCell: Observable<(IndexPath, ViewCoin)>
    }
    
    var disposeBag: DisposeBag = .init()
    var webSocketDisposeBag: DisposeBag = .init()
    var indexPathsForVisibleCells: [IndexPath] = []
    
    private let webSocketService: WebSocketService
    private let coinSortButtons: [CoinSortButton]
    private var allCoinList: [ViewCoin]
    private var favoriteCoinList: [ViewCoin]
    private var selectedButton: CoinSortButton?
    
    private let anyButtonTapped: BehaviorRelay<CoinSortButton?>
    private let displayCoinsRelay: BehaviorRelay<[CoinListSectionModel]>
    private let updateCell: PublishRelay<(IndexPath, ViewCoin)>
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
        self.allCoinList = []
        self.favoriteCoinList = []
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
        
        // INPUT
        
        fetching
            .flatMap { httpNetworkService.fetchRx(api: TickerAPI(), type: TickersValueObject.self) }
            .map { $0.asViewCoinList() }
            .withUnretained(self)
            .subscribe(onNext: { owner, coinList in
                ////////////////// 이부분 바꿔야함. 왜냐면 favorite을 coredata에서 가져와서 설정해줘야하기때문
                var sorted = coinList
                if let coinSortButton = owner.selectedButton {
                    sorted = coinList.sorted(using: coinSortButton)
                }
                owner.allCoinList = sorted
                owner.acceptToCoins(favoriteCoins: owner.favoriteCoinList, allCoins: owner.allCoinList)
            })
            .disposed(by: disposeBag)
        
        sort
            .withUnretained(self)
            .subscribe(onNext: { owner, coinSortButton in
                let favoriteSorted = owner.favoriteCoinList.sorted(using: coinSortButton)
                let allSorted = owner.allCoinList.sorted(using: coinSortButton)
                owner.favoriteCoinList = favoriteSorted
                owner.allCoinList = allSorted
                owner.acceptToCoins(favoriteCoins: owner.favoriteCoinList, allCoins: owner.allCoinList)
            })
            .disposed(by: disposeBag)
        
        filter
            .withUnretained(self)
            .subscribe(onNext: { owner, filterText in
                let favoriteFiltered = owner.favoriteCoinList.filter(by: filterText)
                let allFiltered = owner.allCoinList.filter(by: filterText)
                owner.acceptToCoins(favoriteCoins: favoriteFiltered, allCoins: allFiltered)
//                owner.favoriteCoinList = favoriteFiltered
//                owner.allCoinList = allFiltered
//                owner.acceptToCoins(favoriteCoins: owner.favoriteCoinList, allCoins: owner.allCoinList)
            })
            .disposed(by: disposeBag)
        
        favorite
            .withUnretained(self)
            .subscribe(onNext: { owner, indexPath in
                let index = indexPath.item
                
                /// favoriteCoinList가 비어있는 경우는 무조건 좋아요 하는 경우임
                if owner.favoriteCoinList.isEmpty {
                    let coin = owner.allCoinList[index].toggleFavorite()
                    owner.favoriteCoinList.append(coin)
                    owner.acceptToCoins(favoriteCoins: owner.favoriteCoinList, allCoins: owner.allCoinList)
                    return
                }
                
                /// favoriteCoinList에 코인이 있는 경우는
                /// indexPath.section == 0이면 무조건 좋아요 취소 하는 경우
                /// indexPath.section == 1이면 isFavorite == true이면 좋아요 취소, 그렇지 않으면 좋아요 하는 경우
                if indexPath.section == 0 {
                    let coin = owner.favoriteCoinList[index]
                    owner.favoriteCoinList.remove(at: index)
                    
                    if let index = owner.searchIndex(at: owner.allCoinList, symbolName: coin.symbolName) {
                        owner.allCoinList[index].toggleFavorite()
                    }
                    
                    owner.acceptToCoins(favoriteCoins: owner.favoriteCoinList, allCoins: owner.allCoinList)
                    return
                }
                
                let isFavorite = owner.allCoinList[index].isFavorite
                let coin = owner.allCoinList[index].toggleFavorite()
                
                if isFavorite {
                    if let index = owner.searchIndex(at: owner.favoriteCoinList, symbolName: coin.symbolName) {
                        owner.favoriteCoinList.remove(at: index)
                    }
                } else {
                    owner.favoriteCoinList.append(coin)
                }
                owner.acceptToCoins(favoriteCoins: owner.favoriteCoinList, allCoins: owner.allCoinList)
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
        
        ///////////////// 이부분 리팩토링 가능?
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
        
        // OUTPUT
    }
}

// MARK: - Helpers

extension CoinListViewModel {
    private func acceptToCoins(favoriteCoins: [ViewCoin], allCoins: [ViewCoin]) {
        var sectionModel: [CoinListSectionModel] = []
        
        if favoriteCoins.isEmpty == false {
            sectionModel.append(CoinListSectionModel(model: "관심", items: favoriteCoins))
        }
        
        if allCoins.isEmpty == false {
            sectionModel.append(CoinListSectionModel(model: "원화", items: allCoins))
        }
        
        displayCoinsRelay.accept(sectionModel)
        coinDisplayed.onNext(())
    }
    
    private func displayCoins() {
        let sectionModel = 인스턴스OfCoinList.getSectionModel()
        displayCoinsRelay.accept(sectionModel)
        coinDisplayed.onNext(())
    }
    
    func isFavoriteCoin(for indexPath: IndexPath) -> Bool {
        if favoriteCoinList.isEmpty == false {
            if indexPath.section == 0 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func item(for indexPath: IndexPath) -> ViewCoin {
        let index = indexPath.item
        let section = indexPath.section
        if favoriteCoinList.isEmpty == false {
            if section == 0 {
                return favoriteCoinList[index]
            } else {
                return allCoinList[index]
            }
        }
        return allCoinList[index]
    }
    
    private func getSection(listKind: ListKind) -> Int? {
        switch listKind {
        case .favorite:
            return favoriteCoinList.isEmpty ? nil : 0
        case .all:
            return favoriteCoinList.isEmpty ? 0 : 1
        }
    }
    
    func nameOfSectionHeader(index: Int) -> String? {
        let favoriteCoinListIsEmpty = favoriteCoinList.isEmpty
        let allCoinListIsEmpty = allCoinList.isEmpty

        if favoriteCoinListIsEmpty && allCoinListIsEmpty {
            return nil
        } else if favoriteCoinListIsEmpty {
            return "원화"
        } else if allCoinListIsEmpty {
            return "관심"
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
        // 여기 함수 안에 storedCoinList대신에 새로운 presentingCoinList같은거로 대체하면 해결할수있지않을까
        // WebSocket API를 생성할때 전체 symbol을 다 요청하고있는데 현재 보이는 symbol만 요청하는것도 좋을듯
        let symbols = allCoinList.map { $0.symbolName }
        print("📃 symbols", symbols)
        let api = TransactionWebSocket(symbols: symbols)
        webSocketService
            .openRx(webSocketAPI: api)
//            .debug("✅ webSocket received")
            .withUnretained(self)
            .subscribe(onNext: { owner, transactionData in
                owner.updateCell(from: &owner.allCoinList, section: owner.getSection(listKind: .all), transactionData: transactionData)
                owner.updateCell(from: &owner.favoriteCoinList, section: owner.getSection(listKind: .favorite),transactionData: transactionData)
            })
            .disposed(by: webSocketDisposeBag)
    }
    
    func closeWebSocket() {
        webSocketDisposeBag = .init()
    }
    
    private func updateCell(from coinList: inout [ViewCoin], section: Int?, transactionData: WebSocketTransactionData.WebSocketTransaction) {
        let symbol = transactionData.symbol.components(separatedBy: "_")[0]
        print("✅: ", indexPathsForVisibleCells)
        
        guard let index = coinList.firstIndex(where: { $0.symbolName == symbol }),
              let section
        else { return }
        
        let indexPath = IndexPath(item: index, section: section)
        
        guard indexPathsForVisibleCells.contains(indexPath),
              let newPrice = Double(transactionData.price)
        else { return }
        
        let oldCoin = coinList[index]
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
        coinList.remove(at: index)
        coinList.insert(newCoin, at: index)
        
        updateCell.accept((indexPath, newCoin))
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
    
    final private class CoinListController {
        final private class CoinListWithBackup {
            private var _backup: [ViewCoin]
            private var _displaying: [ViewCoin]
            
            init(coins: [ViewCoin]) {
                _displaying = coins
                _backup = _displaying
            }
        }
        
        private var _backupFavoriteCoins: [ViewCoin]
        private var _backupAllCoins: [ViewCoin]
        
        private var _favoriteCoins: [ViewCoin]
        private var _allCoins: [ViewCoin]
        
        private var __favoriteCoins: CoinListWithBackup
        private var __allCoins: CoinListWithBackup
        
        var favoriteCoins: [ViewCoin] {
            get {
                _favoriteCoins
            }
        }
        
        var allCoins: [ViewCoin] {
            get {
                _allCoins
            }
        }
        
        var currentSortButton: CoinSortButton?
        var currentFilterText: String?
        
        init(fetchedCoinList: [ViewCoin], selectedButton: CoinSortButton?) {
            var sorted = fetchedCoinList
            if let coinSortButton = selectedButton {
                sorted.sort(using: coinSortButton)
            }
            __allCoins = CoinListWithBackup(coins: sorted)
            __favoriteCoins = CoinListWithBackup(coins: []) // coredata.
            
            
            
            
            
            
            
            _allCoins = sorted
            _backupAllCoins = _allCoins
            _favoriteCoins = [] // 이부분 수정해야함 coredata 사용해야.
            _backupFavoriteCoins = _favoriteCoins
        }
        
        func getSectionModel() -> [CoinListSectionModel] {
            var sectionModel: [CoinListSectionModel] = []
            
            if _favoriteCoins.isEmpty == false {
                sectionModel.append(CoinListSectionModel(model: "관심", items: favoriteCoins))
            }
            
            if _allCoins.isEmpty == false {
                sectionModel.append(CoinListSectionModel(model: "원화", items: allCoins))
            }
            
            return sectionModel
        }
        
        func sort(using coinSortButton: CoinSortButton) {
            _backupFavoriteCoins.sort(using: coinSortButton)
            _backupAllCoins.sort(using: coinSortButton)
            _favoriteCoins.sort(using: coinSortButton)
            _allCoins.sort(using: coinSortButton)
            
            currentSortButton = coinSortButton
        }
        
        func filter(by text: String?) {
            _favoriteCoins = _backupFavoriteCoins.filter(by: text)
            _allCoins = _backupAllCoins.filter(by: text)
            
            currentFilterText = text
        }
        
        // 생각해보기 1. filter 안한 상태 2. filter 한 상태
        func favorite(indexPath: IndexPath) {
            let index = indexPath.item
            
            /// favoriteCoinList가 비어있는 경우는 무조건 좋아요 하는 경우임
            if _favoriteCoins.isEmpty {
                let coin = _allCoins[index].toggleFavorite()
                _favoriteCoins.append(coin)
                return
            }
            
            /// favoriteCoinLis가 비어있지 않은 경우는
            /// indexPath.section == 0이면 무조건 좋아요 취소 하는 경우
            /// indexPath.section == 1이면 isFavorite == true이면 좋아요 취소, 그렇지 않으면 좋아요 하는 경우
            if indexPath.section == 0 {
                let coin = _favoriteCoins[index]
                _favoriteCoins.remove(at: index)
                
                if let index = searchIndex(at: _allCoins, symbolName: coin.symbolName) {
                    _allCoins[index].toggleFavorite()
                }
                
                return
            }
            
            let isFavorite = _allCoins[index].isFavorite
            let coin = _allCoins[index].toggleFavorite()
            
            if isFavorite {
                if let index = searchIndex(at: _favoriteCoins, symbolName: coin.symbolName) {
                    _favoriteCoins.remove(at: index)
                }
            } else {
                _favoriteCoins.append(coin)
            }
        }
        
        private func searchIndex(at coinList: [ViewCoin], symbolName: String) -> Int? {
            return coinList.firstIndex { $0.symbolName == symbolName }
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
}
