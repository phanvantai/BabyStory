//
//  CoreDataStack.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 2/6/25.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SoftDreams")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() throws {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
}
