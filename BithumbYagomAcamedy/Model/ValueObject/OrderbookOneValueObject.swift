//
//  OrderbookOneValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/24.
//

import Foundation

struct OrderbookOneValueObject: Decodable {
    let status: String
    let data: OrderbookData
}

struct OrderbookData: Decodable {
    let timestamp: String
    let paymentCurrency: String
    let orderCurrency: String
    let bids: [BidData]
    
    struct BidData: Decodable {
        let price: String
        let quantity: String
    }
}
