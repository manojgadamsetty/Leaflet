//
//  FetchNotesUseCase.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation

/// Use case for fetching notes
/// Handles the business logic for retrieving notes with various filters
final class FetchNotesUseCase {
    
    private let repository: NotesRepository
    
    init(repository: NotesRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Note] {
        // For now, return sample data until we implement the full repository
        return createSampleNotes()
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
                createdAt: now.addingTimeInterval(-86400 * 7), // 7 days ago
                updatedAt: now.addingTimeInterval(-86400 * 2)  // 2 days ago
            ),
            Note(
                id: "2",
                title: "Meeting Notes",
                content: "Project kick-off meeting:\n- Discussed project timeline\n- Assigned team roles\n- Set up weekly check-ins\n- Next meeting: Friday 2PM",
                tags: ["work", "meeting", "project"],
                isImportant: false,
                isArchived: false,
                createdAt: now.addingTimeInterval(-86400 * 5), // 5 days ago
                updatedAt: now.addingTimeInterval(-86400 * 1)  // 1 day ago
            ),
            Note(
                id: "3",
                title: "Grocery List",
                content: "🛒 Shopping list:\n• Milk\n• Bread\n• Eggs\n• Apples\n• Chicken\n• Rice\n• Vegetables",
                tags: ["personal", "shopping"],
                isImportant: false,
                isArchived: false,
                createdAt: now.addingTimeInterval(-86400 * 3), // 3 days ago
                updatedAt: now.addingTimeInterval(-3600 * 6)   // 6 hours ago
            ),
            Note(
                id: "4",
                title: "Book Ideas",
                content: "Ideas for my next novel:\n\n1. Sci-fi thriller about AI consciousness\n2. Historical fiction set in Renaissance Italy\n3. Mystery novel in a small coastal town\n\nNeed to research publishing options and literary agents.",
                tags: ["creative", "writing", "books"],
                isImportant: true,
                isArchived: false,
                createdAt: now.addingTimeInterval(-86400 * 10), // 10 days ago
                updatedAt: now.addingTimeInterval(-3600 * 2)    // 2 hours ago
            ),
            Note(
                id: "5",
                title: "Old Project Notes",
                content: "These are some old project notes that I've archived. They contain important information but are no longer actively used.",
                tags: ["work", "archived", "old"],
                isImportant: false,
                isArchived: true,
                createdAt: now.addingTimeInterval(-86400 * 30), // 30 days ago
                updatedAt: now.addingTimeInterval(-86400 * 15)  // 15 days ago
            )
        ]
    }
}
                return filteredNotes.sorted { $0.updatedAt > $1.updatedAt }
            }
            .eraseToAnyPublisher()
    }
}
