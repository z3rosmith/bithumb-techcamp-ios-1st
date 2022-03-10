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
    
    init(
        time: Double,
        openPrice: Double,
        closePrice: Double,
        lowPrice: Double,
        highPrice: Double,
        volume: Double
    ) {
        self.time = time
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.volume = volume
    }
    
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
    
    init?(ticker: WebSocketTickerData, dateFormat: ChartDateFormat) {
        let dateFormatter = CandlestickDateFormatter(
            date: ticker.date,
            time: ticker.time
        )
        guard let date = dateFormatter.date(by: dateFormat),
              let openPrice = Double(ticker.openPrice),
              let closePrice = Double(ticker.closePrice),
              let lowPrice = Double(ticker.lowPrice),
              let highPrice = Double(ticker.highPrice),
              let volume = Double(ticker.volume)
        else {
            return nil
        }
        let sliceUnit = Int(date.timeIntervalSince1970 / dateFormat.second)
        let timeUnit = Double(sliceUnit) * dateFormat.second
        
        self.time = timeUnit
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.volume = volume
    }
}
