//
//  CoinCandleChartDataSet.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/05.
//

import Foundation
import Charts

final class CoinCandleChartDataSet: CandleChartDataSet {
    convenience init(candlesticks: [Candlestick], label: String? = nil) {
        let dataEnties = candlesticks.enumerated().map {
            CoinCandleChartDataEntry(candlestick: $1, at: $0)
        }
        
        self.init(entries: dataEnties, label: label ?? "")
        barSpace = 0.2
        shadowWidth = 0.7
        axisDependency = .right
        shadowColor = .label
        neutralColor = .black
        increasingColor = .red
        decreasingColor = .blue
        increasingFilled = true
        decreasingFilled = true
        drawValuesEnabled = false
    }
}
