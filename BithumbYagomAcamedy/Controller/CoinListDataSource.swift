//
//  CoinListDataSource.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import Foundation

class CoinListDataSource {
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
