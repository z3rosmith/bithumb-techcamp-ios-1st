//
//  CoinDetailDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/03.
//

import Foundation

protocol CoinDetailDataManagerDelegate: AnyObject {
    func coinDetailDataManager(didChange coin: DetailViewCoin?)
    func coinDetailDataManager(didFetchChartData price: [Double])
}

final class CoinDetailDataManager {
        
    // MARK: - Property
    
    weak var delegate: CoinDetailDataManagerDelegate?
    private let httpNetworkService: HTTPNetworkService
    private var tickerWebSocketService: WebSocketService
    private var transactionWebSocketService: WebSocketService
    private var detailCoin: DetailViewCoin? {
        didSet {
            delegate?.coinDetailDataManager(didChange: detailCoin)
        }
    }
    
    // MARK: - Init
    
    init(
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        tickerWebSocketService: WebSocketService = WebSocketService(),
        transactionWebSocketService: WebSocketService = WebSocketService()
    ) {
        self.httpNetworkService = httpNetworkService
        self.tickerWebSocketService = tickerWebSocketService
        self.transactionWebSocketService = transactionWebSocketService
    }
    
    // MARK: - Deinit
    
    deinit {
        tickerWebSocketService.close()
        transactionWebSocketService.close()
    }
}

// MARK: - Data Processing

extension CoinDetailDataManager {
    func configureDetailCoin(coin: Coin?) {
        guard let coin = coin else {
            return
        }
        
        detailCoin = DetailViewCoin(
            name: coin.symbolName,
            price: coin.currentPrice,
            changePrice: coin.changePrice,
            changeRate: coin.changeRate
        )
    }
}

// MARK: - Ticker WebSocket Network

extension CoinDetailDataManager {
    func fetchTickerWebSocket() {
        guard let symbol = detailCoin?.symbol else {
            return
        }
        
        let api = TickerWebSocket(symbol: symbol)
        
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
                
                self?.detailCoin?.setChangePrice(Double(changePrice))
                self?.detailCoin?.setChangeRate(Double(changeRate))
            default:
                break
            }
        }
    }
    
    private func parseWebSocketTicker(
        to string: String
    ) throws -> WebSocketTickerValueObject {
        do {
            let webSocketTickerValueObjcet = try JSONParser().decode(
                string: string,
                type: WebSocketTickerValueObject.self
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
        guard let symbol = detailCoin?.symbol else {
            return
        }
        
        let api = TransactionWebSocket(symbol: symbol)
        
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
                
                self?.detailCoin?.setPrice(Double(latestTransaction.price))
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

// MARK: - HTTP Network

extension CoinDetailDataManager {
    func fetchChart() {
        guard let symbol = detailCoin?.symbol else {
            return
        }
        
        let api = CandlestickAPI(orderCurrency: symbol)
        
        httpNetworkService.request(api: api) { [weak self] result in
            guard let data = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            let candlestickValueObject = try? self?.parseChart(to: data)
            
            guard let candlestickValueObject = candlestickValueObject,
                  candlestickValueObject.status == "0000"
            else {
                return
            }
            
            self?.setupChartData(from: candlestickValueObject)
        }
    }
    
    private func parseChart(to data: Data) throws -> CandlestickValueObject? {
        do {
            let chartValueObject = try JSONParser().decode(
                data: data
            )
            
            return CandlestickValueObject(serializedData: chartValueObject)
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
    
    private func setupChartData(from candlestickValueObject: CandlestickValueObject) {
        let threeMonthsAgo = Date().timeIntervalSince1970 - (86400 * 90)
        
        let openPrice = candlestickValueObject.data
            .compactMap{ Candlestick(array: $0) }
            .filter({ candleStick in
                candleStick.time > threeMonthsAgo
            })
            .map { $0.openPrice }
        
        guard let min = openPrice.min() else {
            return
        }
        
        let result = openPrice.map { openPrice in
            openPrice - min
        }
        
        delegate?.coinDetailDataManager(didFetchChartData: result)
    }
}
