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
        let viewModel = dependencyContainer.makeNotesListViewModel()
        let notesListVC = NotesListViewController(viewModel: viewModel)
        
        // Set up navigation actions
        notesListVC.onNoteSelected = { [weak self] noteId in
            self?.showNoteDetail(noteId: noteId)
        }
        
        notesListVC.onCreateNote = { [weak self] in
            self?.showNoteDetail(noteId: nil)
        }
        
        navigationController.setViewControllers([notesListVC], animated: false)
    }
    
    private func showNoteDetail(noteId: String?) {
        let viewModel = dependencyContainer.makeNoteDetailViewModel(noteId: noteId)
        let mode: NoteDetailMode = noteId == nil ? .create : .view
        let noteDetailVC = NoteDetailViewController(viewModel: viewModel, mode: mode)
        
        // Set up navigation actions
        noteDetailVC.onDismiss = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        noteDetailVC.onSave = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        noteDetailVC.onEdit = { [weak self] noteId in
            // Replace current detail view with edit mode
            let editViewModel = self?.dependencyContainer.makeNoteDetailViewModel(noteId: noteId)
            if let editViewModel = editViewModel {
                let editVC = NoteDetailViewController(viewModel: editViewModel, mode: .edit)
                editVC.onDismiss = { [weak self] in
                    self?.navigationController.popViewController(animated: true)
                }
                editVC.onSave = { [weak self] in
                    self?.navigationController.popViewController(animated: true)
                }
                self?.navigationController.pushViewController(editVC, animated: true)
            }
        }
        
        navigationController.pushViewController(noteDetailVC, animated: true)
    }
}
