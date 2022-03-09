//
//  CoinChartViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/02.
//

import UIKit
import Charts

final class CoinChartViewController: UIViewController, PageViewControllerable {
    
    @IBOutlet private weak var coinChartView: CandleStickChartView!
    var completion: (() -> Void)?
    private var dataManager: CoinChartDataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        completion?()
        configureCoinChartLayout()
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
    
    func configureDataManager(coin: Coin) {
        dataManager = CoinChartDataManager(symbol: coin.symbolName)
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
