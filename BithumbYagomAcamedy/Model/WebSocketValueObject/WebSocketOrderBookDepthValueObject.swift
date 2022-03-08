//
//  WebSocketOrderBookDepth.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/01.
//

import Foundation

struct WebSocketOrderBookDepthValueObject: Decodable {
    let type: String
    let webSocketOrderBookDepthData: WebSocketOrderBookDepthData
    
    enum CodingKeys: String, CodingKey {
        case type
        case webSocketOrderBookDepthData = "content"
    }
}

struct WebSocketOrderBookDepthData: Decodable {
    let list: [OrderBookDepthData]
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case list
        case date = "datetime"
    }
    
    struct OrderBookDepthData: Decodable {
        let symbol: String
        let orderType: OrderType
        let price: String
        let quantity: String
        let total: String
    }

    enum OrderType: String, Decodable {
        case ask = "ask"
        case bid = "bid"
    }
}

extension WebSocketOrderBookDepthData {
    var bids: [OrderBookDepthData] {
        return list.filter { $0.orderType == .bid }
    }
    
    var asks: [OrderBookDepthData] {
        return list.filter { $0.orderType == .ask }
    }
}

extension WebSocketOrderBookDepthData.OrderBookDepthData {
    func generate() -> Orderbook {
        let type = convert(type: orderType)
        
        return Orderbook(
            price: price,
            quantity: quantity,
            type: type
        )
    }
    
    private func convert(type: WebSocketOrderBookDepthData.OrderType) -> OrderbookType {
        return type == .bid ? .bid : .ask
    }
}
