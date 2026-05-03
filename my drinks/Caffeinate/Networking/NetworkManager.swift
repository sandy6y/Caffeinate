//
//  NetworkManager.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import Foundation

// MARK: - Drinks app errors

enum NetworkError: LocalizedError {
    case invalidURL
    case encodingFailed
    case noData
    case decodingFailed(Error)
    case serverError(Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .encodingFailed: return "Failed to encode request body."
        case .noData: return "No data received from server."
        case .decodingFailed(let e): return "Decoding failed: \(e.localizedDescription)"
        case .serverError(let code): return "Server returned status \(code)."
        case .unknown(let e): return e.localizedDescription
        }
    }
}

// MARK: - Shared manager (ChefOS jsonbin + optional drinks API)

final class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    // MARK: ChefOS (assignment jsonbin)

    /// Set to `true` to skip HTTP and return local mock recipes (`fetchRecipes` only).
    static var useMockAPI = false

    private let recipesURL = URL(string: "https://api.jsonbin.io/v3/b/64d033f18e4aa6225ecbcf9f?meta=false")!

    func fetchRecipes() async throws -> [Recipe] {
        if Self.useMockAPI {
            try await Task.sleep(for: .milliseconds(400))
            return Self.mockRecipesPretendingToBeServer
        }

        let (data, response) = try await URLSession.shared.data(from: recipesURL)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        return try decoder.decode([Recipe].self, from: data)
    }

    private static let mockRecipesPretendingToBeServer: [Recipe] = Recipe.dummyRecipes + [
        Recipe(
            description: "Like takeout — good for demos when the server is not ready yet.",
            difficulty: "Intermediate",
            imageUrl: "https://www.allrecipes.com/thmb/UV3EA5o1UjF0IGo2JciyAMrCXcg=/750x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/290890_original-f425d458ea2b4cec8d4a855ce6929707.jpg",
            name: "Kung Pao Chicken (mock)",
            rating: 4.3
        ),
    ]

    // MARK: Drinks app (placeholder backend)

    private let drinksBaseURL = "https://api.mydrinks.example.com/v1"

    func fetchLogs() async throws -> [Log] {
        guard let url = URL(string: "\(drinksBaseURL)/logs") else { throw NetworkError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        try validateDrinks(response: response)

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Log].self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    func createLog(_ log: Log) async throws -> Log {
        guard let url = URL(string: "\(drinksBaseURL)/logs") else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        guard let body = try? encoder.encode(log) else { throw NetworkError.encodingFailed }
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateDrinks(response: response)

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Log.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    func deleteLog(id: UUID) async throws {
        guard let url = URL(string: "\(drinksBaseURL)/logs") else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)
        try validateDrinks(response: response)
    }

    private func validateDrinks(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.serverError(http.statusCode)
        }
    }
}
