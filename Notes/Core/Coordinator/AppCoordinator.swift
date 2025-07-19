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
    
    private let window: UIWindow
    private let dependencyContainer: DependencyContainer
    
    init(window: UIWindow, dependencyContainer: DependencyContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        self.navigationController = UINavigationController()
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
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
