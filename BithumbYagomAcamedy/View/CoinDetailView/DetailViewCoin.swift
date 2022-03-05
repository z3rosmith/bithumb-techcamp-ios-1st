//
//  DetailViewCoin.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/05.
//

import Foundation

struct DetailViewCoin {
    let name: String
    var price: Double?
    var changePrice: Double?
    var changeRate: Double?
    
    // MARK: - DetailViewCoin Computed Property
    
    var commaPrice: String {
        guard let price = price else {
            return "오류 발생"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter.string(for: price) ?? "오류 발생"
    }
    
    var changePriceString: String {
        guard let changePrice = changePrice else {
            return "오류 발생"
        }
        
        if changePrice > 0 {
            return "+" + String(changePrice)
        }
        
        return String(changePrice)
    }
    
    var changeRateString: String {
        guard let changeRate = changeRate else {
            return "오류 발생"
        }
        
        if changeRate > 0 {
            return "+" + String(changeRate) + "%"
        }
        
        return String(changeRate) + "%"
    }
}
