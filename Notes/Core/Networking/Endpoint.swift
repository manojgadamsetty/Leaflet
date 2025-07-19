//
//  Endpoint.swift
//  Leaflet
//
//  Created on 18 July 2025.
//

import Foundation

/// HTTP methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

/// API endpoint definition
struct Endpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
    
    init(path: String, method: HTTPMethod, headers: [String: String] = [:], body: Data? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
    }
    
    func url(baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(path)
    }
}

// MARK: - Notes Endpoints

extension Endpoint {
    static func fetchNotes() -> Endpoint {
        return Endpoint(path: "/notes", method: .GET)
    }
    
    static func fetchNote(id: String) -> Endpoint {
        return Endpoint(path: "/notes/\(id)", method: .GET)
    }
    
    static func createNote(data: Data) -> Endpoint {
        return Endpoint(
            path: "/notes",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: data
        )
    }
    
    static func updateNote(id: String, data: Data) -> Endpoint {
        return Endpoint(
            path: "/notes/\(id)",
            method: .PUT,
            headers: ["Content-Type": "application/json"],
            body: data
        )
    }
    
    static func deleteNote(id: String) -> Endpoint {
        return Endpoint(path: "/notes/\(id)", method: .DELETE)
    }
}
