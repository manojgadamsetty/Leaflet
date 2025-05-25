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
    
    func execute(noteId: String) async throws -> Note? {
        // Use the repository to fetch note details
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = repository.fetchNotes()
                .sink(
                    receiveCompletion: { completion in
                        cancellable?.cancel()
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { notes in
                        cancellable?.cancel()
                        let note = notes.first { $0.id == noteId }
                        continuation.resume(returning: note)
                    }
                )
        }
    }
    
    private func createSampleNotes() -> [Note] {
        let now = Date()
        
        return [
            Note(
                id: "1",
                title: "Welcome to Leaflet",
                content: "Welcome to your new notes app! This is a sample note to get you started. You can create, edit, and organize your thoughts here.",
                tags: ["welcome", "getting-started"],
                isImportant: true,
                isArchived: false,
                createdAt: now.addingTimeInterval(-86400 * 7),
                updatedAt: now.addingTimeInterval(-86400 * 2)
            ),
            Note(
                id: "2",
                title: "Meeting Notes",
                content: "Project kick-off meeting:\n- Discussed project timeline\n- Assigned team roles\n- Set up weekly check-ins\n- Next meeting: Friday 2PM",
                tags: ["work", "meeting", "project"],
                isImportant: false,
                isArchived: false,
                createdAt: now.addingTimeInterval(-86400 * 5),
                updatedAt: now.addingTimeInterval(-86400 * 1)
            )
        ]
    }
}
