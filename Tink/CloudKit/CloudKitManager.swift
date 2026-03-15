// CloudKitManager.swift
// Tink
//
// Manages CloudKit operations for cross-device sync

import Foundation
import CloudKit

final class CloudKitManager {
    static let shared = CloudKitManager()

    let container = CKContainer(identifier: "iCloud.com.daodaolee.tink")
    var privateDB: CKDatabase { container.privateCloudDatabase }
    let zoneID = CKRecordZone.ID(zoneName: "TinkZone", ownerName: CKCurrentUserDefaultName)

    private init() {}

    func createZoneIfNeeded() async throws {
        let zone = CKRecordZone(zoneID: zoneID)
        _ = try await privateDB.save(zone)
    }

    func pushTaskCompletion(process: MonitoredProcess) async throws {
        let record = CKRecord(recordType: "TaskCompletion", recordID: CKRecord.ID(zoneID: zoneID))
        record["processName"] = process.name as CKRecordValue
        record["displayName"] = process.displayName as CKRecordValue
        record["startTime"] = process.startTime as CKRecordValue
        record["endTime"] = (process.endTime ?? Date()) as CKRecordValue
        record["exitCode"] = (process.exitCode ?? -1) as CKRecordValue
        record["duration"] = (process.duration ?? 0) as CKRecordValue
        record["succeeded"] = process.succeeded as CKRecordValue
        record["durationFormatted"] = process.durationFormatted as CKRecordValue
        _ = try await privateDB.save(record)
    }
}
