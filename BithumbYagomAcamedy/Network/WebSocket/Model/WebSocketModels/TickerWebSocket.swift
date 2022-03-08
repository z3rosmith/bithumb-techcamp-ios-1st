//
//  TicketWebSocket.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation

struct TickerWebSocket: WebSocketable {
       
    // MARK: - Property
    
    private(set) var url: URL?
    private(set) var message: Data
    
    // MARK: - Init
    
    init(
        symbol: String,
        tickType: TickType? = .hour24,
        url: BithumbWebSocketURL = BithumbWebSocketURL()
    ) {
        self.url = URL(string: url.baseURL)
        self.message = WebSocketMessageConverter().data(
            type: .ticker,
            symbol: symbol,
            tickType: tickType
        )
    }
    
    init?(symbol: String, dateFormat: ChartDateFormat) {
        let tickType: TickType
        
        switch dateFormat {
        case .minute1, .minute10:
            return nil
        case .minute30:
            tickType = .minute30
        case .hour1:
            tickType = .hour1
        case .hour24:
            tickType = .hour24
        }
        
        self.init(symbol: symbol, tickType: tickType)
    }
}
