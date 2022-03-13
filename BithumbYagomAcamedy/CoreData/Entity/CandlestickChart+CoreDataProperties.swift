//
//  CandlestickChart+CoreDataProperties.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/08.
//
//

import Foundation
import CoreData


extension CandlestickChart: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CandlestickChart> {
        return NSFetchRequest<CandlestickChart>(entityName: "CandlestickChart")
    }
    
    @nonobjc class func fetchRequest(
        symbol: String,
        dateFormat: ChartDateFormat
    ) -> NSFetchRequest<CandlestickChart> {
        let request = fetchRequest()
        let symbolPredicate = NSPredicate(format: "symbol == %@", symbol)
        let dateFormatPredicate = NSPredicate(format: "timeInterval == %@", dateFormat.description)
        let sortDescriptor = NSSortDescriptor(keyPath: \CandlestickChart.time, ascending: true)
        
        request.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [symbolPredicate, dateFormatPredicate]
        )
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    @nonobjc class func fetchRequest(
        symbol: String,
        dateFormat: ChartDateFormat,
        time: Double
    ) -> NSFetchRequest<CandlestickChart> {
        let request = fetchRequest()
        let symbolPredicate = NSPredicate(format: "symbol == %@", symbol)
        let dateFormatPredicate = NSPredicate(format: "timeInterval == %@", dateFormat.description)
        let timePredicate = NSPredicate(format: "time == %lf", time)
        
        request.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [symbolPredicate, dateFormatPredicate, timePredicate]
        )
        
        return request
    }
    
    @NSManaged public var time: Double
    @NSManaged public var openPrice: Double
    @NSManaged public var closePrice: Double
    @NSManaged public var lowPrice: Double
    @NSManaged public var highPrice: Double
    @NSManaged public var volume: Double
    @NSManaged public var symbol: String
    @NSManaged public var timeInterval: String
}
