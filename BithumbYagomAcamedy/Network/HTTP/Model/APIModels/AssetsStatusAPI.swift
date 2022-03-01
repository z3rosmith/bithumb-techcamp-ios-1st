//
//  AssetsStatusAPI.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation

struct AssetsStatusAPI: Gettable {
    
    // MARK: - Property
    
    private(set) var url: URL?
    
    // MARK: - Init
    
    init(
        orderCurrency: String = "ALL",
        baseURL: BaseURLable = BithumbPublicAPIURL()
    ) {
        let url = URL(
            string: "\(baseURL.baseURL)assetsstatus/\(orderCurrency)"
        )
       
        self.url = url
    }
}
