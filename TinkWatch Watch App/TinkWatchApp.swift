// TinkWatchApp.swift
// TinkWatch Watch App

import SwiftUI
import UserNotifications
import WatchKit
import CloudKit

@main
struct TinkWatch_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(WatchAppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            WatchMainView()
        }
    }
}

class WatchAppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        Task {
            try? await CloudKitSubscriptionManager.shared.subscribeToChanges()
        }
    }

    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any]) async -> WKBackgroundFetchResult {
        await CloudKitSubscriptionManager.shared.handleRemoteNotification()

        // Play haptic
        let succeeded = userInfo["succeeded"] as? Bool ?? true
        if succeeded {
            WKInterfaceDevice.current().play(.success)
        } else {
            WKInterfaceDevice.current().play(.failure)
        }

        return .newData
    }
}
