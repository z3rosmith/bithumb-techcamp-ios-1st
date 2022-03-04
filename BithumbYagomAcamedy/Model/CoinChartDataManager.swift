//
//  CoinChartDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/03.
//

import Foundation

protocol CoinChartDataManagerDelegate {
    func coinChartDataManager(didSet candlestick: [Candlestick])
}

final class CoinChartDataManager {
    private let httpService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private var candlesticks: [Candlestick] {
        didSet {
            delegate?.coinChartDataManager(didSet: Array())
        }
    }
    private let symbol: String
    var delegate: CoinChartDataManagerDelegate?
    
    init(
        symbol: String,
        httpService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService()
    ) {
        self.symbol = symbol
        self.httpService = httpService
        self.webSocketService = webSocketService
        self.candlesticks = []
    }
    
    deinit {
        webSocketService.close()
    }
    
    func requestChart() {
        httpService.request(api: CandlestickAPI(orderCurrency: symbol)) { [weak self] result in
            switch result {
            case .success(let data):
                guard let candlestickValueObject = try? self?.parsedCandlestickValueObject(from: data) else {
                    return
                }
                self?.candlesticks = candlestickValueObject.data.compactMap {
                    Candlestick(array: $0)
                }
                print(self?.candlesticks[...10])
            case .failure(let error):
//                guard let url = Bundle.main.url(forResource: "MockCandlestickDataHour24", withExtension: "json"),
//                      let data = try? Data(contentsOf: url),
//                      let candlestickValueObject = try? self?.parsedCandlestickValueObject(from: data) else {
//                          return
//                      }
//                self?.candlesticks = candlestickValueObject.data.compactMap {
//                    Candlestick(array: $0)
//                }
                
                print(error.localizedDescription)
            }
        }
    }
    
    func requestRealTimeChart() {
        let api = TickerWebSocket(symbol: symbol)
        
        webSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let string):
                guard let valueObject = try? self?.parsedWebSocketTickerValueObject(string: string) else {
                    return
                }
                print(valueObject)
                
            default:
                break
            }
        }
    }
    
    private func parsedWebSocketTickerValueObject(string: String) throws -> WebSocketTickerValueObject {
        do {
            let parser = JSONParser()
            let parsedData = try parser.decode(string: string, type: WebSocketTickerValueObject.self)
            
            return parsedData
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
    
    private func parsedCandlestickValueObject(from data: Data) throws -> CandlestickValueObject? {
        do {
            let parsedData = try JSONParser().decode(data: data)
            
            return CandlestickValueObject(serializedData: parsedData)
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
}
