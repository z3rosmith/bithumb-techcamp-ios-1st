//
//  DetailViewCoin.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/05.
//

import Foundation

struct DetailViewCoin {
    private let name: String
    private(set) var price: Double?
    private(set) var changePrice: Double?
    private(set) var changeRate: Double?
    
    // MARK: - Init
    
    init(
        name: String,
        price: Double?,
        changePrice: Double?,
        changeRate: Double?
    ) {
        self.name = name
        self.price = price
        self.changePrice = changePrice
        self.changeRate = changeRate
    }
    
    // MARK: - Method
    
    mutating func setPrice(_ price: Double?) {
        self.price = price
    }
    
    mutating func setChangePrice(_ changePrice: Double?) {
        self.changePrice = changePrice
    }
    
    mutating func setChangeRate(_ changeRate: Double?) {
        self.changeRate = changeRate
    }
}

// MARK: - DetailViewCoin Computed Property

extension DetailViewCoin {
    var symbol: String {
        return name
    }
    
    var commaPrice: String {
        guard let price = price else {
            return "오류 발생"
        }
        
        return price.commaPrice
    }
    
    var changePriceString: String {
        guard let changePrice = changePrice else {
            return "오류 발생"
        }
        
        let commaChangePrice = changePrice.commaPrice
        
        if changePrice > 0 {
            return "+" + commaChangePrice
        }
        
        return commaChangePrice
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
