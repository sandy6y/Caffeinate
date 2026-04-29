//
//  LogCell.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import SwiftUI

struct LogCell: View {
    let log: Log
    
    var body: some View {
        HStack(spacing: 16) {
            // emoji
            Text(log.type.emoji)
                .font(.largeTitle)
                .frame(width: 56, height: 56)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            // name, size, time, rating
            VStack(alignment: .leading, spacing: 4) {
                Text(log.name.isEmpty ? log.type.rawValue.capitalized : log.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(log.size.rawValue.capitalized) · \(log.time.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let rating = log.rating, rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(1...rating, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            
            Spacer()
            
            // caffeine
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(log.caffeine)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.brown)
                Text("mg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    LogCell(log: .dummy)
}
