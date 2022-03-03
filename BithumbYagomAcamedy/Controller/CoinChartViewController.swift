//
//  CoinChartViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/02.
//

import UIKit
import Charts

class CoinChartViewController: UIViewController {
    @IBOutlet private weak var coinChartView: CandleStickChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCoinChartLayout()
        configureCoinChartXAxisFormatter()
        setChartData()
    }
    
    private func configureCoinChartLayout() {
        coinChartView.xAxis.gridLineWidth = 0.2
        coinChartView.rightAxis.gridLineWidth = 0.2
        coinChartView.xAxis.gridColor = .lightGray
        coinChartView.rightAxis.gridColor = .lightGray
        coinChartView.xAxis.labelPosition = .bottom
        coinChartView.leftAxis.enabled = false
        coinChartView.autoScaleMinMaxEnabled = true
    }
    
    private func configureCoinChartXAxisFormatter() {
        coinChartView.xAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "YYYY-MM-DD"
            
            return dateFormatter.string(from: Date(timeIntervalSince1970: value))
        }
    }
    
    func setChartData() {
        let yVals1 = (0..<100).map { (i) -> CandleChartDataEntry in
            let mult = 10
            let val = Double(Int(arc4random_uniform(40)) + mult)
            let high = Double(arc4random_uniform(9) + 8)
            let low = Double(arc4random_uniform(9) + 8)
            let open = Double(arc4random_uniform(6) + 1)
            let close = Double(arc4random_uniform(6) + 1)
            let even = i % 2 == 0
            
            return CandleChartDataEntry(x: Double(i), shadowH: val + high, shadowL: val - low, open: even ? val + open : val - open, close: even ? val - close : val + close)
        }
        
        let set1 = CandleChartDataSet(entries: yVals1, label: "Data Set")
        set1.axisDependency = .left
        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        set1.shadowColor = .darkGray
        set1.shadowWidth = 0.7
        set1.decreasingColor = .red
        set1.decreasingFilled = true
        set1.increasingColor = UIColor(red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
        set1.increasingFilled = false
        set1.neutralColor = .blue
        
        let data = CandleChartData(dataSet: set1)
        coinChartView.data = data
    }
}
