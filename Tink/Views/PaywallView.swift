// PaywallView.swift
// Tink
//
// iOS subscription paywall

#if os(iOS)
import SwiftUI
import StoreKit

struct PaywallView: View {
    var store: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)

                Text("Tink Pro")
                    .font(.title.bold())

                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(icon: "infinity", text: "Unlimited processes")
                    FeatureRow(icon: "bell.fill", text: "Unlimited notifications")
                    FeatureRow(icon: "slider.horizontal.3", text: "Custom monitoring rules")
                    FeatureRow(icon: "chart.bar.fill", text: "Full history & statistics")
                    FeatureRow(icon: "applewatch", text: "Watch face complication")
                }

                Spacer()

                ForEach(store.products) { product in
                    Button {
                        Task { try? await store.purchase(product) }
                    } label: {
                        VStack {
                            Text(product.displayName)
                                .font(.headline)
                            Text(product.displayPrice)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.tint)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Button("Restore Purchases") {
                    Task { await store.restorePurchases() }
                }
                .font(.caption)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.tint)
            Text(text)
        }
    }
}
#endif
