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
    private var coinTransactions: [Transaction] = [] {
        didSet {
            print(coinTransactions.count)
        }
    }
    
    // MARK: - Init
    
    init(
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService()
    ) {
        self.httpNetworkService = httpNetworkService
        self.webSocketService = webSocketService
    }
}

// MARK: - HTTP Network

extension CoinTransactionDataManager {
    func fetchTransaction() {
        let api = TransactionHistoryAPI(orderCurrency: "BTC", count: 100)
        
        httpNetworkService.request(api: api) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONParser().decode(
                        data: data,
                        type: TranscationValueObject.self
                    )
                    guard response.status == "0000" else {
                        return
                    }
                    self?.setTransaction(from: response.transaction)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func setTransaction(from transactionDatas: [TransactionData]) {
        coinTransactions = transactionDatas.map {
            $0.generate()
        }.reversed()
    }
}
