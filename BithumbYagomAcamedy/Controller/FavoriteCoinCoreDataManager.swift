//
//  FavoriteCoinCoreDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/03/08.
//

import Foundation
import CoreData

struct FavoriteCoinCoreDataManager {
    func fetch() -> [String] {
        let request = FavoriteCoin.fetchRequest()
        let favoriteCoin = CoreDataManager.shared.fetch(request: request)
        
        return favoriteCoin.map { $0.symbol }
    }
    
    func delete(symbol: String) {
        let request = FavoriteCoin.fetchRequest(symbol: symbol)
        
        CoreDataManager.shared.delete(request: request)
    }
    
    func save(symbol: String) {
        let favoriteCoinSymbols = fetch()
        guard favoriteCoinSymbols.contains(symbol) == false else {
            return
        }
        
        let context = CoreDataManager.shared.context
        guard let description = NSEntityDescription.entity(
            forEntityName: "FavoriteCoin",
            in: context
        ) else {
            return
        }
        
        let chart = FavoriteCoin(entity: description, insertInto: context)
        chart.symbol = symbol
        
        CoreDataManager.shared.saveContext()
    }
}
