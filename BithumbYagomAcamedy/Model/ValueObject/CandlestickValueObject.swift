//
//  CandlestickValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/03.
//

import Foundation

struct CandlestickValueObject {
    let status: String
    let data: [[Any]]
    
    init?(serializedData: [String: Any]?) {
        guard let status = serializedData?["status"] as? String,
              let candlestickData = serializedData?["data"] as? [[Any]] else {
                  return nil
              }
        
        self.status = status
        self.data = candlestickData
    }
}
