//
//  NoteEntity+CoreDataProperties.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation
import CoreData

extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var tagsArray: NSArray?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isArchived: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}

extension NoteEntity: Identifiable {

}
