// MonitoredProcess.swift
// Tink
//
// Represents an AI process being monitored

import Foundation

struct MonitoredProcess: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let displayName: String
    let pid: Int32
    let startTime: Date
    var endTime: Date?
    var exitCode: Int32?

    var duration: TimeInterval? {
        guard let end = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return end.timeIntervalSince(startTime)
    }

    var isRunning: Bool { endTime == nil }

    var durationFormatted: String {
        guard let d = duration else { return "..." }
        let m = Int(d) / 60
        let s = Int(d) % 60
        return "\(m)m\(String(format: "%02d", s))s"
    }

    var succeeded: Bool { exitCode == 0 }
}
