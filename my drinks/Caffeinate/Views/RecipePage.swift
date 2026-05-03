//
//  RecipePage.swift
//  my drinks
//
//  Created by Christina Wu on 5/1/26.
//

import SwiftUI

struct RecipePage: View {
    let recipe: Recipe
    @StateObject private var bookmarkManager = BookmarkManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: recipe.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: 0xECECEC))
                            .frame(height: 220)
                            .overlay { ProgressView() }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    case .failure:
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: 0xECECEC))
                            .frame(height: 220)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }

                Text(recipe.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color(hex: 0x2C2C2C))

                Text(recipe.description)
                    .font(.body)
                    .foregroundStyle(Color(hex: 0x4A4A4A))
                    .fixedSize(horizontal: false, vertical: true)

                Label(recipe.difficulty, systemImage: "fork.knife")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(hex: 0x8B4513))
            }
            .padding()
        }
        .background(Color(hex: 0xFAFAFA))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    bookmarkManager.toggleBookmark(for: recipe.id)
                } label: {
                    Image(systemName: bookmarkManager.isBookmarked(recipe.id) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(Color(hex: 0x8B4513))
                }
            }
        }
        .onAppear {
            bookmarkManager.loadBookmarks()
        }
    }
}

#Preview {
    NavigationStack {
        RecipePage(recipe: Recipe.dummyRecipes[0])
    }
}
