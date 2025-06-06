import SwiftUI
import StoreKit

struct PaywallView: View {
    // MARK: - Properties
    let onClose: () -> Void
    let onUpgrade: () -> Void
    let config: StoryGenerationConfig
    
    @ObservedObject var storeKitService: StoreKitService
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var wasNotPremium = true // Track if user was not premium when view appeared
    
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
                                config.subscriptionTier == .premium ? "paywall_premium_active".localized : "paywall_ready_for_more".localized,
                                font: .system(size: 24, weight: .bold, design: .rounded),
                                colors: [Color.orange, Color.pink]
                            )
                            .multilineTextAlignment(.center)
                            
                            if config.subscriptionTier == .premium {
                                Text("paywall_premium_thank_you".localized)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(String(format: "paywall_stories_created_today".localized, config.storiesGeneratedToday))
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
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
                    
                    if config.subscriptionTier == .premium {
                        // Premium user content
                        VStack(spacing: 16) {
                            // Premium features list
                            VStack(alignment: .leading, spacing: 12) {
                                Text("paywall_premium_features".localized)
                                    .font(.headline)
                                
                                ForEach(FeaturesLocalization.features, id: \.self) { feature in
                                    HStack(spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                        Text(feature)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            )
                            
                            // Close button
                            Button(action: onClose) {
                                Text("paywall_close".localized)
                                    .font(.headline)
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
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Free user content
                        VStack(spacing: 16) {
                            // Subscription options
                            ForEach(storeKitService.subscriptions, id: \.id) { product in
                                SubscriptionOptionButton(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id,
                                    action: { selectedProduct = product }
                                )
                            }
                            
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
                                    Link("paywall_terms_of_service".localized, destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                    Text("paywall_and".localized)
                                        .foregroundStyle(.secondary)
                                    Link("paywall_privacy_policy".localized, destination: URL(string: "https://portfolio.taiphanvan.dev/softdreams/privacy")!)
                                }
                                .font(.caption)
                            }
                            .padding(.bottom)
                        }
                        .padding(.horizontal)
                    }
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
            .onAppear {
                // Track initial premium status
                wasNotPremium = !storeKitService.hasActivePremiumSubscription
            }
            .onChange(of: storeKitService.hasActivePremiumSubscription) { oldValue, newValue in
                // If user just became premium (and wasn't before), trigger upgrade
                if wasNotPremium && newValue {
                    onUpgrade()
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
                    
                    // Check if user now has active subscription
                    if !storeKitService.hasActivePremiumSubscription {
                        // Show message that no purchases were found to restore
                        errorMessage = "paywall_no_purchases_to_restore".localized
                        showError = true
                    }
                    // Note: If user does have premium, the onChange modifier will handle calling onUpgrade
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
        ),
        storeKitService: ServiceFactory.shared.createStoreKitService()
    )
}
