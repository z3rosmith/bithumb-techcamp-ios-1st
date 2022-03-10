//
//  CoinOrderbokDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import Foundation

protocol CoinOrderbookDataManagerDelegate: AnyObject {
    func coinOrderbookDataManager(didChange askOrderbooks: [Orderbook], and bidOrderbooks: [Orderbook])
    func coinOrderbookDataManager(didCalculate totalQuantity: Double, type: OrderbookType)
    func coinOrderbookDataManagerDidFetchFail()
}

final class CoinOrderbookDataManager {
    
    // MARK: - Property
    
    weak var delegate: CoinOrderbookDataManagerDelegate?
    private let symbol: String
    private let httpNetworkService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private var askOrderbooks: [Orderbook] = [] {
        didSet {
            delegate?.coinOrderbookDataManager(didChange: askOrderbooks, and: bidOrderbooks)
            calculateTotalOrderQuantity(orderbooks: askOrderbooks, type: .ask)
        }
    }
    private var bidOrderbooks: [Orderbook] = [] {
        didSet {
            delegate?.coinOrderbookDataManager(didChange: askOrderbooks, and: bidOrderbooks)
            calculateTotalOrderQuantity(orderbooks: bidOrderbooks, type: .bid)
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
    
    private func updateOrderbook(
        orderbooks: [Orderbook],
        to currentOrderbooks: inout [Orderbook],
        type : OrderbookType
    ) {
        var newOrderbooks: [String: Double] = [:]
        var oldOrderbooks: [String: Double] = [:]
        
        orderbooks.forEach { orderbook in
            newOrderbooks[orderbook.price] = Double(orderbook.quantity)
        }
        
        currentOrderbooks.forEach { orderbook in
            oldOrderbooks[orderbook.price] = Double(orderbook.quantity)
        }
        
        newOrderbooks.merge(oldOrderbooks) { (new, _) in new }
        
        let resultOrderbooks: [Orderbook] = newOrderbooks
            .filter { $0.value > 0 }
            .map { Orderbook(price: $0.key, quantity: String($0.value), type: type) }
            .sorted { $0.price > $1.price }
        
        if resultOrderbooks.count > 30 {
            currentOrderbooks = resultOrderbooks.dropLast(resultOrderbooks.count - 30)
            return
        }
        
        currentOrderbooks = resultOrderbooks
    }
}

// MARK: - HTTP Network

extension CoinOrderbookDataManager {
    func fetchOrderbook() {
        let api = OrderbookAPI(orderCurrency: symbol)
        
        httpNetworkService.request(api: api) { [weak self] result in
            guard let data = result.value else {
                self?.delegate?.coinOrderbookDataManagerDidFetchFail()
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
        askOrderbooks = orderbook.asks.map {
            $0.generate(type: .ask)
        }.reversed()
        
        bidOrderbooks = orderbook.bids.map {
            $0.generate(type: .bid)
        }
    }
}

// MARK: - WebSocket Network

extension CoinOrderbookDataManager {
    func fetchOrderbookWebSocket() {
        let api = OrderBookDepthWebSocket(symbol: symbol)
        
        webSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let response):
                let orderbook = try? self?.parseWebSocketOrderbook(to: response)
                
                guard let orderbook = orderbook?.webSocketOrderBookDepthData else {
                    return
                }
                
                self?.insertOrderbook(orderbook)
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
        _ orderbooks: WebSocketOrderBookDepthData,
        at index: Int = Int.zero
    ) {
        let webSocketAskOrderbooks = orderbooks.asks.map {
            $0.generate()
        }
        
        updateOrderbook(orderbooks: webSocketAskOrderbooks, to: &askOrderbooks, type: .ask)
        
        let webSocketBidOrderbooks = orderbooks.bids.map {
            $0.generate()
        }

        updateOrderbook(orderbooks: webSocketBidOrderbooks, to: &bidOrderbooks, type: .bid)
    }
}

