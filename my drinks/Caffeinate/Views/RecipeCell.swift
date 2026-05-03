//
//  RecipeCell.swift
//  my drinks
//
//  Created by Christina Wu on 5/1/26.
//

import SwiftUI

struct RecipeCell: View {
    let recipe: Recipe
    @StateObject private var bookmarkManager = BookmarkManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: recipe.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color(hex: 0xE8E8E8)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if bookmarkManager.isBookmarked(recipe.id) {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(Color(hex: 0x8B4513))
                        .padding(8)
                        .shadow(color: .white.opacity(0.8), radius: 1)
                }
            }

            Text(recipe.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(hex: 0x2C2C2C))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: 0xD4A574))
                Text(String(format: "%.1f", recipe.rating))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color(hex: 0x6B6B6B))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 216, alignment: .topLeading)
        .padding(10)
        .background(Color(hex: 0xFAFAFA))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .onAppear {
            bookmarkManager.loadBookmarks()
        }
    }
}

#Preview {
    RecipeCell(recipe: Recipe.dummyRecipes[0])
        .padding()
}
