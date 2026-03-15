// MenuBarView.swift
// Tink
//
// macOS menu bar popover UI

#if os(macOS)
import SwiftUI

struct MenuBarView: View {
    var monitor: ProcessMonitor
    var appState: MacAppState
    var store: StoreManager
    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tink")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(monitor.runningProcesses.isEmpty ? .gray : .green)
                    .frame(width: 8, height: 8)
            }

            Divider()

            if monitor.runningProcesses.isEmpty {
                Text("No AI tasks running")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            } else {
                ForEach(monitor.runningProcesses) { process in
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 6))
                        Text(process.displayName)
                            .font(.caption)
                        Spacer()
                        Text(process.durationFormatted)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !monitor.recentlyCompleted.isEmpty {
                Divider()
                Text("Recent")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                ForEach(monitor.recentlyCompleted.prefix(5)) { process in
                    HStack {
                        Image(systemName: process.succeeded ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(process.succeeded ? .green : .red)
                            .font(.system(size: 10))
                        Text(process.displayName)
                            .font(.caption)
                        Spacer()
                        Text(process.durationFormatted)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            HStack {
                Button("Settings...") {
                    showSettings.toggle()
                }
                .font(.caption)
                .popover(isPresented: $showSettings) {
                    SettingsView()
                }

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.caption)
            }
        }
        .padding()
        .frame(width: 260)
        .onAppear {
            appState.setup(monitor: monitor)
        }
    }
}
#endif
