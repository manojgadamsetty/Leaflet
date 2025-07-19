//
//  NetworkError.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation

/// Network-related errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case decodingError
    case noConnection
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed:
            return "Request failed"
        case .decodingError:
            return "Failed to decode response"
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timeout"
        }
    }
}
