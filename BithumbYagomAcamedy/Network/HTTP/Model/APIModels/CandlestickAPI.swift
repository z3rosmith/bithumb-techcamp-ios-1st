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
        payment_currency: String = "KRW",
        chart_intervals: String = "24h",
        baseURL: BaseURLable = BithumbPublicAPIURL()
    ) {
        let url = URL(
            string: "\(baseURL.baseURL)candlestick/\(orderCurrency)_\(payment_currency)/\(chart_intervals)"
        )
       
        self.url = url
    }
}
