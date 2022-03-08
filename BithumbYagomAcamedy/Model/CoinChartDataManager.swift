//
//  CoinChartDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/03.
//

import Foundation

protocol CoinChartDataManagerDelegate: AnyObject {
    func coinChartDataManager(didSet candlesticks: [Candlestick])
    func coinChartDataManager(didUpdate candlestick: Candlestick)
    func coinChartDataManager(didAdd candlestick: Candlestick)
}

final class CoinChartDataManager {
    private let httpService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private let coreDataManager: CoinChartCoreDataManager
    private let symbol: String
    private var dateFormat: ChartDateFormat
    private var candlesticks: [Candlestick]
    weak var delegate: CoinChartDataManagerDelegate?
    
    init(
        symbol: String,
        dateFormat: ChartDateFormat = .hour24,
        httpService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService()
    ) {
        self.symbol = symbol
        self.dateFormat = dateFormat
        self.httpService = httpService
        self.webSocketService = webSocketService
        self.coreDataManager = CoinChartCoreDataManager(symbol: symbol)
        self.candlesticks = []
    }
    
    deinit {
        webSocketService.close()
    }
    
    func changeChartDateFormat(to dateFormat: ChartDateFormat) {
        self.dateFormat = dateFormat
        webSocketService.close()
        
        DispatchQueue.main.async { [weak self] in
            self?.requestCoreDataChart()
            self?.requestRealTimeChart()
        }
    }
    
    func xAxisDateString() -> [String] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = dateFormat.format
        
        return candlesticks.map { candlestick in
            let date = Date(timeIntervalSince1970: candlestick.time)
            
            return dateFormatter.string(from: date)
        }
    }
    
    private func requestCoreDataChart() {
        let candlesticks = coreDataManager.fetch(dateFormat: dateFormat)
        
        if candlesticks.isEmpty == true {
            requestChart()
        } else {
            self.candlesticks = candlesticks
            self.delegate?.coinChartDataManager(didSet: candlesticks)
        }
    }
    
    private func requestChart() {
        let api = CandlestickAPI(symbol: symbol, dateFormat: dateFormat)
        
        httpService.request(api: api) { [weak self] result in
            guard let data = result.value else {
                let error = result.error
                
                print(error?.localizedDescription as Any)
                return
            }
            guard let candlestickValueObject = try? self?.parsedCandlestickValueObject(
                from: data
            ) else {
                return
            }
            let candlesticks = candlestickValueObject.data.compactMap {
                Candlestick(array: $0)
            }
            
            self?.candlesticks = candlesticks
            self?.saveCoreData(candlesticks: candlesticks)
            self?.delegate?.coinChartDataManager(didSet: candlesticks)
        }
    }
    
    private func requestRealTimeChart() {
        guard let api = TickerWebSocket(symbol: symbol, dateFormat: dateFormat) else {
            return
        }
        
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
                
                self?.update(candlestick: tickerData)
            default:
                break
            }
        }
    }
    
    private func update(candlestick tickerData: WebSocketTickerData) {
        guard let updateCandlestick = Candlestick(ticker: tickerData, dateFormat: dateFormat),
              let recentCandlestick = candlesticks.last
        else {
            return
        }
        let remainTime = updateCandlestick.time - recentCandlestick.time
        
        if remainTime == dateFormat.second {
            candlesticks.append(updateCandlestick)
            coreDataManager.save(candlestick: updateCandlestick, dateFormat: dateFormat)
            delegate?.coinChartDataManager(didAdd: updateCandlestick)
        } else {
            let lastIndex = candlesticks.index(before: candlesticks.endIndex)
            
            coreDataManager.update(
                candlestick: candlesticks[lastIndex],
                to: updateCandlestick,
                dateFormat: dateFormat
            )
            candlesticks[lastIndex] = updateCandlestick
            delegate?.coinChartDataManager(didUpdate: updateCandlestick)
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
    
    private func saveCoreData(candlesticks: [Candlestick]) {
        coreDataManager.save(
            candlesticks: candlesticks,
            dateFormat: dateFormat
        )
    }
}
