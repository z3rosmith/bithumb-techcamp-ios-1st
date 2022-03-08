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
    
    @NSManaged public var time: Double
    @NSManaged public var openPrice: Double
    @NSManaged public var closePrice: Double
    @NSManaged public var lowPrice: Double
    @NSManaged public var highPrice: Double
    @NSManaged public var volume: Double
    @NSManaged public var symbol: String
    @NSManaged public var timeInterval: String
}
