//
//  NoteEntity+Extensions.swift
//  Notes
//
//  Created on 19 July 2025.
//

import Foundation
import CoreData

extension NoteEntity {
    func toDomainModel() -> Note? {
        guard let id = id,
              let title = title,
              let content = content,
              let createdAt = createdAt,
              let updatedAt = updatedAt else {
            return nil
        }
        
        let tags = (tagsArray as? [String]) ?? []
        
        return Note(
            id: id,
            title: title,
            content: content,
            tags: tags,
            isImportant: isImportant,
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
        self.isImportant = note.isImportant
        self.isArchived = note.isArchived
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
    }
}
