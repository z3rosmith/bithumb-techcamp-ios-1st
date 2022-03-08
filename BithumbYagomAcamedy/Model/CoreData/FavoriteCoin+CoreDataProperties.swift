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
    
    @NSManaged public var symbol: String
}
