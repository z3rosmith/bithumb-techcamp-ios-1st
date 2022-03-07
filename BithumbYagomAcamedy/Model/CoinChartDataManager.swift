//
//  CoinChartDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/03.
//

import Foundation

protocol CoinChartDataManagerDelegate: AnyObject {
    func coinChartDataManager(didSet candlesticks: [Candlestick])
}

final class CoinChartDataManager {
    private let httpService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private let symbol: String
    private var tickType: TickType
    private var candlesticks: [Candlestick] {
        didSet {
            delegate?.coinChartDataManager(didSet: candlesticks)
        }
    }
    weak var delegate: CoinChartDataManagerDelegate?
    
    init(
        symbol: String,
        tickType: TickType = .hour24,
        httpService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService()
    ) {
        self.symbol = symbol
        self.tickType = tickType
        self.httpService = httpService
        self.webSocketService = webSocketService
        self.candlesticks = []
    }
    
    deinit {
        webSocketService.close()
    }
    
    func changeTickType(to tickType: TickType) {
        self.tickType = tickType
        webSocketService.close()
        requestChart()
        requestRealTimeChart()
    }
    
    func xAxisDateString() -> [String] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = tickType.dateFormat
        
        return candlesticks.map { candlestick in
            let date = Date(timeIntervalSince1970: candlestick.time)
            
            return dateFormatter.string(from: date)
        }
    }
    
    private func requestChart() {
        let api = CandlestickAPI(orderCurrency: symbol, tickType: tickType)
        
        httpService.request(api: api) { [weak self] result in
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
    
    private func requestRealTimeChart() {
        let api = TickerWebSocket(symbol: symbol, tickType: tickType)
        
        webSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                
                return
            }
            
            switch message {
            case .string(let string):
                guard let ticketValueObject = try? self?.parsedWebSocketTickerValueObject(
                    string: string
                ) else {
                    return
                }
                
                let tickerData = ticketValueObject.webSocketTickerData
                
                self?.update(candlesticks: tickerData)
            default:
                break
            }
        }
    }
    
    private func update(candlesticks tickerData: WebSocketTickerData) {
        guard let updateCandlestick = Candlestick(ticker: tickerData, tickType: tickType),
              let recentCandlestick = candlesticks.last else {
            return
        }
        let remainTime = updateCandlestick.time - recentCandlestick.time
        
        if remainTime == tickType.second {
            candlesticks.append(updateCandlestick)
        } else {
            let lastIndex = candlesticks.index(before: candlesticks.endIndex)
            
            candlesticks[lastIndex] = updateCandlestick
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
