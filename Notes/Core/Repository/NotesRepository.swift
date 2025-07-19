//
//  NotesRepository.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation
import Combine

/// Protocol defining the notes repository interface
/// Abstracts data access for notes from various sources
protocol NotesRepository {
    func fetchNotes() -> AnyPublisher<[Note], Error>
    func fetchNote(id: String) -> AnyPublisher<Note?, Error>
    func saveNote(_ note: Note) -> AnyPublisher<Note, Error>
    func deleteNote(id: String) -> AnyPublisher<Void, Error>
    func searchNotes(query: String) -> AnyPublisher<[Note], Error>
}

/// Implementation of the notes repository
/// Coordinates between local and remote data sources with caching
final class NotesRepositoryImpl: NotesRepository {
    
    private let localDataSource: NotesLocalDataSource
    private let remoteDataSource: NotesRemoteDataSource
    private let cache: NotesCache
    
    init(
        localDataSource: NotesLocalDataSource,
        remoteDataSource: NotesRemoteDataSource,
        cache: NotesCache
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.cache = cache
    }
    
    func fetchNotes() -> AnyPublisher<[Note], Error> {
        // Return cached data immediately if available, then update from local/remote
        let cachedNotes = cache.getCachedNotes()
        
        return localDataSource.fetchNotes()
            .handleEvents(receiveOutput: { [weak self] notes in
                self?.cache.cacheNotes(notes)
            })
            .catch { [weak self] _ in
                // Fallback to cached data if local fetch fails
                return Just(cachedNotes)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchNote(id: String) -> AnyPublisher<Note?, Error> {
        return localDataSource.fetchNote(id: id)
    }
    
    func saveNote(_ note: Note) -> AnyPublisher<Note, Error> {
        return localDataSource.saveNote(note)
            .handleEvents(receiveOutput: { [weak self] savedNote in
                self?.cache.cacheNote(savedNote)
            })
            .eraseToAnyPublisher()
    }
    
    func deleteNote(id: String) -> AnyPublisher<Void, Error> {
        return localDataSource.deleteNote(id: id)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.cache.removeCachedNote(id: id)
            })
            .eraseToAnyPublisher()
    }
    
    func searchNotes(query: String) -> AnyPublisher<[Note], Error> {
        return localDataSource.searchNotes(query: query)
    }
}
