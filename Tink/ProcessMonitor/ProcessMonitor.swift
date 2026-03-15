// ProcessMonitor.swift
// Tink
//
// Polls for AI processes, tracks state, fires completion events (macOS only)

#if os(macOS)
import Foundation
import Observation

@Observable
@MainActor
final class ProcessMonitor {
    var runningProcesses: [MonitoredProcess] = []
    var recentlyCompleted: [MonitoredProcess] = []

    private let scanner = ProcessScanner()
    private var timer: DispatchSourceTimer?
    private var activity: NSObjectProtocol?
    private var trackedPIDs: [pid_t: MonitoredProcess] = [:]

    private var customTargets: [String] = []

    var targetNames: [String] {
        ProcessScanner.defaultTargets.map(\.name) + customTargets
    }

    var onTaskCompleted: (@Sendable (MonitoredProcess) -> Void)?

    func start() {
        activity = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep],
            reason: "Monitoring AI processes"
        )

        let timer = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        timer.schedule(deadline: .now(), repeating: 2.0, leeway: .milliseconds(100))
        timer.setEventHandler { [weak self] in
            Task { @MainActor [weak self] in
                self?.poll()
            }
        }
        timer.resume()
        self.timer = timer
    }

    func stop() {
        timer?.cancel()
        timer = nil
        if let activity { ProcessInfo.processInfo.endActivity(activity) }
    }

    func setCustomTargets(_ targets: [String]) {
        customTargets = targets
    }

    private func poll() {
        let found = scanner.scanForTargets(targetNames)
        let foundPIDs = Set(found.map(\.pid))

        for proc in found where trackedPIDs[proc.pid] == nil {
            let displayName = ProcessScanner.defaultTargets
                .first(where: { proc.name == $0.name })?.displayName ?? proc.name
            let monitored = MonitoredProcess(
                id: UUID(),
                name: proc.name,
                displayName: displayName,
                pid: proc.pid,
                startTime: Date()
            )
            trackedPIDs[proc.pid] = monitored
        }

        for (pid, var process) in trackedPIDs where !foundPIDs.contains(pid) {
            process.endTime = Date()
            process.exitCode = 0
            trackedPIDs.removeValue(forKey: pid)
            recentlyCompleted.insert(process, at: 0)
            if recentlyCompleted.count > 50 {
                recentlyCompleted.removeLast()
            }
            onTaskCompleted?(process)
        }

        runningProcesses = Array(trackedPIDs.values).sorted(by: { $0.startTime < $1.startTime })
    }
}
#endif
