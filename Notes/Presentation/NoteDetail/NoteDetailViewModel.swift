import Foundation
import Combine
import UIKit

class NoteDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var note: Note?
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var tags: [String] = []
    @Published var newTag: String = ""
    @Published var isImportant: Bool = false
    @Published var isArchived: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasUnsavedChanges = false
    
    // MARK: - Private Properties
    private let fetchNoteDetailUseCase: FetchNoteDetailUseCase
    private let saveNoteUseCase: SaveNoteUseCase
    private let coordinator: NotesCoordinator
    private var cancellables = Set<AnyCancellable>()
    private var originalNote: Note?
    private let isNewNote: Bool
    
    // MARK: - Computed Properties
    var navigationTitle: String {
        return isNewNote ? "New Note" : "Edit Note"
    }
    
    var saveButtonTitle: String {
        return isNewNote ? "Create" : "Save"
    }
    
    var canSave: Bool {
        let titleNotEmpty = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let result = titleNotEmpty && hasUnsavedChanges
        print("🔍 canSave check: title='\(title)', titleNotEmpty=\(titleNotEmpty), hasUnsavedChanges=\(hasUnsavedChanges), result=\(result)")
        return result
    }
    
    // MARK: - Initialization
    init(note: Note?, fetchNoteDetailUseCase: FetchNoteDetailUseCase, saveNoteUseCase: SaveNoteUseCase, coordinator: NotesCoordinator) {
        self.note = note
        self.originalNote = note
        self.fetchNoteDetailUseCase = fetchNoteDetailUseCase
        self.saveNoteUseCase = saveNoteUseCase
        self.coordinator = coordinator
        self.isNewNote = note == nil
        
        setupInitialValues()
        setupBindings()
        
        if let note = note {
            loadNoteDetail(noteId: note.id)
        }
    }
    
    // MARK: - Public Methods
    func loadNoteDetail(noteId: String) {
        guard !isNewNote else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let noteDetail = try await fetchNoteDetailUseCase.execute(noteId: noteId)
                await MainActor.run {
                    if let noteDetail = noteDetail {
                        self.updateWithNote(noteDetail)
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func saveNote() {
        guard canSave else { 
            print("❌ Cannot save - canSave is false")
            return 
        }
        
        print("🚀 Starting save process...")
        isLoading = true
        errorMessage = nil
        
        let noteToSave = createNoteFromCurrentState()
        print("📝 Note to save: \(noteToSave)")
        
        Task {
            do {
                print("🔄 Calling saveNoteUseCase...")
                let savedNote = try await saveNoteUseCase.execute(note: noteToSave)
                print("✅ Note saved successfully: \(savedNote)")
                await MainActor.run {
                    self.updateWithNote(savedNote)
                    self.hasUnsavedChanges = false
                    self.isLoading = false
                    self.coordinator.didSaveNote()
                }
            } catch {
                print("❌ Failed to save note: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to save note: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func deleteNote() {
        guard let _ = note, !isNewNote else { return }
        
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement delete use case
        Task {
            // try await deleteNoteUseCase.execute(noteId: note.id)
            await MainActor.run {
                self.isLoading = false
                self.coordinator.didDeleteNote()
            }
        }
    }
    
    func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty && !tags.contains(trimmedTag) else {
            newTag = ""
            return
        }
        
        tags.append(trimmedTag)
        newTag = ""
    }
    
    func removeTag(at index: Int) {
        guard index < tags.count else { return }
        tags.remove(at: index)
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    func toggleImportant() {
        isImportant.toggle()
    }
    
    func toggleArchived() {
        isArchived.toggle()
    }
    
    func dismissKeyboard() {
        // This will be called from the view controller
    }
    
    func showDiscardChangesAlert() -> Bool {
        return hasUnsavedChanges
    }
    
    func discardChanges() {
        coordinator.didCancelNote()
    }
    
    func cancelEditing() {
        if hasUnsavedChanges {
            // View controller should show alert
        } else {
            coordinator.didCancelNote()
        }
    }
    
    // MARK: - Private Methods
    private func setupInitialValues() {
        if let note = note {
            title = note.title
            content = note.content
            tags = note.tags
            isImportant = note.isImportant
            isArchived = note.isArchived
        }
    }
    
    private func setupBindings() {
        // Monitor changes to detect unsaved changes
        Publishers.CombineLatest4($title, $content, $tags, Publishers.CombineLatest($isImportant, $isArchived))
            .dropFirst() // Skip initial value
            .sink { [weak self] _, _, _, _ in
                self?.checkForUnsavedChanges()
            }
            .store(in: &cancellables)
    }
    
    private func checkForUnsavedChanges() {
        print("🔄 Checking for unsaved changes...")
        guard let originalNote = originalNote else {
            // New note - has changes if any field is not empty
            let newHasChanges = !title.isEmpty || !content.isEmpty || !tags.isEmpty
            print("📝 New note: title='\(title)', content='\(content)', tags=\(tags), hasChanges=\(newHasChanges)")
            hasUnsavedChanges = newHasChanges
            return
        }
        
        let titleChanged = title != originalNote.title
        let contentChanged = content != originalNote.content
        let tagsChanged = tags != originalNote.tags
        let importantChanged = isImportant != originalNote.isImportant
        let archivedChanged = isArchived != originalNote.isArchived
        
        hasUnsavedChanges = titleChanged || contentChanged || tagsChanged || importantChanged || archivedChanged
        
        print("📋 Existing note changes: title=\(titleChanged), content=\(contentChanged), tags=\(tagsChanged), important=\(importantChanged), archived=\(archivedChanged), hasChanges=\(hasUnsavedChanges)")
    }
    
    private func updateWithNote(_ note: Note) {
        self.note = note
        self.originalNote = note
        self.title = note.title
        self.content = note.content
        self.tags = note.tags
        self.isImportant = note.isImportant
        self.isArchived = note.isArchived
        self.hasUnsavedChanges = false
    }
    
    private func createNoteFromCurrentState() -> Note {
        let now = Date()
        return Note(
            id: note?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content,
            tags: tags,
            isImportant: isImportant,
            isArchived: isArchived,
            createdAt: note?.createdAt ?? now,
            updatedAt: now
        )
    }
}

// MARK: - Helper Extensions
extension NoteDetailViewModel {
    
    var formattedCreatedDate: String {
        guard let note = note else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Created: \(formatter.string(from: note.createdAt))"
    }
    
    var formattedUpdatedDate: String {
        guard let note = note else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Updated: \(formatter.string(from: note.updatedAt))"
    }
    
    var wordCount: String {
        let words = content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        return "\(words.count) words"
    }
    
    var characterCount: String {
        return "\(content.count) characters"
    }
    
    var tagsDisplay: String {
        return tags.isEmpty ? "No tags" : tags.joined(separator: ", ")
    }
}

// MARK: - Tag Management
extension NoteDetailViewModel {
    
    func suggestedTags() -> [String] {
        // TODO: Implement suggested tags based on content analysis or user history
        return ["Work", "Personal", "Ideas", "Important", "Todo", "Meeting", "Project"]
    }
    
    func isValidTag(_ tag: String) -> Bool {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 20 && !tags.contains(trimmed)
    }
}
