//
//  CandlestickChart+CoreDataClass.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/08.
//
//

import Foundation
import CoreData

@objc(CandlestickChart)
public class CandlestickChart: NSManagedObject {
    var candlestick: Candlestick {
        return Candlestick(
            time: time,
            openPrice: openPrice,
            closePrice: closePrice,
            lowPrice: lowPrice,
            highPrice: highPrice,
            volume: volume
        )
    }
    
    func update(candlestick: Candlestick) {
        time = candlestick.time
        openPrice = candlestick.openPrice
        closePrice = candlestick.closePrice
        lowPrice = candlestick.lowPrice
        highPrice = candlestick.highPrice
        volume = volume
    }
}
