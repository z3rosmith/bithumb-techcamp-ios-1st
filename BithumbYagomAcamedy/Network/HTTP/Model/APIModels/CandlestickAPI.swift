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
        chartIntervals: DateFormat = .hour24,
        baseURL: BaseURLable = BithumbPublicAPIURL()
    ) {
        let url = URL(
            string: "\(baseURL.baseURL)candlestick/\(orderCurrency)_\(paymentCurrency)/\(chartIntervals)"
        )
        
        self.url = url
    }
}
