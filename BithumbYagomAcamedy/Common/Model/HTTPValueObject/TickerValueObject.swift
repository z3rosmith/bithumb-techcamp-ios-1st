//
//  TickerValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/24.
//

import Foundation

struct TickerValueObject: Decodable {
    let status: String
    let ticker: TickerData
    
    enum CodingKeys: String, CodingKey {
        case status
        case ticker = "data"
    }
}
