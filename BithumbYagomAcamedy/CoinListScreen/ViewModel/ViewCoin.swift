//
//  ViewCoin.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/07/10.
//

import Foundation

struct ViewCoin {
    let callingName: String
    let symbolName: String
    let currentPrice: Double
    let changeRate: Double
    let changePrice: Double
    let popularity: Double
    let isFavorite: Bool
    
    func currentPriceUpdated(currentPrice: Double) -> ViewCoin {
        return ViewCoin(
            callingName: self.callingName,
            symbolName: self.symbolName,
            currentPrice: currentPrice,
            changeRate: self.changeRate,
            changePrice: self.changePrice,
            popularity: self.popularity,
            isFavorite: self.isFavorite
        )
    }
}

extension ViewCoin {
    var symbolPerKRW: String {
        return symbolName + "/KRW"
    }
    
    var priceString: String {
        return currentPrice.commaPrice
    }
    
    var changePriceString: String {
        return changePrice.changePriceString
    }
    
    var changeRateString: String {
        return changeRate.changeRateString
    }
}
