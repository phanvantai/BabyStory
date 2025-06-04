import SwiftUI

struct SettingsPremiumSectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var showPremiumFeatures: Bool
    @Binding var isRestoringPurchases: Bool
    
    var body: some View {
        AnimatedEntrance(delay: 0.7) {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                    Text("settings_premium_section".localized)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                VStack(spacing: 16) {
                    // Premium Features Button
//                    Button(action: { showPremiumFeatures = true }) {
//                        HStack {
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("settings_premium_features".localized)
//                                    .font(.body)
//                                    .fontWeight(.medium)
//                                Text("settings_premium_features_description".localized)
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        .padding(.vertical, 12)
//                        .contentShape(Rectangle())
//                    }
//                    
//                    Divider()
//                        .background(Color(UIColor.separator))
                    
                    // Restore Purchases Button
                    Button(action: handleRestorePurchases) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("settings_restore_purchases".localized)
                                    .font(.body)
                                    .fontWeight(.medium)
                                Text("settings_restore_purchases_description".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if isRestoringPurchases {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .disabled(isRestoringPurchases)
                }
            }
            .padding(20)
            .appCardStyle()
            .padding(.horizontal, 24)
        }
    }
    
    private func handleRestorePurchases() {
        isRestoringPurchases = true
        
        Task {
            do {
                try await ServiceFactory.shared.createStoreKitService().restorePurchases()
                await MainActor.run {
                    isRestoringPurchases = false
                }
            } catch {
                await MainActor.run {
                    isRestoringPurchases = false
                }
            }
        }
    }
}

#Preview {
    SettingsPremiumSectionView(
        showPremiumFeatures: .constant(false),
        isRestoringPurchases: .constant(false)
    )
} 
