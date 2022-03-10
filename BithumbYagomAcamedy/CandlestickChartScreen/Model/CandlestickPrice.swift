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
    
    var isIncreasePrice: Bool {
        return `open` - close < Double.zero ? true : false
    }
    
    var isDecreasePrice: Bool {
        return `open` - close > Double.zero ? true : false
    }
    
    var isEqualPrice: Bool {
        return `open` - close == Double.zero ? true : false
    }
    
    var priceString: String {
        "시 \(Int(open)) 고 \(Int(high)) 저 \(Int(low)) 종 \(Int(close))"
    }
}
