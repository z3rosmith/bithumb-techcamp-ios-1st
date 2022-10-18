//
//  CoinListViewModel.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/07/10.
//

import Foundation
import RxSwift
import RxRelay

final class CoinListViewModel: ViewModelType {
    
    enum Section: Int {
        case favorite
        case all
    }
    
    struct Input {
        let fetchCoinList: AnyObserver<Void>
        let sortCoin: AnyObserver<CoinSortButton>
        let filterCoin: AnyObserver<String?>
    }
    
    struct Output {
        let coinList: Observable<[ViewCoin]>
        let coinChanged: Observable<Void>
        let updateCell: Observable<(Int, ViewCoin)>
    }
    
    var disposeBag: DisposeBag = .init()
    var webSocketDisposeBag: DisposeBag = .init()
    
    private let webSocketService: WebSocketService
    private let coinSortButtons: [CoinSortButton]
    private var storedCoinList: [ViewCoin]
    private var selectedButton: CoinSortButton?
    private let anyButtonTapped: BehaviorRelay<CoinSortButton?>
    private let coins: BehaviorRelay<[ViewCoin]>
    private let updateCell: PublishRelay<(Int, ViewCoin)>
    var indexForVisibleCells: [Int]
    
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
        
        self.webSocketService = webSocketService
        self.coinSortButtons = sortButtons.enumerated().map { index, sortButton in
            CoinSortButton(button: sortButton, buttonType: sortButtonTypes[index])
        }
        self.storedCoinList = []
        self.selectedButton = coinSortButtons.first
        self.anyButtonTapped = .init(value: coinSortButtons.first)
        self.coins = .init(value: [])
        self.updateCell = .init()
        self.indexForVisibleCells = []
        
        self.input = Input(
            fetchCoinList: fetching.asObserver(),
            sortCoin: sort.asObserver(),
            filterCoin: filter.asObserver()
        )
        
        let coinChanged = Observable.merge(
            fetching,
            sort.map { _ in },
            filter.map { _ in }
        )
        
//        let coinsToCoinList = PublishRelay<[SectionOfViewCoin]>()
//
//        coins
//            .subscribe(onNext: { coins in
//                let sectionOfViewCoin = SectionOfViewCoin(items: coins)
//                coinsToCoinList.accept([sectionOfViewCoin])
//            })
//            .disposed(by: disposeBag)
        
        self.output = Output(
            coinList: coins.asObservable(),
            coinChanged: coinChanged,
            updateCell: updateCell.asObservable()
        )
        
        // INPUT
        
        fetching
            .flatMap { httpNetworkService.fetchRx(api: TickerAPI(), type: TickersValueObject.self) }
            .map { $0.asViewCoinList() }
            .withUnretained(self)
            .subscribe(onNext: { owner, coinList in
                var sorted = coinList
                if let coinSortButton = owner.selectedButton {
                    sorted = coinList.sorted(using: coinSortButton)
                }
                owner.storedCoinList = sorted
                owner.coins.accept(sorted)
            })
            .disposed(by: disposeBag)
        
        sort
            .withUnretained(self)
            .subscribe(onNext: { owner, coinSortButton in
                let sorted = owner.storedCoinList.sorted(using: coinSortButton)
                owner.storedCoinList = sorted
                owner.coins.accept(sorted)
            })
            .disposed(by: disposeBag)
        
        filter
            .withUnretained(self)
            .subscribe(onNext: { owner, filterText in
                let filtered = owner.storedCoinList.filter(by: filterText)
                owner.coins.accept(filtered)
            })
            .disposed(by: disposeBag)
        
        coinSortButtons.forEach { coinSortButton in
            let button = coinSortButton.button
            let sortType = coinSortButton.sortType
            
            button.rx.tap
                .map { coinSortButton }
                .withUnretained(self)
                .subscribe(onNext: { owner, coinSortButton in
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
                .asDriver(onErrorJustReturn: .none)
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
        
        // OUTPUT
    }
}

extension CoinListViewModel {
    func openWebSocket() {
        closeWebSocket()
        let symbols = storedCoinList.map { $0.symbolName }
        print("📃 symbols", symbols)
        // symbols를 현재 화면에 보이는 것만 해서 api를 만들 수는 없을까
        let api = TransactionWebSocket(symbols: symbols)
        webSocketService
            .openRx(webSocketAPI: api)
//            .debug("✅ webSocket received")
            .withUnretained(self)
            .subscribe(onNext: { owner, transactionData in
                var newCoinList = owner.storedCoinList
                let (index, newCoin) = owner.updateCoinListAndReturnIndexNCoin(coinList: &newCoinList, transactionData: transactionData)
                owner.storedCoinList = newCoinList
                if let index, let newCoin {
                    owner.updateCell.accept((index, newCoin))
                }
            })
            .disposed(by: webSocketDisposeBag)
    }
    
    func closeWebSocket() {
        webSocketDisposeBag = .init()
    }
    
    private func updateCoinListAndReturnIndexNCoin(coinList: inout [ViewCoin], transactionData: WebSocketTransactionData.WebSocketTransaction) -> (Int?, ViewCoin?) {
        let symbol = transactionData.symbol.components(separatedBy: "_")[0]
        print("✅: ", indexForVisibleCells)
        if let index = coinList.firstIndex(where: { $0.symbolName == symbol }),
           indexForVisibleCells.contains(index),
           let newPrice = Double(transactionData.price) {
            
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
            return (index, newCoin)
        } else { // 코인리스트에 들어온 웹소켓의 코인이 없거나, 들어온 웹소켓의 코인이 있었음에도 visible cell이 아니었거나, visiblecell에 있었는데 price를 Double로 변환할 수 없었을 때
            indexForVisibleCells.forEach { index in
                let newCoin = coinList[index].updateChangePriceStyleToNone()
                coinList.remove(at: index)
                coinList.insert(newCoin, at: index)
            }
            return (nil, nil)
        }
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
