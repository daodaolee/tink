// IdleDetector.swift
// Tink
//
// Detects user idle time for smart DND (macOS only)

#if os(macOS)
import Foundation
import CoreGraphics

final class IdleDetector {
    var secondsSinceLastInput: TimeInterval {
        CGEventSource.secondsSinceLastEventType(
            .hidSystemState,
            eventType: CGEventType(rawValue: ~0)!
        )
    }

    func isUserAway(thresholdSeconds: Int = 120) -> Bool {
        secondsSinceLastInput > Double(thresholdSeconds)
    }
}
#endif
