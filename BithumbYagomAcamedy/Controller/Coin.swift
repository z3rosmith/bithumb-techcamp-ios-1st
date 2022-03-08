//
//  Coin.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/03/04.
//

import Foundation

struct Coin: Hashable {
    let callingName: String
    let symbolName: String
    var currentPrice: Double?
    var changeRate: Double?
    var changePrice: Double?
    var popularity: Double?
    var isFavorite: Bool
    let identifier = UUID()
    
    init(
        callingName: String,
        symbolName: String,
        currentPrice: Double?,
        changeRate: Double?,
        changePrice: Double?,
        popularity: Double?,
        isFavorite: Bool
    ) {
        self.callingName = callingName
        self.symbolName = symbolName
        self.currentPrice = currentPrice
        self.changeRate = changeRate
        self.changePrice = changePrice
        self.popularity = popularity
        self.isFavorite = isFavorite
    }
    
    init(toggleFavorite coin: Coin) {
        self.callingName = coin.callingName
        self.symbolName = coin.symbolName
        self.currentPrice = coin.currentPrice
        self.changeRate = coin.changeRate
        self.changePrice = coin.changePrice
        self.popularity = coin.popularity
        self.isFavorite = !coin.isFavorite
    }
}

// MARK: - Coin Computed Property

extension Coin {
    var symbolPerKRW: String {
        return symbolName + "/KRW"
    }
    
    var priceString: String {
        return currentPrice?.commaPrice ?? "오류 발생"
    }
    
    var changePriceString: String {
        guard let changePrice = changePrice else {
            return "오류 발생"
        }
        
        return changePrice.changePriceString
    }
    
    var changeRateString: String {
        guard let changeRate = changeRate else {
            return "오류 발생"
        }
        
        return changeRate.changeRateString
    }
}
