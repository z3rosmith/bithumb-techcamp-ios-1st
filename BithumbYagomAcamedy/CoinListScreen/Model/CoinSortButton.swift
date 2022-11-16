//
//  CoinSortButton.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/11/16.
//

import RxRelay

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
