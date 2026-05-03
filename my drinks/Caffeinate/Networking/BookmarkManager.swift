//
//  BookmarkManager.swift
//  my drinks
//
//  Created by Christina Wu on 5/1/26.
//

import Combine
import Foundation

final class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()

    @Published var bookmarkRecipeIds: Set<UUID> = []

    private let userDefaultsKey = "ChefOS.bookmarkedRecipeUUIDs"

    private init() {
        loadBookmarks()
    }

    func saveBookmarks() {
        let strings = bookmarkRecipeIds.map(\.uuidString)
        UserDefaults.standard.set(strings, forKey: userDefaultsKey)
    }

    func loadBookmarks() {
        guard let strings = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] else {
            bookmarkRecipeIds = []
            return
        }
        bookmarkRecipeIds = Set(strings.compactMap(UUID.init(uuidString:)))
    }

    func toggleBookmark(for recipeId: UUID?) {
        guard let recipeId else { return }
        if bookmarkRecipeIds.contains(recipeId) {
            bookmarkRecipeIds.remove(recipeId)
        } else {
            bookmarkRecipeIds.insert(recipeId)
        }
        saveBookmarks()
    }

    func isBookmarked(_ recipeId: UUID?) -> Bool {
        guard let recipeId else { return false }
        return bookmarkRecipeIds.contains(recipeId)
    }
}
