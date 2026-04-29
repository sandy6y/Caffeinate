//
//  ContentView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var logs: [Log] = [
        Log(name: "Pistachio Cloud Jasmine", time: Date(), type: .boba, size: .medium, temperature: .iced, caffeine: 156, sugar: 20, price: 7.50, rating: 5, note: nil),
        Log(name: "Vanilla Latte", time: Date(), type: .latte, size: .medium, temperature: .iced, caffeine: 75, sugar: 10, price: 6.00, rating: 3, note: nil),
        Log(name: "", time: Date(), type: .espresso, size: .small, temperature: .hot, caffeine: 64, sugar: 0, price: nil, rating: nil, note: nil),
        Log(name: "Matcha", time: Date(), type: .other, size: .large, temperature: .iced, caffeine: 0, sugar: 5, price: 5.50, rating: 2, note: "Too sweet"),
        Log(name: "Cappuccino", time: Date(), type: .cappuccino, size: .medium, temperature: .hot, caffeine: 75, sugar: 0, price: 4.50, rating: 4, note: nil)
    ]
    
    @State private var showingNewLog = false
    
    var todayCaffeine: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return logs
            .filter {Calendar.current.startOfDay(for: $0.time) == today}
            .reduce(0) {$0 + $1.caffeine}
    }

    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            Text("Today's Caffeine")
                .font(.system(size: 40))
                .fontWeight(.semibold)
                .foregroundColor(.brown)
            
            Text("\(todayCaffeine) mg")
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .padding()
            
            // add new drink
            Button("+ Add a cup") {
                showingNewLog = true
            }
            .padding(.horizontal, 120)
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(.brown)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            ScrollView {
                LazyVStack {
                    ForEach(logs) {log in
                        LogCell(log: log)
                    }
                }
                .padding()
            }
        }
        .padding()
        .sheet(isPresented: $showingNewLog) {
            NewLogView(logs: $logs)
        }

    }
}

#Preview {
    ContentView()
}
