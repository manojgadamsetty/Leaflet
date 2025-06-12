//
//  SaveNoteUseCase.swift
//  Leaflet
//
//  Created by Manoj Gadamsetty on 19/07/25.
//

import Foundation
import Combine

/// Use case for saving a note
/// Handles business logic for note saving operations
final class SaveNoteUseCase {
    
    private let repository: NotesRepository
    
    init(repository: NotesRepository) {
        self.repository = repository
    }
    
    /// Saves a note to the repository
    /// - Parameter note: The note to save
    /// - Returns: The saved note with updated metadata
    func execute(note: Note) async throws -> Note {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = repository.saveNote(note)
                .sink(
                    receiveCompletion: { completion in
                        cancellable = nil
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { savedNote in
                        cancellable = nil
                        continuation.resume(returning: savedNote)
                    }
                )
        }
    }
}
