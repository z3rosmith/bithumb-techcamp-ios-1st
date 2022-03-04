//
//  CoinChartViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/02.
//

import UIKit
import Charts

final class CoinChartViewController: UIViewController {
    @IBOutlet private weak var coinChartView: CandleStickChartView!
    private var dataManager: CoinChartDataManager?
    private var coin: String = "BTC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCoinChartLayout()
        configureDataManager()
    }
    
    private func configureCoinChartLayout() {
        coinChartView.xAxis.labelWidth = 10
        coinChartView.xAxis.axisLineWidth = 3
        coinChartView.xAxis.gridLineWidth = 0.2
        coinChartView.rightAxis.gridLineWidth = 0.2
        coinChartView.xAxis.gridColor = .lightGray
        coinChartView.rightAxis.gridColor = .lightGray
        coinChartView.xAxis.labelPosition = .bottom
        coinChartView.legend.enabled = false
        coinChartView.leftAxis.enabled = false
        coinChartView.doubleTapToZoomEnabled = false
        
//        coinChartView.xAxis.valueFormatter = createFormatter()
//        coinChartView.delegate = self
    }
    
    private func createFormatter() -> DefaultAxisValueFormatter {
        return DefaultAxisValueFormatter { value, axis in
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "MM-dd"
            guard let interval = self.dataManager?.candlesticks[Int(value)].time else {
                return ""
            }
            print(dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(interval))))
            print(interval)
            return dateFormatter.string(from: Date(timeIntervalSince1970: interval))
        }
    }
    
    private func configureDataManager() {
        dataManager = CoinChartDataManager(symbol: coin)
        dataManager?.delegate = self
        dataManager?.requestChart()
        dataManager?.requestRealTimeChart()
    }
}

extension CoinChartViewController: CoinChartDataManagerDelegate {
    func coinChartDataManager(didSet candlesticks: [Candlestick]) {
        let entries = candlesticks.enumerated().map { create(candlestick: $1, at: $0) }
        let dataSet = create(dataSet: entries)
        let data = CandleChartData(dataSet: dataSet)
        
        DispatchQueue.main.async {
            self.coinChartView.data = data
            self.coinChartView.xAxis.valueFormatter = self.configureCoinChartXAxisFormatter(candlesticks)
            self.coinChartView.notifyDataSetChanged()
        }
    }
    
    private func create(dataSet dataEntries: [CandleChartDataEntry]) -> CandleChartDataSet {
        let dataSet = CandleChartDataSet(entries: dataEntries)
        
        dataSet.barSpace = 0.2
        dataSet.shadowWidth = 0.7
        dataSet.shadowColor = .black
        dataSet.neutralColor = .black
        dataSet.increasingColor = .red
        dataSet.decreasingColor = .blue
        dataSet.increasingFilled = true
        dataSet.decreasingFilled = true
        dataSet.drawValuesEnabled = false
        
        return dataSet
    }
    
    private func create(candlestick: Candlestick, at index: Int) -> CandleChartDataEntry {
        return CandleChartDataEntry(
            x: Double(index),
            shadowH: candlestick.highPrice,
            shadowL: candlestick.lowPrice,
            open: candlestick.openPrice,
            close: candlestick.closePrice
        )
    }
    
    private func configureCoinChartXAxisFormatter(_ candlestick: [Candlestick]) -> IndexAxisValueFormatter {
        let dateFormat: [String] = candlestick.map {
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "MM-dd"
            
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval($0.time)))
        }
        
        return IndexAxisValueFormatter(values: dateFormat)
    }
}
