//
//  DependencyContainer.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation

/// Dependency injection container
/// Manages the creation and lifecycle of dependencies throughout the app
final class DependencyContainer {
    
    // MARK: - Core Services
    
    private lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack()
    }()
    
    private lazy var apiService: APIService = {
        return APIService()
    }()
    
    private lazy var notesCache: NotesCache = {
        return NotesCache()
    }()
    
    // MARK: - Data Sources
    
    private lazy var notesLocalDataSource: NotesLocalDataSource = {
        return NotesLocalDataSource(coreDataStack: coreDataStack)
    }()
    
    private lazy var notesRemoteDataSource: NotesRemoteDataSource = {
        return NotesRemoteDataSource(apiService: apiService)
    }()
    
    // MARK: - Repositories
    
    private lazy var notesRepository: NotesRepository = {
        return NotesRepositoryImpl(
            localDataSource: notesLocalDataSource,
            remoteDataSource: notesRemoteDataSource,
            cache: notesCache
        )
    }()
    
    // MARK: - Use Cases
    
    func makeFetchNotesUseCase() -> FetchNotesUseCase {
        return FetchNotesUseCase(repository: notesRepository)
    }
    
    func makeFetchNoteDetailUseCase() -> FetchNoteDetailUseCase {
        return FetchNoteDetailUseCase(repository: notesRepository)
    }
    
    func makeSaveNoteUseCase() -> SaveNoteUseCase {
        return SaveNoteUseCase(repository: notesRepository)
    }
    
    // MARK: - ViewModels
    
    func makeNotesListViewModel(coordinator: NotesCoordinator) -> NotesListViewModel {
        return NotesListViewModel(
            fetchNotesUseCase: makeFetchNotesUseCase(),
            saveNoteUseCase: makeSaveNoteUseCase(),
            coordinator: coordinator
        )
    }
    
    func makeNoteDetailViewModel(note: Note?, coordinator: NotesCoordinator) -> NoteDetailViewModel {
        return NoteDetailViewModel(
            note: note,
            fetchNoteDetailUseCase: makeFetchNoteDetailUseCase(),
            saveNoteUseCase: makeSaveNoteUseCase(),
            coordinator: coordinator
        )
    }
}
