//
//  CoinListViewModel.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/07/10.
//

import Foundation
import RxSwift
import RxRelay

class CoinListViewModel: ViewModelType {
    struct Input {
        let fetchCoinList: AnyObserver<Void>
        let sortCoin: AnyObserver<CoinSortButton>
        let filterCoin: AnyObserver<String?>
    }
    
    struct Output {
        let coinList: Observable<[ViewCoin]>
    }
    
    var disposeBag: DisposeBag = .init()
    
    let input: Input
    let output: Output
    
    private let coinSortButtons: [CoinSortButton]
    private var storedCoinList: [ViewCoin]
    private var selectedButton: CoinSortButton?
    private let anyButtonTapped: BehaviorRelay<CoinSortButton?>
    
    init(
        httpNetworkService: HTTPNetworkService = .init(),
        webSocketService: WebSocketService = .init(),
        sortButtons: [SortButton],
        sortButtonTypes: [CoinSortButton.ButtonType]
    ) {
        let fetching = PublishSubject<Void>()
        let coins = BehaviorRelay<[ViewCoin]>(value: [])
        let sort = PublishSubject<CoinSortButton>()
        let filter = PublishSubject<String?>()
        
        input = Input(
            fetchCoinList: fetching.asObserver(),
            sortCoin: sort.asObserver(),
            filterCoin: filter.asObserver()
        )
        
        output = Output(
            coinList: coins.asObservable()
        )
        
        coinSortButtons = sortButtons.enumerated().map { index, sortButton in
            CoinSortButton(button: sortButton, buttonType: sortButtonTypes[index])
        }
        
        storedCoinList = []
        
        selectedButton = coinSortButtons.first
        
        anyButtonTapped = .init(value: coinSortButtons.first)
        
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
                coins.accept(sorted)
                owner.storedCoinList = sorted
            })
            .disposed(by: disposeBag)
        
        sort
            .withUnretained(self)
            .subscribe(onNext: { owner, coinSortButton in
                let sorted = coins.value.sorted(using: coinSortButton)
                coins.accept(sorted)
                owner.storedCoinList = sorted
            })
            .disposed(by: disposeBag)
        
        filter
            .withUnretained(self)
            .subscribe(onNext: { owner, filterText in
                let filtered = owner.storedCoinList.filter(by: filterText)
                coins.accept(filtered)
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
