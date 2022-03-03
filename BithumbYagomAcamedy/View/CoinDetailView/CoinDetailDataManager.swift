//
//  CoinDetailDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/03.
//

import Foundation

protocol CoinDetailDataManagerDelegate: AnyObject {
    func coinDetailDataManager(didChange coin: CoinDetailDataManager.DetailViewCoin)
}

final class CoinDetailDataManager {
    
    // MARK: - Nested Type
    
    struct DetailViewCoin {
        let name: String
        var price: Double
        var changePrice: Double
        var changeRate: Double
    }
    
    // MARK: - Property
    
    weak var delegate: CoinDetailDataManagerDelegate?
    private var tickerWebSocketService: WebSocketService
    private var transactionWebSocketService: WebSocketService
//    private lazy var detainCoin: DetailViewCoin
    
    // MARK: - Init
    
    init(
        tickerWebSocketService: WebSocketService = WebSocketService(),
        transactionWebSocketService: WebSocketService = WebSocketService()
    ) {
        self.tickerWebSocketService = tickerWebSocketService
        self.transactionWebSocketService = transactionWebSocketService
    }
}

// MARK: - Ticker WebSocket Network

extension CoinDetailDataManager {
    func fetchTickerWebSocket() {
        let api = TickerWebSocket(symbol: "BTC")
        
        tickerWebSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let response):
                let ticker = try? self?.parseWebSocketTicker(to: response)
                
                guard let changePrice = ticker?.webSocketTickerData.changePrice,
                      let changeRate = ticker?.webSocketTickerData.changeRate
                else {
                    return
                }
                
                print(changeRate, changePrice)
            default:
                break
            }
        }
    }
    
    private func parseWebSocketTicker(
        to string: String
    ) throws -> WebSocketTickerValueObjcet {
        do {
            let webSocketTickerValueObjcet = try JSONParser().decode(
                string: string,
                type: WebSocketTickerValueObjcet.self
            )
            
            return webSocketTickerValueObjcet
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
}

// MARK: - Transaction WebSocket Network

extension CoinDetailDataManager {
    func fetchTransactionWebSocket() {
        let api = TransactionWebSocket(symbol: "BTC")
        
        transactionWebSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let response):
                let transaction = try? self?.parseWebSocketTranscation(to: response)
                
                guard let transactionList = transaction?.webSocketTransactionData.list,
                      let latestTransaction = transactionList.reversed().first
                else {
                    return
                }
                
                print(latestTransaction.price)
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
}
