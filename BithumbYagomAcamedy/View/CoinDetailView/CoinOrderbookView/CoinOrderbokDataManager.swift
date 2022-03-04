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
            calculateTotalOrderQuantity(orderbooks: asksOrderbook, type: .bid)
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
            
            self?.setTransaction(from: orderbookValueObject.orderbook)
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
    
    private func setTransaction(from orderbook: OrderbookData) {
        asksOrderbook = orderbook.asks.map {
            $0.generate(type: .ask)
        }.reversed()
        
        bidsOrderbook = orderbook.bids.map {
            $0.generate(type: .bid)
        }
    }
}
