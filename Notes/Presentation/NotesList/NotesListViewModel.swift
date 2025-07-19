import Foundation
import Combine
import UIKit

class NotesListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var filteredNotes: [Note] = []
    @Published var selectedCategory: NoteCategory = .all
    
    // MARK: - Private Properties
    private let fetchNotesUseCase: FetchNotesUseCase
    private let coordinator: NotesCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Enums
    enum NoteCategory: String, CaseIterable {
        case all = "All"
        case recent = "Recent"
        case important = "Important"
        case archived = "Archived"
        
        var title: String {
            return rawValue
        }
        
        var icon: String {
            switch self {
            case .all: return "doc.text"
            case .recent: return "clock"
            case .important: return "star"
            case .archived: return "archivebox"
            }
        }
    }
    
    // MARK: - Initialization
    init(fetchNotesUseCase: FetchNotesUseCase, coordinator: NotesCoordinator) {
        self.fetchNotesUseCase = fetchNotesUseCase
        self.coordinator = coordinator
        setupBindings()
        loadNotes()
    }
    
    // MARK: - Public Methods
    func loadNotes() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedNotes = try await fetchNotesUseCase.execute()
                await MainActor.run {
                    self.notes = fetchedNotes
                    self.isLoading = false
                    self.filterNotes()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshNotes() {
        loadNotes()
    }
    
    func didSelectNote(_ note: Note) {
        coordinator.showNoteDetail(note: note)
    }
    
    func addNewNote() {
        coordinator.showNoteDetail(note: nil)
    }
    
    func deleteNote(_ note: Note) {
        // Remove from local array immediately for better UX
        notes.removeAll { $0.id == note.id }
        filterNotes()
        
        // TODO: Implement delete use case
        // Task {
        //     try await deleteNoteUseCase.execute(noteId: note.id)
        // }
    }
    
    func toggleNoteImportant(_ note: Note) {
        // Update local array immediately
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isImportant.toggle()
            filterNotes()
        }
        
        // TODO: Implement update use case
        // Task {
        //     try await updateNoteUseCase.execute(note: updatedNote)
        // }
    }
    
    func archiveNote(_ note: Note) {
        // Update local array immediately
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isArchived.toggle()
            filterNotes()
        }
        
        // TODO: Implement archive use case
        // Task {
        //     try await archiveNoteUseCase.execute(noteId: note.id)
        // }
    }
    
    func searchNotes(with text: String) {
        searchText = text
        filterNotes()
    }
    
    func selectCategory(_ category: NoteCategory) {
        selectedCategory = category
        filterNotes()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Combine search text and category changes to filter notes
        Publishers.CombineLatest3($searchText, $selectedCategory, $notes)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.filterNotes()
            }
            .store(in: &cancellables)
    }
    
    private func filterNotes() {
        var filtered = notes
        
        // Filter by category
        switch selectedCategory {
        case .all:
            filtered = notes
        case .recent:
            let calendar = Calendar.current
            let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
            filtered = notes.filter { $0.createdAt >= oneWeekAgo }
        case .important:
            filtered = notes.filter { $0.isImportant }
        case .archived:
            filtered = notes.filter { $0.isArchived }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sort by most recent first
        filtered.sort { $0.updatedAt > $1.updatedAt }
        
        filteredNotes = filtered
    }
}

// MARK: - Helper Extensions
extension NotesListViewModel {
    
    var hasNotes: Bool {
        return !filteredNotes.isEmpty
    }
    
    var emptyStateMessage: String {
        if searchText.isEmpty {
            switch selectedCategory {
            case .all:
                return "No notes yet.\nTap + to create your first note."
            case .recent:
                return "No recent notes.\nCreate a note to see it here."
            case .important:
                return "No important notes.\nMark notes as important to see them here."
            case .archived:
                return "No archived notes.\nArchive notes to see them here."
            }
        } else {
            return "No notes found for '\(searchText)'"
        }
    }
    
    var emptyStateIcon: String {
        if searchText.isEmpty {
            switch selectedCategory {
            case .all: return "doc.text"
            case .recent: return "clock"
            case .important: return "star"
            case .archived: return "archivebox"
            }
        } else {
            return "magnifyingglass"
        }
    }
}
