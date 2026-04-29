//
//  ContentView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import SwiftUI

struct ContentView: View {
    @State private var logs: [Log] = []
    @State private var showingNewLog = false
    
    var body: some View {
        Button("Add") {
            showingNewLog = true
        }
        .sheet(isPresented: $showingNewLog) {
            NewLogView(logs: $logs)
        }
    }
}

#Preview {
    ContentView()
}
