// CloudKitSubscriptionManager.swift
// Tink
//
// Subscribes to CloudKit changes and posts local notifications (iOS/watchOS)

import Foundation
import CloudKit
import UserNotifications

final class CloudKitSubscriptionManager {
    static let shared = CloudKitSubscriptionManager()
    private let subscriptionSavedKey = "tink_ck_subscription_saved"
    private let zoneTokenKey = "tink_ck_zone_token"

    private init() {}

    func subscribeToChanges() async throws {
        guard !UserDefaults.standard.bool(forKey: subscriptionSavedKey) else { return }

        let subscription = CKDatabaseSubscription(subscriptionID: "tink-private-changes")
        let notifInfo = CKSubscription.NotificationInfo()
        notifInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notifInfo

        _ = try await CloudKitManager.shared.privateDB.save(subscription)
        UserDefaults.standard.set(true, forKey: subscriptionSavedKey)
    }

    func handleRemoteNotification() async {
        do {
            let records = try await fetchChanges()
            for record in records {
                await postLocalNotification(from: record)
            }
        } catch {
            print("Tink: failed to fetch changes: \(error)")
        }
    }

    private func fetchChanges() async throws -> [CKRecord] {
        let zoneID = CloudKitManager.shared.zoneID
        let token = loadChangeToken()
        var records: [CKRecord] = []

        let changes = try await CloudKitManager.shared.privateDB
            .recordZoneChanges(inZoneWith: zoneID, since: token)

        for (_, result) in changes.modificationResultsByID {
            if case .success(let modification) = result {
                records.append(modification.record)
            }
        }

        saveChangeToken(changes.changeToken)

        return records
    }

    private func postLocalNotification(from record: CKRecord) async {
        guard record.recordType == "TaskCompletion" else { return }

        let displayName = record["displayName"] as? String ?? "AI Task"
        let succeeded = record["succeeded"] as? Bool ?? true
        let durationFormatted = record["durationFormatted"] as? String ?? ""

        let content = UNMutableNotificationContent()
        content.title = "Tink"
        if succeeded {
            content.body = "\(displayName) completed \u{00B7} \(durationFormatted)"
        } else {
            let exitCode = record["exitCode"] as? Int ?? -1
            content.body = "\(displayName) failed \u{00B7} exit \(exitCode) \u{00B7} \(durationFormatted)"
        }
        content.sound = .default
        content.categoryIdentifier = succeeded ? "TASK_SUCCESS" : "TASK_FAILURE"

        let request = UNNotificationRequest(
            identifier: record.recordID.recordName,
            content: content,
            trigger: nil
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    private func loadChangeToken() -> CKServerChangeToken? {
        guard let data = UserDefaults.standard.data(forKey: zoneTokenKey) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
    }

    private func saveChangeToken(_ token: CKServerChangeToken) {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
        UserDefaults.standard.set(data, forKey: zoneTokenKey)
    }
}
