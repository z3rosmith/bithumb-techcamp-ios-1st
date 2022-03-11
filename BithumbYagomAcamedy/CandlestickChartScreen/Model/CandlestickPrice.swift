//
//  CandlestickPrice.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/10.
//

import Foundation

struct CandlestickPrice {
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    
    var prices: [Double] {
        return [open, high, low, close]
    }
    
    var pricesString: [String] {
        var pricesString: [String] = []
        
        prices.forEach { price in
            let removedPriceDecimalPoint = Int(price)
            let priceDecimal = price - Double(removedPriceDecimalPoint)
            
            if priceDecimal == Double.zero {
                pricesString.append(String(removedPriceDecimalPoint))
            } else {
                pricesString.append(String(price))
            }
        }
        
        return pricesString
    }
    
    var priceInformation: String {
        return String(format: "시 %@ 고 %@ 저 %@ 종 %@", arguments: pricesString)
    }
    
    var isIncreasePrice: Bool {
        return `open` - close < Double.zero ? true : false
    }
    
    var isDecreasePrice: Bool {
        return `open` - close > Double.zero ? true : false
    }
    
    var isEqualPrice: Bool {
        return `open` - close == Double.zero ? true : false
    }
}
