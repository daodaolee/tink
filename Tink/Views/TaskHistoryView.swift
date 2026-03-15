// TaskHistoryView.swift
// Tink
//
// iOS task history list

#if os(iOS)
import SwiftUI
import SwiftData

struct TaskHistoryView: View {
    var store: StoreManager
    @Query(sort: \TaskRecord.endTime, order: .reverse) private var records: [TaskRecord]
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "No tasks yet",
                        systemImage: "bell.slash",
                        description: Text("When your AI tasks finish on Mac, they'll appear here.")
                    )
                } else {
                    List(records) { record in
                        HStack {
                            Image(systemName: record.exitCode == 0
                                  ? "checkmark.circle.fill"
                                  : "xmark.circle.fill")
                                .foregroundStyle(record.exitCode == 0 ? .green : .red)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(record.displayName)
                                    .font(.body)
                                Text(record.endTime, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(formatDuration(record.duration))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Tink")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !store.isPro {
                        Button("Pro") { showPaywall = true }
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(store: store)
            }
        }
    }

    private func formatDuration(_ d: Double) -> String {
        let m = Int(d) / 60
        let s = Int(d) % 60
        return "\(m)m\(String(format: "%02d", s))s"
    }
}
#endif
