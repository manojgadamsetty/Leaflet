//
//  Note.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation

/// Domain model for a note
struct Note: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var content: String
    var tags: [String]
    var isImportant: Bool
    var isArchived: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        title: String = "",
        content: String = "",
        tags: [String] = [],
        isImportant: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.tags = tags
        self.isImportant = isImportant
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Computed Properties

extension Note {
    var isEmpty: Bool {
        return title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var formattedCreatedDate: String {
        return DateFormatter.noteDateFormatter.string(from: createdAt)
    }
    
    var formattedUpdatedDate: String {
        return DateFormatter.noteDateFormatter.string(from: updatedAt)
    }
    
    var preview: String {
        let maxLength = 100
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedContent.count <= maxLength {
            return trimmedContent
        } else {
            let endIndex = trimmedContent.index(trimmedContent.startIndex, offsetBy: maxLength)
            return String(trimmedContent[..<endIndex]) + "..."
        }
    }
}

// MARK: - DateFormatter Extension

private extension DateFormatter {
    static let noteDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
