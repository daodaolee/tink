// TaskRecord.swift
// Tink
//
// SwiftData model for task history, syncs via CloudKit

import Foundation
import SwiftData

@Model
final class TaskRecord {
    var processName: String = ""
    var displayName: String = ""
    var startTime: Date = Date()
    var endTime: Date = Date()
    var exitCode: Int32 = 0
    var duration: Double = 0
    var notified: Bool = false
    var deviceName: String = ""

    init(from process: MonitoredProcess) {
        self.processName = process.name
        self.displayName = process.displayName
        self.startTime = process.startTime
        self.endTime = process.endTime ?? Date()
        self.exitCode = process.exitCode ?? -1
        self.duration = process.duration ?? 0
        self.notified = false
        #if os(macOS)
        self.deviceName = Host.current().localizedName ?? "Mac"
        #else
        self.deviceName = ""
        #endif
    }

    init() {}
}
