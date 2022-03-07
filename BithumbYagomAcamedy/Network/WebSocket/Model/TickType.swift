//
//  TickType.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/07.
//

import Foundation

enum TickType: Int, CustomStringConvertible {
    case minute1
    case minute10
    case minute30
    case hour1
    case hour24
    
    var description: String {
        switch self {
        case .minute1:
            return "1M"
        case .minute10:
            return "10M"
        case .minute30:
            return "30M"
        case .hour1:
            return "1H"
        case .hour24:
            return "24H"
        }
    }
    
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
    
    var dateFormat: String {
        switch self {
        case .minute1, .minute10, .minute30, .hour1:
            return "yy.MM.dd HH:mm"
        case .hour24:
            return "yy.MM.dd"
        }
    }
}
