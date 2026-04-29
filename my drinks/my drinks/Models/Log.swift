//
//  Log.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import Foundation

struct Log: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let time: Date
    let type: DrinkType
    let size: DrinkSize
    let temperature: DrinkTemperature
    let caffeine: Int
    let sugar: Int
    let price: Double?
    let rating: Int?
    let note: String?
}

enum DrinkTemperature: String, Codable, CaseIterable {
    case hot, iced
}

enum DrinkType: String, Codable, CaseIterable {
    case espresso, americano, latte, mocha, flatWhite, cappuccino, matcha, tea, boba, energydrink, other
    
    var emoji: String {
        switch self {
        case .espresso: return "☕️"
        case .americano: return "🥃"
        case .latte: return "🥛"
        case .cappuccino: return "☁️"
        case .flatWhite: return "⬜️"
        case .mocha: return "🍫"
        case .matcha: return "🍵"
        case .tea: return "🫖"
        case .boba: return "🧋"
        case .energydrink: return "⚡️"
        case .other: return "➕"
        }
    }
}

enum DrinkSize: String, Codable, CaseIterable {
    case small, medium, large, XL
}
