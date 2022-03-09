//
//  ChartDateFormat.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/08.
//

import Foundation


enum ChartDateFormat: Int, CustomStringConvertible {
    case minute1
    case minute10
    case minute30
    case hour1
    case hour24
    
    var second: Double {
        switch self {
        case .minute1:
            return 60
        case .minute10:
            return 600
        case .minute30:
            return 1800
        case .hour1:
            return 3600
        case .hour24:
            return 86400
        }
    }
    
    var format: String {
        switch self {
        case .minute1, .minute10, .minute30, .hour1:
            return "yy.MM.dd\nHH:mm"
        case .hour24:
            return "yy.MM.dd"
        }
    }
    
    var description: String {
        switch self {
        case .minute1:
            return "1m"
        case .minute10:
            return "10m"
        case .minute30:
            return "30m"
        case .hour1:
            return "1h"
        case .hour24:
            return "24h"
        }
    }
}
