//
//  NotesCoordinator.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import UIKit

/// Coordinator for notes-related navigation
/// Handles navigation between notes list and note detail screens
final class NotesCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let dependencyContainer: DependencyContainer
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {
        showNotesList()
    }
    
    private func showNotesList() {
        let viewModel = dependencyContainer.makeNotesListViewModel(coordinator: self)
        let notesListVC = NotesListViewController(viewModel: viewModel)
        
        navigationController.setViewControllers([notesListVC], animated: false)
    }
    
    func showNoteDetail(note: Note?) {
        let viewModel = dependencyContainer.makeNoteDetailViewModel(note: note, coordinator: self)
        let noteDetailVC = NoteDetailViewController(viewModel: viewModel)
        
        navigationController.pushViewController(noteDetailVC, animated: true)
    }
    
    func didSaveNote() {
        navigationController.popViewController(animated: true)
    }
    
    func didCancelNote() {
        navigationController.popViewController(animated: true)
    }
    
    func didDeleteNote() {
        navigationController.popViewController(animated: true)
    }
}
