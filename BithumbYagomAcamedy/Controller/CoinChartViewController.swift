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
    @IBOutlet private weak var timeSegmentedControl: UISegmentedControl!
    private var dataManager: CoinChartDataManager?
    private var coin: String = "BTC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCoinChartLayout()
        configureDataManager()
    }
    
    private func configureCoinChartLayout() {
        coinChartView.xAxis.spaceMax = 10.0
        coinChartView.xAxis.granularity = 10
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
        requestChartData(at: timeSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func timeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        requestChartData(at: sender.selectedSegmentIndex)
    }
    
    private func requestChartData(at index: Int) {
        guard let tickType = TickType(rawValue: index) else {
            return
        }
        
        dataManager?.changeTickType(to: tickType)
    }
}

extension CoinChartViewController: CoinChartDataManagerDelegate {
    func coinChartDataManager(didSet candlesticks: [Candlestick]) {
        let dataSet = CoinCandleChartDataSet(candlesticks: candlesticks)
        let data = CandleChartData(dataSet: dataSet)
        
        DispatchQueue.main.async { [weak self] in
            self?.coinChartView.data = data
            self?.updateXAxisValueFormat()
            self?.moveChartPosition(entry: dataSet.last)
            self?.coinChartView.notifyDataSetChanged()
        }
    }
    
    func coinChartDataManager(didUpdate candlestick: Candlestick) {
        guard let coinChartDataSet = coinChartView.data?.dataSets[Int.zero] else {
            return
        }
        let endIndex = coinChartDataSet.entryCount - 1
        guard let removeEntry = coinChartDataSet.entryForIndex(endIndex) else {
            return
        }
        let entry = CoinCandleChartDataEntry(candlestick: candlestick, at: endIndex)
        
        DispatchQueue.main.async { [weak self] in
            self?.coinChartView.candleData?.removeEntry(removeEntry, dataSetIndex: Int.zero)
            self?.coinChartView.candleData?.addEntry(entry, dataSetIndex: Int.zero)
            self?.coinChartView.notifyDataSetChanged()
        }
    }
    
    func coinChartDataManager(didAdd candlestick: Candlestick) {
        guard let entryCount = coinChartView.data?.entryCount else {
            return
        }
        let entry = CoinCandleChartDataEntry(candlestick: candlestick, at: entryCount)
        
        DispatchQueue.main.async { [weak self] in
            self?.coinChartView.data?.addEntry(entry, dataSetIndex: Int.zero)
            self?.updateXAxisValueFormat()
            self?.coinChartView.notifyDataSetChanged()
        }
    }
    
    private func updateXAxisValueFormat() {
        guard let dateStrings = dataManager?.xAxisDateString() else {
            return
        }
        let dateFormatter = IndexAxisValueFormatter(values: dateStrings)
        coinChartView.xAxis.valueFormatter = dateFormatter
    }
    
    private func moveChartPosition(entry: ChartDataEntry?) {
        guard let x = entry?.x,
              let y = entry?.y else {
                  return
              }
        
        coinChartView.zoom(
            scaleX: 80,
            scaleY: 5,
            xValue: x,
            yValue: y,
            axis: .right
        )
    }
}
