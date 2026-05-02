//
//  NetworkManager.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import Foundation
// MARK: - Network Errors
 
enum NetworkError: LocalizedError {
    case invalidURL
    case encodingFailed
    case noData
    case decodingFailed(Error)
    case serverError(Int)
    case unknown(Error)
 
    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "Invalid URL."
        case .encodingFailed:     return "Failed to encode request body."
        case .noData:             return "No data received from server."
        case .decodingFailed(let e): return "Decoding failed: \(e.localizedDescription)"
        case .serverError(let code): return "Server returned status \(code)."
        case .unknown(let e):    return e.localizedDescription
        }
    }
}
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // this is a temporary fake url
    private let baseURL = "https://api.mydrinks.example.com/v1"
    
    
    // MARK: GET /logs
    func fetchLogs() async throws -> [Log] {
        guard let url = URL(string: "\(baseURL)/logs") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response)
        
        do {
            let decoder = JSONDecoder()
            let logs = try decoder.decode([Log].self, from: data)
            return logs
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    // MARK: POST /logs
    // creates a new drink log on the server and returns the saved copy
    func createLog(_ log: Log) async throws -> Log {
        guard let url = URL(string: "\(baseURL)/logs") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        guard let body = try? encoder.encode(log) else { throw NetworkError.encodingFailed}
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response)
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Log.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    // MARK: Delete /logs/{id}
    // Deletes a drink log by its UUID
    func deleteLog(id: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/logs") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        try validate(response: response)
    }
    
    // MARK: Private Helpers
    private func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {return}
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.serverError(http.statusCode)
        }
    }
}
