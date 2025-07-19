//
//  NotesLocalDataSource.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation
import CoreData
import Combine

/// Local data source for notes using Core Data
/// Handles all local persistence operations
final class NotesLocalDataSource {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchNotes() -> AnyPublisher<[Note], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.unknown))
                return
            }
            
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \NoteEntity.updatedAt, ascending: false)]
            
            do {
                let entities = try context.fetch(request)
                let notes = entities.compactMap { $0.toDomainModel() }
                promise(.success(notes))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchNote(id: String) -> AnyPublisher<Note?, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.unknown))
                return
            }
            
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            
            do {
                let entities = try context.fetch(request)
                let note = entities.first?.toDomainModel()
                promise(.success(note))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveNote(_ note: Note) -> AnyPublisher<Note, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.unknown))
                return
            }
            
            let context = self.coreDataStack.backgroundContext
            
            context.perform {
                do {
                    // Check if note exists
                    let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", note.id)
                    request.fetchLimit = 1
                    
                    let existingEntities = try context.fetch(request)
                    let entity = existingEntities.first ?? NoteEntity(context: context)
                    
                    // Update entity
                    var updatedNote = note
                    updatedNote.updatedAt = Date()
                    entity.updateFromDomainModel(updatedNote)
                    
                    // Save context
                    try context.save()
                    
                    DispatchQueue.main.async {
                        promise(.success(updatedNote))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteNote(id: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.unknown))
                return
            }
            
            let context = self.coreDataStack.backgroundContext
            
            context.perform {
                do {
                    let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", id)
                    
                    let entities = try context.fetch(request)
                    entities.forEach { context.delete($0) }
                    
                    try context.save()
                    
                    DispatchQueue.main.async {
                        promise(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func searchNotes(query: String) -> AnyPublisher<[Note], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.unknown))
                return
            }
            
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
            
            // Create search predicate
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
            let contentPredicate = NSPredicate(format: "content CONTAINS[cd] %@", query)
            let tagsPredicate = NSPredicate(format: "ANY tagsArray CONTAINS[cd] %@", query)
            
            request.predicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate, tagsPredicate]
            )
            request.sortDescriptors = [NSSortDescriptor(keyPath: \NoteEntity.updatedAt, ascending: false)]
            
            do {
                let entities = try context.fetch(request)
                let notes = entities.compactMap { $0.toDomainModel() }
                promise(.success(notes))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Data Source Errors

enum DataSourceError: Error, LocalizedError {
    case unknown
    case notFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown data source error"
        case .notFound:
            return "Data not found"
        case .saveFailed:
            return "Failed to save data"
        }
    }
}
