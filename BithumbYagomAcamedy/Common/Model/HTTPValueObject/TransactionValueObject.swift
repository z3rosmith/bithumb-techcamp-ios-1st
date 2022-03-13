//
//  TransactionValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/24.
//

import Foundation

struct TransactionValueObject: Decodable {
    let status: String
    let transaction: [TransactionData]
    
    enum CodingKeys: String, CodingKey {
        case status
        case transaction = "data"
    }
}

struct TransactionData: Decodable {
    let transactionDate: String
    let type: String
    let unitsTraded: String
    let price: String
    let total: String
}

// MARK: - Generate

extension TransactionData {
    func generate() -> Transaction {
        let type = convert(type: type)
        
        return Transaction(
            date: transactionDate,
            type: type,
            price: price,
            quantity: unitsTraded
        )
    }
    
    private func convert(type: String) -> TransactionType {
        return type == "bid" ? .bid : .ask
    }
}
