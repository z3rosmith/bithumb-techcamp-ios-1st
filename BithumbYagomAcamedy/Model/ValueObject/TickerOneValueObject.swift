//
//  TickerOneValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/24.
//

import Foundation

struct TickerOneValueObject: Decodable {
    let status: String
    let data: TickerData
}
