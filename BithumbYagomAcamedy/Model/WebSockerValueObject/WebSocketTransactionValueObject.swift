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
        let type: TransactionType
        let price: String
        let quantity: String
        let amount: String
        let date: String
        let updown: PriceUpDown

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
    
    enum TransactionType: String, Decodable {
        case ask = "1"
        case bid = "2"
    }
    
    enum PriceUpDown: String, Decodable {
        case up = "up"
        case down = "dn"
    }
}

// MARK: - Generate

extension WebSocketTransactionData.WebSocketTransaction {
    func generate() -> Transaction {
        let type = convert(type: type)
        let removedMillisecondDate = removeMillisecond(date: date)
        
        return Transaction(
            date: removedMillisecondDate,
            type: type,
            price: price,
            quantity: quantity
        )
    }
    
    private func convert(type: WebSocketTransactionData.TransactionType) -> TransactionType {
        return type == .bid ? .bid : .ask
    }
    
    private func removeMillisecond(date: String) -> String {
        if let removedMillisecondDate = date.components(separatedBy: ".").first {
            return removedMillisecondDate
        }
        
        return String()
    }
}
