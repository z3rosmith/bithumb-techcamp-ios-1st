//
//  Orderbook.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import Foundation

enum OrderbookType {
    case bid
    case ask
}

struct Orderbook: Hashable {
    
    // MARK: - Property
    
    private(set) var price: String
    private(set) var quantity: String
    private(set) var type: OrderbookType
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
        return Double(price)?.commaPrice ?? "오류 발생"
    }
    
    var roundedQuantity: String {
        return Double(quantity)?.roundedQuantity ?? "오류 발생"
    }
}
