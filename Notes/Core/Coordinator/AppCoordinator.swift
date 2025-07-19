//
//  AppCoordinator.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import UIKit

/// Main application coordinator
/// Manages the overall navigation flow of the application
final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let dependencyContainer: DependencyContainer
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependencyContainer = DependencyContainer()
    }
    
    func start() {
        // Start with notes list
        showNotesList()
    }
    
    private func showNotesList() {
        let notesCoordinator = NotesCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        addChild(notesCoordinator)
        notesCoordinator.start()
    }
}
