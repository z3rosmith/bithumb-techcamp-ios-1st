//
//  WebSocketTransactionValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/01.
//

import Foundation

struct WebSocketTransactionValueObject: Decodable {
    let type: String
    let webSocketTransactionData: WebSocketTransactionData
    
    enum CodingKeys: String, CodingKey {
        case type
        case webSocketTransactionData = "content"
    }
}

struct WebSocketTransactionData: Decodable {
    let list: [WebSocketTransaction]
    
    struct WebSocketTransaction: Decodable {
        let symbol: String
        let type: String
        let price: String
        let quantity: String
        let amount: String
        let date: String
        let updown: String

        enum CodingKeys: String, CodingKey {
            case symbol
            case type = "buySellGb"
            case price = "contPrice"
            case quantity = "contQty"
            case amount = "contAmt"
            case date = "contDtm"
            case updown = "updn"
        }
    }
}
