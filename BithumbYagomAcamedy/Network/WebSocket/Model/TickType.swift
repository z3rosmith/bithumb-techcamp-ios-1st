//
//  TickType.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/07.
//

import Foundation

enum TickType: CustomStringConvertible {
    case minute30
    case hour1
    case hour12
    case hour24
    case month
    
    var description: String {
        switch self {
        case .minute30:
            return "30M"
        case .hour1:
            return "1H"
        case .hour12:
            return "12H"
        case .hour24:
            return "24H"
        case .month:
            return "MID"
        }
    }
}
