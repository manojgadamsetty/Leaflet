//
//  Coordinator.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import UIKit

/// Base protocol for all coordinators
/// Defines the basic structure for navigation coordination
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    
    func start()
    func addChild(_ coordinator: Coordinator)
    func removeChild(_ coordinator: Coordinator)
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
