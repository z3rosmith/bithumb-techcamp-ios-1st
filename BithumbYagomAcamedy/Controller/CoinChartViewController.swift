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
        configureCoinChartXAxisFormatter()
        configureDataManager()
    }
    
    private func configureCoinChartLayout() {
        coinChartView.xAxis.axisLineWidth = 2
        coinChartView.xAxis.gridLineWidth = 0.2
        coinChartView.rightAxis.gridLineWidth = 0.2
        coinChartView.xAxis.gridColor = .lightGray
        coinChartView.rightAxis.gridColor = .lightGray
        coinChartView.xAxis.labelPosition = .bottom
        coinChartView.legend.enabled = false
        coinChartView.leftAxis.enabled = false
    }
    
    private func configureCoinChartXAxisFormatter() {
        coinChartView.xAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "yy-MM-dd"
            
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(value / 1000)))
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
    func coinChartDataManager(didSet candlestick: [Candlestick]) {
        let dataEnties = candlestick.map {
            create(candlestick: $0)
        }
        let dataSet = create(dataSet: dataEnties)
        let data = CandleChartData(dataSet: dataSet)
        
        DispatchQueue.main.async {
            self.coinChartView.data = data
            self.coinChartView.data?.notifyDataChanged()
        }
    }
    
    private func create(dataSet dataEntries: [CandleChartDataEntry]) -> CandleChartDataSet {
        let dataSet = CandleChartDataSet(entries: dataEntries)
        
        dataSet.axisDependency = .left
        dataSet.barSpace = 0.2
        dataSet.shadowWidth = 0.5
        dataSet.shadowColor = .black
        dataSet.neutralColor = .black
        dataSet.increasingColor = .red
        dataSet.decreasingColor = .blue
        dataSet.increasingFilled = true
        
        return dataSet
    }
    
    private func create(candlestick: Candlestick) -> CandleChartDataEntry {
        return CandleChartDataEntry(
            x: candlestick.time,
            shadowH: candlestick.highPrice,
            shadowL: candlestick.lowPrice,
            open: candlestick.openPrice,
            close: candlestick.closePrice
        )
    }
}
