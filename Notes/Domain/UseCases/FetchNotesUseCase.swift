//
//  FetchNotesUseCase.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation
import Combine

/// Use case for fetching notes
/// Handles the business logic for retrieving notes with various filters
final class FetchNotesUseCase {
    
    private let repository: NotesRepository
    
    init(repository: NotesRepository) {
        self.repository = repository
    }
    
    func execute(
        searchQuery: String? = nil,
        showArchived: Bool = false,
        showFavorites: Bool = false
    ) -> AnyPublisher<[Note], Error> {
        
        return repository.fetchNotes()
            .map { notes in
                var filteredNotes = notes
                
                // Filter archived notes
                if !showArchived {
                    filteredNotes = filteredNotes.filter { !$0.isArchived }
                }
                
                // Filter favorites
                if showFavorites {
                    filteredNotes = filteredNotes.filter { $0.isFavorite }
                }
                
                // Apply search query
                if let query = searchQuery, !query.isEmpty {
                    filteredNotes = filteredNotes.filter { note in
                        note.title.localizedCaseInsensitiveContains(query) ||
                        note.content.localizedCaseInsensitiveContains(query) ||
                        note.tags.contains { $0.localizedCaseInsensitiveContains(query) }
                    }
                }
                
                // Sort by update date (most recent first)
                return filteredNotes.sorted { $0.updatedAt > $1.updatedAt }
            }
            .eraseToAnyPublisher()
    }
}
