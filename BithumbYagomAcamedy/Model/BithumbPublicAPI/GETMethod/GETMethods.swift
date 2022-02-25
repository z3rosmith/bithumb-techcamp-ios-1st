//
//  GETMethods.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/25.
//

import Foundation

struct TickerAPI: Gettable {
    private(set) var url: URL?
    
    init(
        orderCurrency: String = "ALL",
        paymentCurrency: String = "KRW",
        baseURL: BaseURLable = BithumbPublicAPIURL()
    )
    {
        let url = URL(
            string: "\(baseURL.baseURL)ticker/\(orderCurrency)_\(paymentCurrency)"
        )
        
        self.url = url
    }
}

struct OrderbookAPI: Gettable {
    private(set) var url: URL?
    
    init(
        orderCurrency: String = "ALL",
        paymentCurrency: String = "KRW",
        count: Int = 1,
        baseURL: BaseURLable = BithumbPublicAPIURL()
    )
    {
        var urlComponents = URLComponents(
            string: "\(baseURL.baseURL)orderbook/\(orderCurrency)_\(paymentCurrency)?"
        )
        let countQuery = URLQueryItem(name: "count", value: "\(count)")
        
        urlComponents?.queryItems?.append(countQuery)
        
        self.url = urlComponents?.url
    }
}

struct TransactionHistoryAPI: Gettable {
    private(set) var url: URL?
    
    init(
        orderCurrency: String,
        paymentCurrency: String = "KRW",
        count: Int = 1,
        baseURL: BaseURLable = BithumbPublicAPIURL()
    )
    {
        var urlComponents = URLComponents(
            string: "\(baseURL.baseURL)transaction_history/\(orderCurrency)_\(paymentCurrency)?"
        )
        let countQuery = URLQueryItem(name: "count", value: "\(count)")
        
        urlComponents?.queryItems?.append(countQuery)
        
        self.url = urlComponents?.url
    }
}

struct AssetsStatusAPI: Gettable {
    private(set) var url: URL?
    
    init(
        orderCurrency: String = "ALL",
        baseURL: BaseURLable = BithumbPublicAPIURL()
    )
    {
        let url = URL(
            string: "\(baseURL.baseURL)assetsstatus/\(orderCurrency)"
        )
       
        self.url = url
    }
}
