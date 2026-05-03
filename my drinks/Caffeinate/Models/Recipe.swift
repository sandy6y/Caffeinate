//
//  Recipe.swift
//  my drinks
//
//  Created by Christina Wu on 5/1/26.
//

import Foundation

struct Recipe: Identifiable, Decodable, Hashable {
    var id: UUID?
    let description: String
    let difficulty: String
    let imageUrl: String
    let name: String
    let rating: Float

    enum CodingKeys: String, CodingKey {
        case id, description, difficulty, imageUrl = "image_url", name, rating
    }

    /// Default initializer for dummy / preview data (camelCase in code).
    init(
        id: UUID? = UUID(),
        description: String,
        difficulty: String,
        imageUrl: String,
        name: String,
        rating: Float
    ) {
        self.id = id
        self.description = description
        self.difficulty = difficulty
        self.imageUrl = imageUrl
        self.name = name
        self.rating = rating
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idString = try container.decodeIfPresent(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString)
        } else {
            self.id = nil
        }
        self.description = try container.decode(String.self, forKey: .description)
        self.difficulty = try container.decode(String.self, forKey: .difficulty)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.name = try container.decode(String.self, forKey: .name)
        self.rating = try container.decode(Float.self, forKey: .rating)
    }

    /// Stable identity for `ForEach` / navigation when `id` is missing from bad JSON.
    var stableId: UUID {
        id ?? UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    }
}

extension Recipe {
    /// Small dummy set before the network response arrives (Pastebin-style shape).
    static let dummyRecipes: [Recipe] = [
        Recipe(
            description: "Warm, flaky, and perfect with coffee.",
            difficulty: "Beginner",
            imageUrl: "https://www.allrecipes.com/thmb/neJT4JLJz7ks8D0Rkvzf8fRufWY=/750x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/6900-dumplings-DDMFS-4x3-c03fe714205d4f24bd74b99768142864.jpg",
            name: "Homemade Dumplings",
            rating: 4.7
        ),
        Recipe(
            description: "Crispy crust, classic Italian-American comfort food.",
            difficulty: "Intermediate",
            imageUrl: "https://www.allrecipes.com/thmb/0NW5WeQpXaotyZHJnK1e1mFWcCk=/750x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/223042-Chicken-Parmesan-mfs_001-7ab952346edc4b2da36f3c0259b78543.jpg",
            name: "Chicken Parmesan",
            rating: 4.8
        ),
    ]
}
