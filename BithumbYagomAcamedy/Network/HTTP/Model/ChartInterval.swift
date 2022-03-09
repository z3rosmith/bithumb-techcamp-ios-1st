//
//  ChartInterval.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/08.
//

import Foundation

enum ChartInterval: CustomStringConvertible {
    case minute1
    case minute3
    case minute5
    case minute10
    case minute30
    case hour1
    case hour6
    case hour12
    case hour24
    
    var description: String {
        switch self {
        case .minute1:
            return "1m"
        case .minute3:
            return "3m"
        case .minute5:
            return "5m"
        case .minute10:
            return "10m"
        case .minute30:
            return "30m"
        case .hour1:
            return "1h"
        case .hour6:
            return "6h"
        case .hour12:
            return "12h"
        case .hour24:
            return "24h"
        }
    }
}
