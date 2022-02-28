//
//  TicketWebSocket.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation



struct TickerWebSocket: WebSocketable {
       
    // MARK: - Property
    
    var url: URL?
    var message: Data
    
    // MARK: - Init
    
    init(
        symbol: String,
        tickType: TickType = .minute30,
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
