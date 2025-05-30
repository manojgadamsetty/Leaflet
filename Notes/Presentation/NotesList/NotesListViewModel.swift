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
    private let saveNoteUseCase: SaveNoteUseCase
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
    init(fetchNotesUseCase: FetchNotesUseCase, saveNoteUseCase: SaveNoteUseCase, coordinator: NotesCoordinator) {
        self.fetchNotesUseCase = fetchNotesUseCase
        self.saveNoteUseCase = saveNoteUseCase
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
    
    func addDummyData() {
        isLoading = true
        errorMessage = nil
        
        let dummyNotes = createRealisticDummyNotes()
        
        Task {
            do {
                // Save each dummy note
                for note in dummyNotes {
                    _ = try await saveNoteUseCase.execute(note: note)
                }
                
                // Reload notes to show the new data
                let fetchedNotes = try await fetchNotesUseCase.execute()
                await MainActor.run {
                    self.notes = fetchedNotes
                    self.isLoading = false
                    self.filterNotes()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to add dummy data: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
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
    
    // MARK: - Dummy Data Creation
    private func createRealisticDummyNotes() -> [Note] {
        let now = Date()
        let calendar = Calendar.current
        
        return [
            Note(
                title: "Project Meeting Notes",
                content: """
                📋 Sprint Planning Meeting - Q3 2025
                
                Attendees: Sarah, Mike, Alex, Jennifer
                
                Key Discussion Points:
                • Backend API optimization - reduce response time by 40%
                • Mobile app UI/UX improvements
                • Database migration timeline
                • Testing automation setup
                
                Action Items:
                ✅ Complete API documentation by Friday
                ⏳ Setup CI/CD pipeline (Alex)
                ⏳ Design review for new dashboard (Sarah)
                ⏳ Performance testing (Mike)
                
                Next Meeting: Thursday 2 PM
                """,
                tags: ["work", "meeting", "project", "planning"],
                isImportant: true,
                createdAt: calendar.date(byAdding: .day, value: -2, to: now) ?? now
            ),
            
            Note(
                title: "Weekend Recipe Ideas",
                content: """
                🍳 Trying new recipes this weekend!
                
                Saturday Brunch:
                • Avocado Toast with Poached Eggs
                • Fresh Berry Smoothie Bowl
                • Homemade Granola with Greek Yogurt
                
                Sunday Dinner:
                • Herb-Crusted Salmon with Lemon
                • Roasted Vegetables (Brussels sprouts, carrots)
                • Quinoa Pilaf with Almonds
                
                Shopping List:
                - Avocados (3)
                - Eggs (dozen)
                - Mixed berries
                - Salmon fillets
                - Fresh herbs (dill, parsley)
                - Quinoa
                - Almonds
                """,
                tags: ["food", "recipes", "weekend", "cooking"],
                isImportant: false,
                createdAt: calendar.date(byAdding: .hour, value: -6, to: now) ?? now
            ),
            
            Note(
                title: "Travel Itinerary - Japan Trip",
                content: """
                🗾 Japan Adventure - October 2025
                
                Tokyo (3 days):
                Day 1: Arrive at Haneda, check into Shibuya hotel
                • Visit Senso-ji Temple
                • Explore Nakamise Shopping Street
                • Dinner in Shibuya
                
                Day 2: Modern Tokyo
                • Tsukiji Outer Market breakfast
                • TeamLab Borderless
                • Tokyo Skytree sunset
                
                Day 3: Culture & Gardens
                • Meiji Shrine
                • Harajuku district
                • Imperial Palace East Gardens
                
                Kyoto (4 days):
                • Fushimi Inari Shrine
                • Kinkaku-ji (Golden Pavilion)
                • Bamboo Grove, Arashiyama
                • Traditional tea ceremony
                
                Must try: Ramen, Sushi, Takoyaki, Matcha Kit-Kats
                """,
                tags: ["travel", "japan", "vacation", "itinerary"],
                isImportant: true,
                createdAt: calendar.date(byAdding: .day, value: -5, to: now) ?? now
            ),
            
            Note(
                title: "Book Recommendations",
                content: """
                📚 Must-Read Books for 2025
                
                Fiction:
                • "The Seven Husbands of Evelyn Hugo" - Taylor Jenkins Reid
                • "Where the Crawdads Sing" - Delia Owens
                • "Project Hail Mary" - Andy Weir
                • "The Midnight Library" - Matt Haig
                
                Non-Fiction:
                • "Atomic Habits" - James Clear
                • "Educated" - Tara Westover
                • "Sapiens" - Yuval Noah Harari
                • "The Psychology of Money" - Morgan Housel
                
                Tech/Programming:
                • "Clean Code" - Robert C. Martin
                • "System Design Interview" - Alex Xu
                • "Designing Data-Intensive Applications" - Martin Kleppmann
                
                Currently Reading: "The Power of Now" by Eckhart Tolle
                """,
                tags: ["books", "reading", "recommendations", "learning"],
                isImportant: false,
                createdAt: calendar.date(byAdding: .day, value: -1, to: now) ?? now
            ),
            
            Note(
                title: "Fitness Goals & Workout Plan",
                content: """
                💪 Q3 Fitness Goals
                
                Primary Goals:
                • Run 5K in under 25 minutes
                • Increase bench press to bodyweight
                • Improve flexibility - touch toes without bending knees
                • Consistency: 4 workouts per week
                
                Weekly Schedule:
                Monday: Upper body strength
                Tuesday: 3-mile run
                Wednesday: Core & flexibility
                Thursday: Lower body strength
                Friday: HIIT cardio
                Weekend: Yoga or hiking
                
                Nutrition Focus:
                • 8 glasses of water daily
                • Protein with every meal
                • Reduce processed sugar
                • Meal prep Sundays
                
                Progress Tracking:
                Week 1: ✅ 4/4 workouts completed
                Week 2: ⏳ 2/4 workouts so far
                """,
                tags: ["fitness", "health", "goals", "workout"],
                isImportant: true,
                createdAt: calendar.date(byAdding: .hour, value: -3, to: now) ?? now
            ),
            
            Note(
                title: "Gift Ideas for Mom's Birthday",
                content: """
                🎁 Mom's 60th Birthday - August 15th
                
                Ideas brainstormed so far:
                • Spa day package at her favorite resort
                • Premium tea collection from around the world
                • Digital photo frame with family memories
                • Cooking class for Italian cuisine
                • Weekend getaway to wine country
                • Subscription to her favorite magazine
                • Custom jewelry with birthstones
                • Professional family photoshoot
                
                Budget: $200-300
                
                Top 3 favorites:
                1. Spa day package ⭐⭐⭐
                2. Weekend wine country trip ⭐⭐⭐
                3. Italian cooking class ⭐⭐
                
                Need to decide by: August 1st
                """,
                tags: ["family", "birthday", "gifts", "mom"],
                isImportant: false,
                createdAt: calendar.date(byAdding: .hour, value: -12, to: now) ?? now
            ),
            
            Note(
                title: "Home Improvement Projects",
                content: """
                🏠 Summer Home Projects 2025
                
                Priority 1 (July):
                • Paint master bedroom - soft blue color
                • Fix leaky kitchen faucet
                • Install smart thermostat
                • Deep clean garage and organize tools
                
                Priority 2 (August):
                • Update bathroom light fixtures
                • Plant herb garden in backyard
                • Repair deck staining
                • Clean gutters
                
                Future Projects:
                • Kitchen backsplash renovation
                • Basement finishing
                • Solar panel installation research
                
                Budget Estimates:
                Painting: $150-200
                Faucet repair: $80-120
                Smart thermostat: $250
                Light fixtures: $300-400
                
                Contractors to call:
                • Mike's Plumbing: (555) 123-4567
                • GreenThumb Landscaping: (555) 234-5678
                """,
                tags: ["home", "renovation", "DIY", "summer"],
                isImportant: false,
                createdAt: calendar.date(byAdding: .day, value: -3, to: now) ?? now
            ),
            
            Note(
                title: "Learning Swift & iOS Development",
                content: """
                📱 iOS Development Learning Path
                
                Completed ✅:
                • Swift fundamentals
                • Basic UIKit components
                • Auto Layout and constraints
                • MVC architecture pattern
                • Core Data basics
                
                Currently Learning:
                • MVVM architecture
                • Combine framework
                • SwiftUI basics
                • Unit testing with XCTest
                
                Next Steps:
                • Advanced SwiftUI
                • Networking with URLSession
                • App Store deployment
                • Performance optimization
                • Accessibility features
                
                Practice Projects:
                1. Weather app with API integration
                2. Personal expense tracker
                3. Recipe sharing app
                4. Habit tracking app
                
                Resources:
                • Stanford CS193p course
                • Ray Wenderlich tutorials
                • Apple's Human Interface Guidelines
                • iOS Dev Weekly newsletter
                """,
                tags: ["programming", "ios", "swift", "learning", "development"],
                isImportant: true,
                createdAt: calendar.date(byAdding: .day, value: -7, to: now) ?? now
            )
        ]
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
