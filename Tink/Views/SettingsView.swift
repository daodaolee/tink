// SettingsView.swift
// Tink
//
// macOS settings popover

#if os(macOS)
import SwiftUI

struct SettingsView: View {
    @AppStorage("minimumDuration") private var minimumDuration = 30
    @AppStorage("dndWhenActive") private var dndWhenActive = true
    @AppStorage("dndIdleThreshold") private var dndIdleThreshold = 120
    @AppStorage("customProcesses") private var customProcesses = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Notifications")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Stepper("Min duration: \(minimumDuration)s", value: $minimumDuration, in: 5...300, step: 5)
                    .font(.caption)

                Toggle("Smart DND (skip when at Mac)", isOn: $dndWhenActive)
                    .font(.caption)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Monitored Processes")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Built-in: claude, codex, gemini, aider, copilot, cursor-agent")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                TextField("Custom (comma-separated)", text: $customProcesses)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
#endif
