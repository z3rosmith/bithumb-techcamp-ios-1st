//
//  CoinChartDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/03.
//

import Foundation

protocol CoinChartDataManagerDelegate {
    func coinChartDataManager(didSet candlesticks: [Candlestick])
}

final class CoinChartDataManager {
    private let httpService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private(set) var candlesticks: [Candlestick] {
        didSet {
            delegate?.coinChartDataManager(didSet: candlesticks)
        }
    }
    private let symbol: String
    private let formatType: DateFormat
    var delegate: CoinChartDataManagerDelegate?
    
    init(
        symbol: String,
        formatType: DateFormat = .hour24,
        httpService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService()
    ) {
        self.symbol = symbol
        self.formatType = formatType
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
                let candlesticks = candlestickValueObject.data.compactMap { Candlestick(array: $0) }
                
                self?.candlesticks = candlesticks
            case .failure(let error):
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
                guard let tickerData = try? self?.parsedWebSocketTickerValueObject(string: string).webSocketTickerData else {
                    return
                }
                
                self?.update(candlesticks: tickerData)
            default:
                break
            }
        }
    }
    
    func xAxisDateString() -> [String] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = formatType.format
        
        return candlesticks.map { candlestick in
            let date = Date(timeIntervalSince1970: candlestick.time)
            
            return dateFormatter.string(from: date)
        }
    }
    
    private func update(candlesticks tickerData: WebSocketTickerData) {
        guard let updateCandlestick = Candlestick(ticker: tickerData),
              let recentCandlestick = candlesticks.last else {
            return
        }
        let remainTime = updateCandlestick.time - recentCandlestick.time
        
        if Int(remainTime) < formatType.second {
            candlesticks[candlesticks.index(before: candlesticks.endIndex)] = updateCandlestick
        } else {
            candlesticks.append(updateCandlestick)
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
}
