// TinkApp.swift
// Tink

import SwiftUI
import SwiftData
import UserNotifications
import Observation

@main
struct TinkApp: App {
    #if os(macOS)
    @State private var monitor = ProcessMonitor()
    @State private var appState = MacAppState()
    #endif

    @State private var store = StoreManager()

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra {
            MenuBarView(monitor: monitor, appState: appState, store: store)
        } label: {
            Image(systemName: monitor.runningProcesses.isEmpty ? "bell" : "bell.badge")
        }
        .menuBarExtraStyle(.window)
        #else
        WindowGroup {
            TaskHistoryView(store: store)
        }
        .modelContainer(for: TaskRecord.self)
        #endif
    }
}

#if os(macOS)
@Observable
@MainActor
final class MacAppState {
    let idleDetector = IdleDetector()
    private var isSetUp = false

    func setup(monitor: ProcessMonitor) {
        guard !isSetUp else { return }
        isSetUp = true

        Task {
            try? await CloudKitManager.shared.createZoneIfNeeded()
        }

        monitor.onTaskCompleted = { [weak self] process in
            Task { @MainActor [weak self] in
                await self?.handleTaskCompleted(process)
            }
        }

        monitor.start()
    }

    private func handleTaskCompleted(_ process: MonitoredProcess) async {
        let minDuration = UserDefaults.standard.integer(forKey: "minimumDuration")
        let threshold = minDuration > 0 ? minDuration : 30
        if let duration = process.duration, duration < Double(threshold) {
            return
        }

        let dndEnabled = UserDefaults.standard.bool(forKey: "dndWhenActive")
        if dndEnabled && !idleDetector.isUserAway() {
            return
        }

        do {
            try await CloudKitManager.shared.pushTaskCompletion(process: process)
        } catch {
            print("Tink: CloudKit push failed: \(error)")
        }
    }
}
#endif
