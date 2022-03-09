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
    private let symbol: String
    private let httpNetworkService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private var coinTransactions: [Transaction] = [] {
        didSet {
            delegate?.coinTransactionDataManager(didChange: coinTransactions)
        }
    }
    
    // MARK: - Init
    
    init(
        symbol: String,
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService()
    ) {
        self.symbol = symbol
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
        let api = TransactionHistoryAPI(orderCurrency: symbol, count: 20)
        
        httpNetworkService.request(api: api) { [weak self] result in
            guard let data = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            let transactionValueObject = try? self?.parseTranscation(to: data)
            
            guard let transactionValueObject = transactionValueObject,
                  transactionValueObject.status == "0000"
            else {
                return
            }
            
            self?.setTransaction(from: transactionValueObject.transaction)
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
        let api = TransactionWebSocket(symbol: symbol)
        
        webSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let response):
                let transaction = try? self?.parseWebSocketTranscation(to: response)
                
                guard let transactionList = transaction?.webSocketTransactionData.list else {
                    return
                }
                
                self?.insertTransaction(transactionList)
            default:
                break
            }
        }
    }
    
    private func parseWebSocketTranscation(
        to string: String
    ) throws -> WebSocketTransactionValueObject {
        do {
            let webSocketTransactionValueObject = try JSONParser().decode(
                string: string,
                type: WebSocketTransactionValueObject.self
            )
            
            return webSocketTransactionValueObject
        } catch {
            print(error.localizedDescription)
            
            throw error
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
