//
//  ContentView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import SwiftUI

struct ContentView: View {
    @State private var recipes: [Recipe] = Recipe.dummyRecipes
    @State private var selectedDifficulty = "All"
    @State private var networkErrorMessage: String?

    @StateObject private var bookmarkManager = BookmarkManager.shared

    private let difficulties: [String] = ["All", "Beginner", "Intermediate", "Advanced"]

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    private var filteredRecipes: [Recipe] {
        guard selectedDifficulty != "All" else { return recipes }
        return recipes.filter { $0.difficulty == selectedDifficulty }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("ChefOS")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: 0x3D2314))
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Button {
                                selectedDifficulty = difficulty
                            } label: {
                                Text(difficulty)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(selectedDifficulty == difficulty ? Color.white : Color(hex: 0x4A3728))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(selectedDifficulty == difficulty ? Color(hex: 0x8B4513) : Color(hex: 0xEDE5DC))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }

                if let networkErrorMessage {
                    Text(networkErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                }

                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink {
                                RecipePage(recipe: recipe)
                            } label: {
                                RecipeCell(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(hex: 0xF5F0E8))
        }
        .tint(Color(hex: 0x8B4513))
        .onAppear {
            bookmarkManager.loadBookmarks()
        }
        .task {
            await fetchRecipesFromNetwork()
        }
    }

    private func fetchRecipesFromNetwork() async {
        networkErrorMessage = nil
        do {
            let fetched = try await NetworkManager.shared.fetchRecipes()
            recipes = fetched
        } catch {
            networkErrorMessage = "Could not refresh recipes. Showing offline samples."
        }
    }
}

#Preview {
    ContentView()
}
