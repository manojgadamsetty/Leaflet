//
//  APIService.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation
import Combine

/// API service for network requests
/// Handles communication with remote servers for note synchronization
final class APIService {
    
    private let session = URLSession.shared
    private let baseURL = URL(string: "https://api.leaflet.app")!
    
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard let url = endpoint.url(baseURL: baseURL) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        request.httpBody = endpoint.body
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.requestFailed
                }
            }
            .eraseToAnyPublisher()
    }
}
