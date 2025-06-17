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
  
  private var features: [String] {
    return [
      "feature_custom_story_settings".localized,
      "feature_advanced_ai_models".localized,
      //"feature_voice_narration".localized,
      //"feature_multiple_baby_profiles".localized,
      "feature_daily_story_limit".localized,
    ]
  }
  
  // MARK: - Body
  var body: some View {
    NavigationStack {
      ScrollView {
        mainContent
      }
      .background(backgroundView)
      .alert("paywall_purchase_error".localized, isPresented: $showError) {
        Button("paywall_ok".localized, role: .cancel) {}
      } message: {
        Text(errorMessage)
      }
      .task {
        await loadInitialData()
      }
      .onAppear {
        wasNotPremium = !storeKitService.hasActivePremiumSubscription
      }
      .onChange(of: storeKitService.hasActivePremiumSubscription) { oldValue, newValue in
        handlePremiumStatusChange(wasNotPremium: wasNotPremium, newValue: newValue)
      }
    }
  }
  
  // MARK: - Computed Properties
  
  private var mainContent: some View {
    VStack(spacing: 24) {
      PaywallHeaderView(config: config)
      
      usageDisplayView
      
      if config.subscriptionTier == .premium {
        premiumUserContent
      } else {
        freeUserContent
      }
    }
  }
  
  private var usageDisplayView: some View {
    StoryUsageLimitView(
      storiesGenerated: config.storiesGeneratedToday,
      dailyLimit: config.dailyStoryLimit,
      tier: config.subscriptionTier
    )
    .padding(.horizontal)
  }
  
  private var premiumUserContent: some View {
    VStack(spacing: 16) {
      FeatureList(features: features)
      
      closeButton
    }
    .padding(.horizontal)
  }
  
  private var closeButton: some View {
    Button(action: onClose) {
      Text("paywall_close".localized)
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding()
        .background(gradientBackground)
        .foregroundColor(.white)
        .cornerRadius(16)
    }
  }
  
  private var freeUserContent: some View {
    VStack(spacing: 16) {
      subscriptionOptions
      
      purchaseButton
      
      restoreButton
      
      termsAndPrivacy
    }
    .padding(.horizontal)
  }
  
  private var subscriptionOptions: some View {
    ForEach(storeKitService.subscriptions, id: \.id) { product in
      SubscriptionOptionButton(
        product: product,
        isSelected: selectedProduct?.id == product.id,
        action: { selectedProduct = product },
        features: features
      )
    }
  }
  
  private var purchaseButton: some View {
    Button(action: handlePurchase) {
      purchaseButtonContent
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(gradientBackground)
    .foregroundColor(.white)
    .cornerRadius(16)
    .disabled(selectedProduct == nil || isPurchasing)
  }
  
  private var purchaseButtonContent: some View {
    Group {
      if isPurchasing {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
      } else {
        purchaseButtonText
      }
    }
  }
  
  private var purchaseButtonText: some View {
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
  
  private var restoreButton: some View {
    Button(action: handleRestore) {
      restoreButtonContent
    }
    .disabled(isRestoring)
    .padding(.top, 8)
  }
  
  private var restoreButtonContent: some View {
    Group {
      if isRestoring {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .purple))
      } else {
        Text("paywall_restore_purchases".localized)
          .font(.subheadline)
          .foregroundStyle(.purple)
      }
    }
  }
  
  private var termsAndPrivacy: some View {
    VStack(spacing: 8) {
      Text("paywall_terms_agreement".localized)
        .font(.caption)
        .foregroundStyle(.secondary)
      
      termsLinks
    }
    .padding(.bottom)
  }
  
  private var termsLinks: some View {
    HStack(spacing: 4) {
      Link("paywall_terms_of_service".localized, destination: termsURL)
      
      Text("paywall_and".localized)
        .foregroundStyle(.secondary)
      
      Link("paywall_privacy_policy".localized, destination: privacyURL)
    }
    .font(.caption)
  }
  
  private var backgroundView: some View {
    ZStack {
      AppGradientBackground()
      FloatingStars(count: 8)
    }
  }
  
  private var gradientBackground: some View {
    LinearGradient(
      colors: [Color.purple, Color.pink],
      startPoint: .leading,
      endPoint: .trailing
    )
  }
  
  private var termsURL: URL {
    URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
  }
  
  private var privacyURL: URL {
    URL(string: "https://portfolio.taiphanvan.dev/softdreams/privacy")!
  }
  
  // MARK: - Private Methods
  
  private func loadInitialData() async {
    await storeKitService.loadProducts()
    if let firstProduct = storeKitService.subscriptions.first {
      selectedProduct = firstProduct
    }
  }
  
  private func handlePremiumStatusChange(wasNotPremium: Bool, newValue: Bool) {
    if wasNotPremium && newValue {
      onUpgrade()
    }
  }
  
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

struct FeatureList: View {
  let features: [String]
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("paywall_premium_features".localized)
        .font(.headline)
      
      ForEach(features, id: \.self) { feature in
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
  }
}

struct PaywallHeaderView: View {
  let config: StoryGenerationConfig
  var body: some View {
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
  }
}
