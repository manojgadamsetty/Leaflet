//
//  FetchNoteDetailUseCase.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation

/// Use case for fetching a specific note's details
/// Handles the business logic for retrieving a single note
final class FetchNoteDetailUseCase {
    
    private let repository: NotesRepository
    
    init(repository: NotesRepository) {
        self.repository = repository
    }
    
    func execute(noteId: String) async throws -> Note? {
        // For now, return mock data
        let sampleNotes = createSampleNotes()
        return sampleNotes.first { $0.id == noteId }
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
