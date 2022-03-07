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
}
