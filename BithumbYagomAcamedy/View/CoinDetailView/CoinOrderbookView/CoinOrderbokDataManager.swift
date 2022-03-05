//
//  CoinOrderbokDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import Foundation

protocol CoinOrderbookDataManagerDelegate: AnyObject {
    func coinOrderbookDataManager(didChange askOrderbooks: [Orderbook], bidOrderbooks: [Orderbook])
    func coinOrderbookDataManager(didCalculate totalQuntity: Double, type: OrderbookType)
}

final class CoinOrderbookDataManager {
    
    // MARK: - Property
    
    weak var delegate: CoinOrderbookDataManagerDelegate?
    private let httpNetworkService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private var asksOrderbook: [Orderbook] = [] {
        didSet {
            delegate?.coinOrderbookDataManager(didChange: asksOrderbook, bidOrderbooks: bidsOrderbook)
            calculateTotalOrderQuantity(orderbooks: asksOrderbook, type: .ask)
        }
    }
    private var bidsOrderbook: [Orderbook] = [] {
        didSet {
            delegate?.coinOrderbookDataManager(didChange: asksOrderbook, bidOrderbooks: bidsOrderbook)
            calculateTotalOrderQuantity(orderbooks: bidsOrderbook, type: .bid)
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

// MARK: - Data Processing

extension CoinOrderbookDataManager {
    private func calculateTotalOrderQuantity(
        orderbooks: [Orderbook],
        type: OrderbookType
    ) {
        let totalQuantity = orderbooks.compactMap { orderbook in
            Double(orderbook.quantity)
        }.reduce(0, +)
        
        let digit: Double = pow(10, 5)
        let roundedQuantity = round(totalQuantity * digit) / digit
        
        delegate?.coinOrderbookDataManager(didCalculate: roundedQuantity, type: type)
    }
}

// MARK: - HTTP Network

extension CoinOrderbookDataManager {
    func fetchOrderbook() {
        let api = OrderbookAPI(orderCurrency: "BTC")
        
        httpNetworkService.request(api: api) { [weak self] result in
            guard let data = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            let orderbookValueObject = try? self?.parseOrderbook(to: data)
            
            guard let orderbookValueObject = orderbookValueObject,
                  orderbookValueObject.status == "0000"
            else {
                return
            }
            
            self?.setOrderbooks(from: orderbookValueObject.orderbook)
        }
    }
    
    private func parseOrderbook(to data: Data) throws -> OrderbookValueObject {
        do {
            let orderbookValueObject = try JSONParser().decode(
                data: data,
                type: OrderbookValueObject.self
            )
            
            return orderbookValueObject
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
    
    private func setOrderbooks(from orderbook: OrderbookData) {
        asksOrderbook = orderbook.asks.map {
            $0.generate(type: .ask)
        }.reversed()
        
        bidsOrderbook = orderbook.bids.map {
            $0.generate(type: .bid)
        }
    }
}

// MARK: - WebSocket Network

extension CoinOrderbookDataManager {
    func fetchOrderbookWebSocket() {
        let api = OrderBookDepthWebSocket(symbol: "BTC")
        
        webSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let response):
                let orderbook = try? self?.parseWebSocketOrderbook(to: response)
                
                guard let orderbookList = orderbook?.webSocketOrderBookDepthData.list else {
                    return
                }
                
                self?.insertOrderbook(orderbookList)
            default:
                break
            }
        }
    }
    
    private func parseWebSocketOrderbook(
        to string: String
    ) throws -> WebSocketOrderBookDepthValueObject {
        do {
            let webSocketOrderbookValueObject = try JSONParser().decode(
                string: string,
                type: WebSocketOrderBookDepthValueObject.self
            )
            
            return webSocketOrderbookValueObject
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
    
    private func insertOrderbook(
        _ orderbooks: [WebSocketOrderBookDepthData.OrderBookDepthData],
        at index: Int = Int.zero
    ) {
        let askOrderbooks = orderbooks.filter {
            $0.orderType == .ask
        }.map {
            $0.generate()
        }
        self.asksOrderbook.append(contentsOf: askOrderbooks)
        
        let bidOrderbooks = orderbooks.filter {
            $0.orderType == .bid
        }.map {
            $0.generate()
        }
        self.bidsOrderbook.insert(contentsOf: bidOrderbooks, at: Int.zero)
    }
}

