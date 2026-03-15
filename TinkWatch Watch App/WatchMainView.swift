// WatchMainView.swift
// TinkWatch Watch App

import SwiftUI

struct WatchMainView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "bell")
                .font(.largeTitle)
                .foregroundStyle(.tint)
            Text("Tink")
                .font(.headline)
            Text("Listening for AI tasks")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
