//
//  NotesCache.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation

/// In-memory cache for notes
/// Provides fast access to recently accessed notes
final class NotesCache {
    
    private var cachedNotes: [String: Note] = [:]
    private let queue = DispatchQueue(label: "notes.cache", attributes: .concurrent)
    
    func getCachedNotes() -> [Note] {
        return queue.sync {
            Array(cachedNotes.values)
        }
    }
    
    func getCachedNote(id: String) -> Note? {
        return queue.sync {
            cachedNotes[id]
        }
    }
    
    func cacheNote(_ note: Note) {
        queue.async(flags: .barrier) {
            self.cachedNotes[note.id] = note
        }
    }
    
    func cacheNotes(_ notes: [Note]) {
        queue.async(flags: .barrier) {
            for note in notes {
                self.cachedNotes[note.id] = note
            }
        }
    }
    
    func removeCachedNote(id: String) {
        queue.async(flags: .barrier) {
            self.cachedNotes.removeValue(forKey: id)
        }
    }
    
    func clearCache() {
        queue.async(flags: .barrier) {
            self.cachedNotes.removeAll()
        }
    }
}
