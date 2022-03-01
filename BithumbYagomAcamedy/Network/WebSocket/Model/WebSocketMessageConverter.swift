//
//  WebSocketMessageConverter.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation

// MARK: - WebSocketType

enum WebSocketType: CustomStringConvertible {
    case ticker
    case transaction
    case orderbookdepth
    
    var description: String {
        switch self {
        case .ticker:
            return "ticker"
        case .transaction:
            return "transaction"
        case .orderbookdepth:
            return "orderbookdepth"
        }
    }
}

// MARK: - TickType

enum TickType: CustomStringConvertible {
    case minute30
    case hour1
    case hour12
    case hour24
    case month
    
    var description: String {
        switch self {
        case .minute30:
            return "30M"
        case .hour1:
            return "1H"
        case .hour12:
            return "12H"
        case .hour24:
            return "24H"
        case .month:
            return "MID"
        }
    }
}

// MARK: - WebSocketMessageConverter

struct WebSocketMessageConverter {
    
    // MARK: - Method
    
    func data(
        type: WebSocketType,
        symbol: String,
        tickType: TickType? = nil
    ) -> Data {
        var message = #"{"type":"\#(type)", "symbols":["\#(symbol)_KRW"]"#
        
        if let tickType = tickType {
            message += #", "tickTypes": ["\#(tickType)" ]"#
        }
        
        message += "}"
        
        return message.data(using: .utf8) ?? Data()
    }
}
