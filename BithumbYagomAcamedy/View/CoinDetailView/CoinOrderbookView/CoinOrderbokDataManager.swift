//
//  CoinOrderbokDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import Foundation

protocol CoinOrderbookDataManagerDelegate: AnyObject {
    func coinOrderbookDataManager(didChange orderbook: [Any])
}

final class CoinOrderbookDataManager {
    
    // MARK: - Property
    weak var delegate: CoinOrderbookDataManagerDelegate?
    private let httpNetworkService: HTTPNetworkService
    private var webSocketService: WebSocketService
    
    
    // MARK: - Init
    
    init(
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService()
    ) {
        self.httpNetworkService = httpNetworkService
        self.webSocketService = webSocketService
    }
    
    deinit {
        webSocketService.close()
    }
}
