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
        
        self.time = Double(time)
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.volume = volume
    }
    
    init?(ticker: WebSocketTickerData) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let date = formatter.date(from: ticker.date)
        guard let time = date?.timeIntervalSince1970,
              let openPrice = Double(ticker.openPrice),
              let closePrice = Double(ticker.closePrice),
              let lowPrice = Double(ticker.lowPrice),
              let highPrice = Double(ticker.highPrice),
              let volume = Double(ticker.volume) else {
                  return nil
              }
        
        self.time = Double(time * 1000)
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.volume = volume
    }
}
