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
        coinChartView.xAxis.axisLineWidth = 3
        coinChartView.xAxis.gridLineWidth = 0.2
        coinChartView.xAxis.labelPosition = .bottom
        coinChartView.xAxis.gridColor = .lightGray
        coinChartView.rightAxis.gridLineWidth = 0.2
        coinChartView.rightAxis.gridColor = .lightGray
        coinChartView.leftAxis.enabled = false
        coinChartView.legend.enabled = false
        coinChartView.doubleTapToZoomEnabled = false
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
        let dataSet = CoinCandleChartDataSet(candlesticks: candlesticks)
        let data = CandleChartData(dataSet: dataSet)
        
        DispatchQueue.main.async { [weak self] in
            guard let dateStrings = self?.dataManager?.xAxisDateString() else {
                return
            }
            let dateFormatter = IndexAxisValueFormatter(values: dateStrings)
            
            self?.coinChartView.data = data
            self?.coinChartView.xAxis.valueFormatter = dateFormatter
            self?.coinChartView.notifyDataSetChanged()
        }
    }
}
