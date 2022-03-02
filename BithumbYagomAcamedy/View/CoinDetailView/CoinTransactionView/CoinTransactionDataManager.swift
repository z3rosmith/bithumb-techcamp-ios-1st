//
//  CoinTransactionDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/02.
//

import Foundation

final class CoinTransactionDataManager {
    
    // MARK: - Property
    
    private let httpNetworkService: HTTPNetworkService
    private let webSocketService: WebSocketService
    private var coinTransactions: [Transaction] = []
    
    // MARK: - Init
    
    init(
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService()
    ) {
        self.httpNetworkService = httpNetworkService
        self.webSocketService = webSocketService
    }
}
