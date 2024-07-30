//
//  CoreDataStack.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 28.07.2024.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var mainContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
