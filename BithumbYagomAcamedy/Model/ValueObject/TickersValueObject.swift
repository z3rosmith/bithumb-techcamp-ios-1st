//
//  TickersValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/24.
//

import Foundation

struct TickersValueObject: Decodable {
    let status: String
    let ticker: [String: DynamicValue]
    
    enum CodingKeys: String, CodingKey {
        case status
        case ticker = "data"
    }
}

enum DynamicValue: Decodable {
    case string(String)
    case tickerData(TickerData)
    
    init(from decoder: Decoder) throws {
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        if let tickerData = try? decoder.singleValueContainer().decode(TickerData.self) {
            self = .tickerData(tickerData)
            return
        }
        
        throw DynamicError.noMatchingType
    }
    
    enum DynamicError: Error {
        case noMatchingType
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

#warning("의견 필요")
extension TickerData {
    var accTradeValue24HourDouble: Double {
        return Double(accTradeValue24Hour) ?? -1 // 의견 필요
    }
    
    var fluctate24HourDouble: Double {
        return Double(fluctate24Hour) ?? -1 // 의견 필요
    }
    
    var fluctateRate24HourDouble: Double {
        return Double(fluctateRate24Hour) ?? -1.0 // 의견 필요
    }
}

extension DynamicValue {
    var tickerData: TickerData? {
        if case let .tickerData(tickerData) = self {
            return tickerData
        }
        return nil
    }
    
    var dateString: String? {
        if case let .string(string) = self {
            return string
        }
        return nil
    }
}
