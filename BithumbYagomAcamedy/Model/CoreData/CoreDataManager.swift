//
//  CoreDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/08.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    static let shared: CoreDataManager = CoreDataManager()
    private(set) lazy var context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Not down cast AppDelegate")
        }
        
        return appDelegate.persistentContainer.viewContext
    }()
    
    private init() { }
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            let fetchResult = try self.context.fetch(request)
            
            return fetchResult
        } catch {
            print(error.localizedDescription)
            
            return []
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
