//
//  CoinChartCoreDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/08.
//

import Foundation
import CoreData

struct CoinChartCoreDataManager {
    private let context: NSManagedObjectContext
    private let symbol: String
    
    init(
        symbol: String,
        context: NSManagedObjectContext = CoreDataManager.shared.context
    ) {
        self.context = context
        self.symbol = symbol
    }
    
    func fetch(dateFormat: ChartDateFormat) -> [Candlestick] {
        let request = CandlestickChart.fetchRequest(symbol: symbol, dateFormat: dateFormat)
        let chart = CoreDataManager.shared.fetch(request: request)
        
        return chart.map { $0.candlestick }.sorted { $0.time < $1.time }
    }
    
    func update(
        candlestick: Candlestick,
        to updateCandlestick: Candlestick,
        dateFormat: ChartDateFormat
    ) {
        let request = CandlestickChart.fetchRequest(
            symbol: symbol,
            dateFormat: dateFormat,
            time: candlestick.time
        )
        let charts = CoreDataManager.shared.fetch(request: request)
        
        guard let chart = charts.first else {
            return
        }
        chart.update(candlestick: updateCandlestick)
        
        CoreDataManager.shared.saveContext()
    }
    
    func save(candlestick: Candlestick, dateFormat: ChartDateFormat) {
        guard let description = createDescription() else {
            return
        }
        
        insertContextCandlestickChart(
            to: candlestick,
            dateFormat: dateFormat,
            description: description,
            context: context
        )
        
        CoreDataManager.shared.saveContext()
    }
    
    func save(candlesticks: [Candlestick], dateFormat: ChartDateFormat) {
        guard let description = createDescription() else {
            return
        }
        
        candlesticks.forEach { candlestick in
            insertContextCandlestickChart(
                to: candlestick,
                dateFormat: dateFormat,
                description: description,
                context: context
            )
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    private func insertContextCandlestickChart(
        to candlestick: Candlestick,
        dateFormat: ChartDateFormat,
        description: NSEntityDescription,
        context: NSManagedObjectContext
    ) {
        let chart = CandlestickChart(entity: description, insertInto: context)
        
        chart.time = candlestick.time
        chart.highPrice = candlestick.highPrice
        chart.lowPrice = candlestick.lowPrice
        chart.openPrice = candlestick.openPrice
        chart.closePrice = candlestick.closePrice
        chart.symbol = symbol
        chart.timeInterval = dateFormat.description
    }
    
    private func createDescription() -> NSEntityDescription? {
        return NSEntityDescription.entity(
            forEntityName: "CandlestickChart",
            in: context
        )
    }
}
