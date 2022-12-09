//
//  CoinSortType.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/11/16.
//

import RxRelay

struct CoinSortType: Equatable {
    let buttonType: CoinSortButtonType
    let sortOrderType: BehaviorRelay<CoinSortOrderType> = .init(value: .none)
    
    static func == (lhs: CoinSortType, rhs: CoinSortType) -> Bool {
        return lhs.buttonType == rhs.buttonType
    }
}

enum CoinSortButtonType {
    case popularity
    case name
    case price
    case changeRate
}
