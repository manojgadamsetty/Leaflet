//
//  NoteEntity+CoreDataClass.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation
import CoreData

@objc(NoteEntity)
public class NoteEntity: NSManagedObject {
    
    func toDomainModel() -> Note? {
        guard let id = id,
              let title = title,
              let content = content,
              let createdAt = createdAt,
              let updatedAt = updatedAt else {
            return nil
        }
        
        let tags = tagsArray?.compactMap { $0 as? String } ?? []
        
        return Note(
            id: id,
            title: title,
            content: content,
            tags: tags,
            isFavorite: isFavorite,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    func updateFromDomainModel(_ note: Note) {
        self.id = note.id
        self.title = note.title
        self.content = note.content
        self.tagsArray = note.tags as NSArray
        self.isFavorite = note.isFavorite
        self.isArchived = note.isArchived
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
    }
}
