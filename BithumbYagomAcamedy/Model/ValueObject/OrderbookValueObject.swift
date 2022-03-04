//
//  OrderbookValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/24.
//

import Foundation

struct OrderbookValueObject: Decodable {
    let status: String
    let orderbook: OrderbookData
    
    enum CodingKeys: String, CodingKey {
        case status
        case orderbook = "data"
    }
}

struct OrderbookData: Decodable {
    let timestamp: String
    let paymentCurrency: String
    let orderCurrency: String
    let bids: [Order]
    let asks: [Order]
    
    struct Order: Decodable {
        let price: String
        let quantity: String
    }
}

// MARK: - Generate

extension OrderbookData.Order {
    func generate() -> Orderbook {
        return Orderbook(price: price, quantity: quantity)
    }
}
