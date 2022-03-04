//
//  Orderbook.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import Foundation

struct Orderbook: Hashable {
    
    // MARK: - Property
    
    private(set) var price: String
    private(set) var quantity: String
    private let uuid: UUID = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    static func == (lhs: Orderbook, rhs: Orderbook) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

// MARK: - Computed Property

extension Orderbook {
    var commaPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let price = Double(price)
        
        return formatter.string(for: price) ?? String()
    }
    
    var roundedQuantity: String {
        if let quantity = Double(quantity) {
            let digit: Double = pow(10, 5)
            let roundedQuantity = round(quantity * digit) / digit
            
            return String(roundedQuantity)
        }
        
        return String()
    }
}
