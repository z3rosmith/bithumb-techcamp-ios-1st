//
//  CoinDetailDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/03.
//

import Foundation

protocol CoinDetailDataManagerDelegate: AnyObject {
    func coinDetailDataManager(didChange coin: CoinDetailDataManager.DetailViewCoin)
}

final class CoinDetailDataManager {
    
    // MARK: - Nested Type
    
    struct DetailViewCoin {
        var price: Double
        var changePrice: Double
        var changeRate: Double
    }
    
    // MARK: - Property
    
    weak var delegate: CoinDetailDataManagerDelegate?
    
}
