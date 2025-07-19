//
//  NotesRemoteDataSource.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation
import Combine

/// Remote data source for notes
/// Handles synchronization with remote server (future implementation)
final class NotesRemoteDataSource {
    
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchNotes() -> AnyPublisher<[Note], Error> {
        // Future implementation for remote sync
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func saveNote(_ note: Note) -> AnyPublisher<Note, Error> {
        // Future implementation for remote sync
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
