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
        let appDelegate: AppDelegate?
        if Thread.current.isMainThread {
            appDelegate = UIApplication.shared.delegate as? AppDelegate
        } else {
            appDelegate = DispatchQueue.main.sync {
                return UIApplication.shared.delegate as? AppDelegate
            }
        }
        
        guard let appDelegate else {
            fatalError("")
        }
        
        return appDelegate.persistentContainer.viewContext
    }()
    
    private init() { }
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            let fetchResult = try context.fetch(request)
            
            return fetchResult
        } catch {
            print(error.localizedDescription)
            
            return []
        }
    }
    
    func delete<T: NSManagedObject>(request: NSFetchRequest<T>) {
        do {
            let fetchResult = try context.fetch(request)
            
            fetchResult.forEach {
                context.delete($0)
            }
            
            saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveContext() {
        context.performAndWait {
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
}
