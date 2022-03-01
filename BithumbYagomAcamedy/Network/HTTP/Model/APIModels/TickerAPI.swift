//
//  TickerAPI.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation

struct TickerAPI: Gettable {
    
    // MARK: - Property
    
    private(set) var url: URL?
    
    // MARK: - Init
    
    init(
        orderCurrency: String = "ALL",
        paymentCurrency: String = "KRW",
        baseURL: BaseURLable = BithumbPublicAPIURL()
    ) {
        let url = URL(
            string: "\(baseURL.baseURL)ticker/\(orderCurrency)_\(paymentCurrency)"
        )
        
        self.url = url
    }
}
