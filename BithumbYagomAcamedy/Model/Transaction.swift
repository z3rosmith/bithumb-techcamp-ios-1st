//
//  Transaction.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/01.
//

import Foundation

enum TransactionType {
    case bid
    case ask
}

struct Transaction {
    
    // MARK: - Property
    
    private(set) var date: String
    private(set) var type: TransactionType
    private(set) var price: String
    private(set) var quantity: String
}

// MARK: - Computed Property

extension Transaction {
    var convertedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = formatter.date(from: date) else {
            return String()
        }
        
        formatter.dateFormat = "HH:mm:ss"
        
        return formatter.string(from: date)
    }
}
