//
//  ViewCoin.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/07/10.
//

struct ViewCoin {
    enum ChangeStyle {
        case none, up, down
    }
    
    let callingName: String
    let symbolName: String
    let closingPrice: Double
    let currentPrice: Double
    let changeRate: Double
    let changePrice: Double
    let popularity: Double
    let changePriceStyle: ChangeStyle
    let isFavorite: Bool
    
    func updated(newPrice: Double, newChangeRate: Double, newChangePrice: Double, changePriceStyle: ChangeStyle) -> ViewCoin {
        return ViewCoin(
            callingName: self.callingName,
            symbolName: self.symbolName,
            closingPrice: self.closingPrice,
            currentPrice: newPrice,
            changeRate: newChangeRate,
            changePrice: newChangePrice,
            popularity: self.popularity,
            changePriceStyle: changePriceStyle,
            isFavorite: self.isFavorite
        )
    }
    
    func updateChangePriceStyleToNone() -> ViewCoin {
        return ViewCoin(
            callingName: self.callingName,
            symbolName: self.symbolName,
            closingPrice: self.closingPrice,
            currentPrice: self.currentPrice,
            changeRate: self.changeRate,
            changePrice: self.changePrice,
            popularity: self.popularity,
            changePriceStyle: .none,
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
