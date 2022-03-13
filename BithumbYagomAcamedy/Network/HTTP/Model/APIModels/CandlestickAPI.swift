//
//  CandlestickAPI.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/03.
//

import Foundation

struct CandlestickAPI: Gettable {
    var url: URL?
    
    init(
        orderCurrency: String = "BTC",
        paymentCurrency: String = "KRW",
        chartInterval: ChartInterval = .hour24,
        baseURL: BaseURLable = BithumbPublicAPIURL()
    ) {
        let url = URL(
            string: "\(baseURL.baseURL)candlestick/\(orderCurrency)_\(paymentCurrency)/\(chartInterval)"
        )
        
        self.url = url
    }
    
    init(symbol: String,
         dateFormat: ChartDateFormat
    ) {
        let interval: ChartInterval
        
        switch dateFormat {
        case .minute1:
            interval = .minute1
        case .minute10:
            interval = .minute10
        case .minute30:
            interval = .minute30
        case .hour1:
            interval = .hour1
        case .hour24:
            interval = .hour24
        }
        
        self.init(
            orderCurrency: symbol,
            chartInterval: interval
        )
    }
}
