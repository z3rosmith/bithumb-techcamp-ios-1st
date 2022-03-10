//
//  FavoriteCoin+CoreDataProperties.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/08.
//
//

import Foundation
import CoreData


extension FavoriteCoin: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteCoin> {
        return NSFetchRequest<FavoriteCoin>(entityName: "FavoriteCoin")
    }
    
    @nonobjc public class func fetchRequest(symbol: String) -> NSFetchRequest<FavoriteCoin> {
        let request = fetchRequest()
        let symbolPredicate = NSPredicate(format: "symbol == %@", symbol)
        
        request.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [symbolPredicate]
        )
        
        return request
    }
    
    @NSManaged public var symbol: String
}
