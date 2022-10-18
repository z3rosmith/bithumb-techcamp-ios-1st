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

extension TickersValueObject {
    func asViewCoinList() -> [ViewCoin] {
        var viewCoinList: [ViewCoin] = []
        ticker.forEach { key, dynamicValue in
            if let tickerData = dynamicValue.tickerData {
                let viewCoin = ViewCoin(
                    callingName: NSLocalizedString(key, comment: ""),
                    symbolName: key,
                    closingPrice: Double(tickerData.closingPrice) ?? -Double.greatestFiniteMagnitude,
                    currentPrice: Double(tickerData.closingPrice) ?? -Double.greatestFiniteMagnitude,
                    changeRate: Double(tickerData.fluctateRate24Hour) ?? -Double.greatestFiniteMagnitude,
                    changePrice: Double(tickerData.fluctate24Hour) ?? -Double.greatestFiniteMagnitude,
                    popularity: Double(tickerData.accTradeValue24Hour) ?? -Double.greatestFiniteMagnitude,
                    changePriceStyle: .none,
                    isFavorite: false
                )
                viewCoinList.append(viewCoin)
            }
        }
        return viewCoinList
    }
}

// MARK: - DynamicValue

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

// MARK: - TickerData

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
