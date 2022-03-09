//
//  OrderbookAPI.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation

struct OrderbookAPI: Gettable {
    
    // MARK: - Property
    
    private(set) var url: URL?
    
    // MARK: - Init
    
    init(
        orderCurrency: String = "ALL",
        paymentCurrency: String = "KRW",
        count: Int = 30,
        baseURL: BaseURLable = BithumbPublicAPIURL()
    ) {
        var urlComponents = URLComponents(
            string: "\(baseURL.baseURL)orderbook/\(orderCurrency)_\(paymentCurrency)?"
        )
        let countQuery = URLQueryItem(name: "count", value: "\(count)")
        
        urlComponents?.queryItems?.append(countQuery)
        
        self.url = urlComponents?.url
    }
}
