//
//  Candlestick.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/05.
//

import Foundation

struct Candlestick {
    let time: Double
    let openPrice: Double
    let closePrice: Double
    let lowPrice: Double
    let highPrice: Double
    let volume: Double
    
    init?(array: [Any]) {
        guard let time = array[0] as? Int64,
              let openPrice = array[1] as? String,
              let closePrice = array[2] as? String,
              let highPrice = array[3] as? String,
              let lowPrice = array[4] as? String,
              let volume = array[5] as? String else {
                  return nil
              }
        
        guard let openPrice = Double(openPrice),
              let closePrice = Double(closePrice),
              let lowPrice = Double(lowPrice),
              let highPrice = Double(highPrice),
              let volume = Double(volume) else {
                  return nil
              }
        
        self.time = Double(time / 1000)
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.volume = volume
    }
    
    init?(ticker: WebSocketTickerData, tickType: TickType) {
        let formatter = DateFormatter()
        let startIndex = ticker.time.startIndex
        let endIndex = ticker.time.endIndex
        var dateString: String
        
        switch tickType {
        case .minute1, .minute10, .minute30:
            let lastIndex = ticker.time.index(endIndex, offsetBy: -2)
            formatter.dateFormat =  "yyyyMMddHHmm"
            dateString = ticker.date + ticker.time[startIndex..<lastIndex]
        case .hour1:
            formatter.dateFormat =  "yyyyMMddHH"
            let lastIndex = ticker.time.index(endIndex, offsetBy: -4)
            dateString = ticker.date + ticker.time[startIndex..<lastIndex]
        case .hour24:
            formatter.dateFormat = "yyyyMMdd"
            dateString = ticker.date
        }
        
        guard let date = formatter.date(from: dateString),
              let openPrice = Double(ticker.openPrice),
              let closePrice = Double(ticker.closePrice),
              let lowPrice = Double(ticker.lowPrice),
              let highPrice = Double(ticker.highPrice),
              let volume = Double(ticker.volume) else {
                  return nil
              }
        let sliceUnit = Int(date.timeIntervalSince1970 / tickType.second)
        let timeUnit = Double(sliceUnit) * tickType.second
        
        self.time = timeUnit
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.volume = volume
    }
}
