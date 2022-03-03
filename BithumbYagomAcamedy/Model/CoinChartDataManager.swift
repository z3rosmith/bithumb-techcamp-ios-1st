//
//  CoinChartDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/03.
//

import Foundation

protocol CoinChartDataManagerDelegate {
    func coinChartDataManager(didSet: [Candlestick])
}

final class CoinChartDataManager {
    
    private let httpService: HTTPNetworkService
    private let webSocketService: WebSocketService
    private var candlesticks: [Candlestick] {
        didSet {
            delegate?.coinChartDataManager(didSet: candlesticks)
        }
    }
    var delegate: CoinChartDataManagerDelegate?
    
    init(httpService: HTTPNetworkService = HTTPNetworkService(),
         webSocketService: WebSocketService = WebSocketService()) {
        self.httpService = httpService
        self.webSocketService = webSocketService
        self.candlesticks = []
    }
    
    func requestChart() {
        httpService.request(api: CandlestickAPI()) { [weak self] result in
            switch result {
            case .success(let data):
                guard let candlestickValueObject = try? self?.parsedCandlestickValueObject(from: data) else {
                    return
                }
                
                self?.candlesticks = candlestickValueObject.data.compactMap {
                    Candlestick(array: $0)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
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
