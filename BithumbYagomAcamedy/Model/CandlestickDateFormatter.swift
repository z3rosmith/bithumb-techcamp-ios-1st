//
//  CandlestickDateFormatter.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/09.
//

import Foundation

struct CandlestickDateFormatter {
    let date: String
    let time: String
    
    func date(by dateFormat: ChartDateFormat) -> Date? {
        let formatter = DateFormatter()
        let dateString: String
        let endIndex = time.endIndex
        
        switch dateFormat {
        case .minute1, .minute10, .minute30:
            let lastIndex = time.index(endIndex, offsetBy: -2)
            
            dateString = date + time[..<lastIndex]
            formatter.dateFormat =  "yyyyMMddHHmm"
        case .hour1:
            let lastIndex = time.index(endIndex, offsetBy: -4)
            
            dateString = date + time[..<lastIndex]
            formatter.dateFormat =  "yyyyMMddHH"
        case .hour24:
            formatter.dateFormat = "yyyyMMdd"
            dateString = date
        }
        
        return formatter.date(from: dateString)
    }
}
