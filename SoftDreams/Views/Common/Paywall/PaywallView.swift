import SwiftUI
import StoreKit

struct PaywallView: View {
    // MARK: - Properties
    let onClose: () -> Void
    let onUpgrade: () -> Void
    let config: StoryGenerationConfig
    
    @StateObject private var storeKitService = ServiceFactory.shared.createStoreKitService()
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        // Title and description
                        VStack(spacing: 8) {
                            GradientText(
                                "paywall_ready_for_more".localized,
                                font: .system(size: 24, weight: .bold, design: .rounded),
                                colors: [Color.orange, Color.pink]
                            )
                            .multilineTextAlignment(.center)
                            
                          Text(String(format: "paywall_stories_created_today".localized, config.storiesGeneratedToday))
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    
                    // Usage display
                    StoryUsageLimitView(
                        storiesGenerated: config.storiesGeneratedToday,
                        dailyLimit: config.dailyStoryLimit,
                        tier: config.subscriptionTier
                    )
                    .padding(.horizontal)
                    
                    // Subscription options
                    VStack(spacing: 16) {
                        ForEach(storeKitService.subscriptions, id: \.id) { product in
                            SubscriptionOptionButton(
                                product: product,
                                isSelected: selectedProduct?.id == product.id,
                                action: { selectedProduct = product }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Purchase button
                    Button(action: handlePurchase) {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            VStack(spacing: 4) {
                                Text(selectedProduct == nil ? "paywall_select_plan".localized : "paywall_start_trial".localized)
                                    .font(.headline)
                                if selectedProduct != nil {
                                    Text("paywall_cancel_anytime".localized)
                                        .font(.caption)
                                        .opacity(0.8)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .disabled(selectedProduct == nil || isPurchasing)
                    
                    // Restore purchases button
                    Button(action: handleRestore) {
                        if isRestoring {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        } else {
                            Text("paywall_restore_purchases".localized)
                                .font(.subheadline)
                                .foregroundStyle(.purple)
                        }
                    }
                    .disabled(isRestoring)
                    .padding(.top, 8)
                    
                    // Terms and privacy
                    VStack(spacing: 8) {
                        Text("paywall_terms_agreement".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 4) {
                            Link("paywall_terms_of_service".localized, destination: URL(string: "https://softdreams.app/terms")!)
                            Text("paywall_and".localized)
                                .foregroundStyle(.secondary)
                            Link("paywall_privacy_policy".localized, destination: URL(string: "https://softdreams.app/privacy")!)
                        }
                        .font(.caption)
                    }
                    .padding(.bottom)
                }
            }
            .background(
                ZStack {
                    // Background
                    AppGradientBackground()
                    
                    // Floating decorative elements
                    FloatingStars(count: 8)
                }
            )
            .alert("paywall_purchase_error".localized, isPresented: $showError) {
                Button("paywall_ok".localized, role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .task {
                // Load products and select first product
                await storeKitService.loadProducts()
                if let firstProduct = storeKitService.subscriptions.first {
                    selectedProduct = firstProduct
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handlePurchase() {
        guard let product = selectedProduct else { return }
        
        isPurchasing = true
        
        Task {
            do {
                let success = try await storeKitService.purchase(product)
                
                await MainActor.run {
                    isPurchasing = false
                    
                    if success {
                        onUpgrade()
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func handleRestore() {
        isRestoring = true
        
        Task {
            do {
                try await storeKitService.restorePurchases()
                
                await MainActor.run {
                    isRestoring = false
                    onUpgrade()
                }
            } catch {
                await MainActor.run {
                    isRestoring = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    PaywallView(
        onClose: {},
        onUpgrade: {},
        config: StoryGenerationConfig(
            subscriptionTier: .free,
            selectedModel: .gpt35Turbo,
            storiesGeneratedToday: 3,
            lastResetDate: Date()
        )
    )
}
