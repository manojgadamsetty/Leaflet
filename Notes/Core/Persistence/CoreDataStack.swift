//
//  CoreDataStack.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import CoreData
import Combine

/// Core Data stack manager
/// Handles the setup and management of Core Data persistence
final class CoreDataStack: ObservableObject {
    
    @Published var isReady = false
    
    private let modelName = "Notes"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    init() {
        setupCoreData()
    }
    
    private func setupCoreData() {
        persistentContainer.loadPersistentStores { [weak self] _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Core Data error: \(error.localizedDescription)")
                } else {
                    self?.viewContext.automaticallyMergesChangesFromParent = true
                    self?.isReady = true
                    print("Core Data loaded successfully")
                }
            }
        }
    }
    
    func save() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Context save error: \(error.localizedDescription)")
        }
    }
}
