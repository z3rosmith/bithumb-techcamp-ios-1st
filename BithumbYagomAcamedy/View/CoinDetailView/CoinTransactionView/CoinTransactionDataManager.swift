//
//  CoinTransactionDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/02.
//

import Foundation

protocol CoinTransactionDataManagerDelegate: AnyObject {
    func coinTransactionDataManager(didChange transactions: [Transaction])
}

final class CoinTransactionDataManager {
    
    // MARK: - Property
    weak var delegate: CoinTransactionDataManagerDelegate?
    private let httpNetworkService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private var coinTransactions: [Transaction] = [] {
        didSet {
            delegate?.coinTransactionDataManager(didChange: coinTransactions)
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
    
    deinit {
        webSocketService.close()
    }
}

// MARK: - HTTP Network

extension CoinTransactionDataManager {
    func fetchTransaction() {
        let api = TransactionHistoryAPI(orderCurrency: "BTC", count: 100)
        
        httpNetworkService.request(api: api) { [weak self] result in
            switch result {
            case .success(let data):
                let transcationValueObject = try? self?.parseTranscation(to: data)
                
                guard let transcationValueObject = transcationValueObject,
                      transcationValueObject.status == "0000"
                else {
                    return
                }
                
                self?.setTransaction(from: transcationValueObject.transaction)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func parseTranscation(to data: Data) throws -> TranscationValueObject {
        do {
            let transcationValueObject = try JSONParser().decode(
                data: data,
                type: TranscationValueObject.self
            )
            
            return transcationValueObject
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
    
    private func setTransaction(from transactionDatas: [TransactionData]) {
        coinTransactions = transactionDatas.map {
            $0.generate()
        }.reversed()
    }
}

// MARK: - WebSocket Network

extension CoinTransactionDataManager {
    func fetchTransactionWebSocket() {
        let api = TransactionWebSocket(symbol: "BTC")
        
        webSocketService.open(webSocketAPI: api) { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let response):
                    guard let responseData = response.data(using: .utf8) else {
                        break
                    }
                    if let transaction = try? JSONParser().decode(
                        data: responseData,
                        type: WebSocketTransactionValueObject.self
                    ).webSocketTransactionData {
                        self?.insertTransaction(transaction.list)
                    }
                default:
                    break
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func insertTransaction(
        _ transactions: [WebSocketTransactionData.WebSocketTransaction],
        at index: Int = Int.zero
    ) {
        let convertedTransactions = transactions.map {
            $0.generate()
        }.reversed()
        
        coinTransactions.insert(contentsOf: convertedTransactions, at: index)
    }
}
