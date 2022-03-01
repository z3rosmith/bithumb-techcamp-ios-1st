//
//  TransactionWebSocket.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/01.
//

import Foundation

struct TransactionWebSocket: WebSocketable {
       
    // MARK: - Property
    
    private(set) var url: URL?
    private(set) var message: Data
    
    // MARK: - Init
    
    init(
        symbol: String,
        url: BithumbWebSocketURL = BithumbWebSocketURL()
    ) {
        self.url = URL(string: url.baseURL)
        self.message = WebSocketMessageConverter().data(
            type: .transaction,
            symbol: symbol
        )
    }
}
