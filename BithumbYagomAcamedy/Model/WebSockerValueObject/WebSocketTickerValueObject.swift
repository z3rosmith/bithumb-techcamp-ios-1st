//
//  WebSocketTickerValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/01.
//

import Foundation

struct WebSocketTickerValueObjcet: Decodable {
    let type: String
    let webSocketTickerData: WebSocketTickerData
    
    enum CodingKeys: String, CodingKey {
        case type
        case webSocketTickerData = "content"
    }
}

struct WebSocketTickerData: Decodable {
    let symbol: String
    let tickType: String
    let date: String
    let time: String
    let openPrice: String
    let closePrice: String
    let lowPrice: String
    let highPrice: String
    let value: String
    let volume: String
    let sellVolume: String
    let buyVolume: String
    let previousClosePrice: String
    let changeRate: String
    let changePrice: String
    let volumePower: String
    
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case tickType
        case date
        case time
        case openPrice
        case closePrice
        case lowPrice
        case highPrice
        case value
        case volume
        case sellVolume
        case buyVolume
        case volumePower
        case previousClosePrice = "prevClosePrice"
        case changeRate = "chgRate"
        case changePrice = "chgAmt"
    }
}
