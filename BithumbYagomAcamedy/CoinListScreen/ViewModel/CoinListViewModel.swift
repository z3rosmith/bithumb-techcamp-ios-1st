//
//  CoinListViewModel.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/07/10.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

class CoinListViewModel: ViewModelType {
    struct Input {
        let fetchCoinList: AnyObserver<Void>
        let sortCoin: AnyObserver<CoinSortButton>
    }
    
    struct Output {
        let coinList: Observable<[ViewCoin]>
    }
    
    var disposeBag = DisposeBag()
    
    let input: Input
    let output: Output
    
    let coinSortButtons: [CoinSortButton]
    var selectedButton: BehaviorRelay<SortButton?>
    var anyButtonTapped: PublishRelay<CoinSortButton>
    
    init(
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService(),
        sortButtons: [SortButton],
        sortButtonTypes: [CoinSortButton.ButtonType]
    ) {
        let fetching = PublishSubject<Void>()
        let coins = BehaviorRelay<[ViewCoin]>(value: [])
        let sort = PublishSubject<CoinSortButton>()
        
        input = Input(
            fetchCoinList: fetching.asObserver(),
            sortCoin: sort.asObserver()
        )
        
        output = Output(
            coinList: coins.asObservable()
        )
        
        coinSortButtons = sortButtons.enumerated().map { index, sortButton in
            CoinSortButton(button: sortButton, buttonType: sortButtonTypes[index])
        }
        
        selectedButton = .init(value: coinSortButtons.first?.button)
        
        anyButtonTapped = .init()
        
        // INPUT
        
        fetching
            .flatMap { httpNetworkService.fetchRx(api: TickerAPI(), type: TickersValueObject.self) }
            .map { $0.asViewCoinList() }
            .subscribe(onNext: coins.accept)
            .disposed(by: disposeBag)
        
        sort
            .subscribe(onNext: { coinSortButton in
                let sorted = coins.value.sorted(using: coinSortButton)
                coins.accept(sorted)
            })
            .disposed(by: disposeBag)
        
        coinSortButtons.forEach { coinSortButton in
            let button = coinSortButton.button
            let imageName = coinSortButton.imageName
            let sortType = coinSortButton.sortType
            
            button.rx.tap
                .map { button }
                .bind(to: selectedButton)
                .disposed(by: disposeBag)
            
            button.rx.tap
                .withUnretained(self)
                .flatMap { owner, _ in
                    Observable.from(owner.coinSortButtons)
                }
                .bind(to: anyButtonTapped)
                .disposed(by: disposeBag)
            
            imageName
                .asDriver(onErrorJustReturn: "")
                .drive(onNext: { name in
                    button.setImage(UIImage(named: name), for: .normal)
                })
                .disposed(by: disposeBag)
            
            sortType
                .withUnretained(self)
                .subscribe(onNext: { owner, type in
                    imageName.accept(type.rawValue)
                })
                .disposed(by: disposeBag)
        }
        
        anyButtonTapped
            .withUnretained(self)
            .map { owner, eachButton -> (CoinSortType, CoinSortButton) in
                let isSelected = eachButton.button == owner.selectedButton.value
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
                eachButton.sortType.accept(sortType)
                if sortType != .none {
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
        let imageName: PublishRelay<String> = .init()
    }
}

// MARK: - Extension Of Array

private extension Array where Element == ViewCoin {
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
}
