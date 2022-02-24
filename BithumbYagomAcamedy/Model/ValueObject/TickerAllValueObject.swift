//
//  TickerAllValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/24.
//

import Foundation

struct TickerAllValueObject: Decodable {
    let status: String
    let data: [String: QuantumValue]
}

enum QuantumValue: Decodable {
    case string(String), tickerData(TickerData)
    
    init(from decoder: Decoder) throws {
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        if let tickerData = try? decoder.singleValueContainer().decode(TickerData.self) {
            self = .tickerData(tickerData)
            return
        }
        
        throw QuantumError.missingValue
    }
    
    enum QuantumError:Error {
        case missingValue
    }
}

struct TickerData: Decodable {
    let openingPrice: String
    let closingPrice: String
    let minPrice: String
    let maxPrice: String
    let unitsTraded: String
    let accTradeValue: String
    let prevClosingPrice: String
    let unitsTraded24Hour: String
    let accTradeValue24Hour: String
    let fluctate24Hour: String
    let fluctateRate24Hour: String
    let date: String?

    enum CodingKeys: String, CodingKey {
        case openingPrice
        case closingPrice
        case minPrice
        case maxPrice
        case unitsTraded
        case accTradeValue
        case prevClosingPrice
        case date
        
        case unitsTraded24Hour = "unitsTraded24H"
        case accTradeValue24Hour = "accTradeValue24H"
        case fluctate24Hour = "fluctate24H"
        case fluctateRate24Hour = "fluctateRate24H"
    }
}

extension QuantumValue {
    
    var tickerData: TickerData? {
        switch self {
        case .tickerData(let tickerData):
            return tickerData
        default:
            return nil
        }
    }
    
    var string: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
}
