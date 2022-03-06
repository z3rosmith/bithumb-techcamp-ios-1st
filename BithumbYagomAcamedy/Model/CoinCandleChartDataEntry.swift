//
//  CoinCandleChartDataEntry.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/05.
//

import Foundation
import Charts

final class CoinCandleChartDataEntry: CandleChartDataEntry {
    convenience init(candlestick: Candlestick, at index: Int) {
        self.init(
            x: Double(index),
            shadowH: candlestick.highPrice,
            shadowL: candlestick.lowPrice,
            open: candlestick.openPrice,
            close: candlestick.closePrice
        )
    }
}
