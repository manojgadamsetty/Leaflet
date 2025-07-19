//
//  FetchNoteDetailUseCase.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation
import Combine

/// Use case for fetching a specific note's details
/// Handles the business logic for retrieving a single note
final class FetchNoteDetailUseCase {
    
    private let repository: NotesRepository
    
    init(repository: NotesRepository) {
        self.repository = repository
    }
    
    func execute(noteId: String) -> AnyPublisher<Note?, Error> {
        return repository.fetchNote(id: noteId)
    }
}
