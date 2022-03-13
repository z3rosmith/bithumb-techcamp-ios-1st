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
    
    func data(
        type: WebSocketType,
        symbols: [String],
        tickType: TickType? = nil
    ) -> Data {
        let symbolsTransformed = symbols.map { "\"\($0)_KRW\"" }.joined(separator: ", ")
        
        var message = #"{"type":"\#(type)", "symbols":[\#(symbolsTransformed)]"#
        
        if let tickType = tickType {
            message += #", "tickTypes": ["\#(tickType)" ]"#
        }
        
        message += "}"
        
        return message.data(using: .utf8) ?? Data()
    }
}
