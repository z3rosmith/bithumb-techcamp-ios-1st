//
//  CoinListDataSource.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import Foundation

class CoinListDataSource {
    
    // MARK: - Nested Type
    
    struct Coin: Hashable {
        let callingName: String
        let symbolName: String
        let price: Int
        let changeRate: Double
        let changePrice: Int
        let identifier = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: Coin, rhs: Coin) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
}

extension CoinListDataSource.Coin {
    var symbolPerKRW: String {
        return symbolName + "/KRW"
    }
    
    var priceString: String {
        return "\(price)"
    }
    
    var changeRateString: String {
        return "\(changeRate)"
    }
    
    var changePriceString: String {
        return "\(changePrice)"
    }
}
