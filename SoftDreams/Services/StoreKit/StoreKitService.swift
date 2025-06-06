import Foundation
import StoreKit

@MainActor
class StoreKitService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: Product.SubscriptionInfo.RenewalState?
    
    // MARK: - Private Properties
    private let productIds = [
        "com.randomtech.softDreams.monthly",
        "com.randomtech.softDreams.yearly"
    ]
    
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Load available products from the App Store
    func loadProducts() async {
        do {
            subscriptions = try await Product.products(for: productIds)
            Logger.info("Loaded \(subscriptions.count) subscription products", category: .general)
        } catch {
            Logger.error("Failed to load products: \(error.localizedDescription)", category: .general)
            #if DEBUG
            // In debug builds, fall back to mock data if loading fails
            setupPreviewData()
            #endif
        }
    }
    
    /// Purchase a subscription
    /// - Parameter product: The product to purchase
    /// - Returns: True if purchase was successful
    func purchase(_ product: Product) async throws -> Bool {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // In previews, simulate a successful purchase
            await simulatePurchase(product)
            return true
        }
        #endif
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check if the transaction is verified
            let transaction = try checkVerified(verification)
            
            // Update the user's subscription status
            await updateSubscriptionStatus()
            
            // Finish the transaction
            await transaction.finish()
            
            // Notify observers of the change
            await MainActor.run {
                objectWillChange.send()
            }
            
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    /// Restore purchases and update subscription status
    func restorePurchases() async throws {
        // Only sync if we don't have any active subscriptions
        if purchasedSubscriptions.isEmpty {
            // This will trigger a refresh of the subscription status
            try await AppStore.sync()
            
            // Update subscription status
            await updateSubscriptionStatus()
            
            // Notify observers of the change
            await MainActor.run {
                objectWillChange.send()
            }
        }
    }
    
    /// Check if user has an active premium subscription
    var hasActivePremiumSubscription: Bool {
        return !purchasedSubscriptions.isEmpty
    }
    
    /// Get the current subscription status
    func getSubscriptionStatus() async -> SubscriptionStatus {
        // First check if we already have active subscriptions in memory
        if !purchasedSubscriptions.isEmpty {
            return .active(purchasedSubscriptions[0])
        }
        
        // If not, check current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if the subscription is still active
                if transaction.revocationDate == nil {
                    // Find the corresponding product
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        // Cache the subscription
                        purchasedSubscriptions = [subscription]
                        return .active(subscription)
                    } else {
                        // If we don't have the product loaded yet, load products and try again
                        await loadProducts()
                        if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                            purchasedSubscriptions = [subscription]
                            return .active(subscription)
                        }
                    }
                }
            } catch {
                Logger.error("Failed to verify transaction: \(error.localizedDescription)", category: .general)
            }
        }
        
        return .none
    }
    
    // MARK: - Private Methods
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    // Update the user's subscription status
                    await self.updateSubscriptionStatus()
                    
                    // Finish the transaction
                    await transaction.finish()
                    
                    // Notify observers of the change
                    await MainActor.run {
                        self.objectWillChange.send()
                    }
                } catch {
                    Logger.error("Transaction failed verification: \(error.localizedDescription)", category: .general)
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func updateSubscriptionStatus() async {
        var purchasedSubscriptions: [Product] = []
        
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if the subscription is still active
                if transaction.revocationDate == nil {
                    // Find the corresponding product
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                    } else {
                        // If we don't have the product loaded yet, load products and try again
                        await loadProducts()
                        if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                            purchasedSubscriptions.append(subscription)
                        }
                    }
                }
            } catch {
                Logger.error("Failed to verify transaction: \(error.localizedDescription)", category: .general)
            }
        }
        
        // Update the published property
        await MainActor.run {
            self.purchasedSubscriptions = purchasedSubscriptions
        }
    }
    
    // MARK: - Preview/Simulator Support
    
    private func setupPreviewData() {
        // In previews, we'll use the StoreKit configuration file
        // This will be handled by the StoreKit configuration in the scheme settings
        Task {
            await loadProducts()
        }
    }
    
    private func simulatePurchase(_ product: Product) async {
        // Simulate a successful purchase in previews
        purchasedSubscriptions = [product]
        await updateSubscriptionStatus()
    }
}

// MARK: - Store Error
enum StoreError: Error {
    case failedVerification
}

// MARK: - Subscription Status
enum SubscriptionStatus {
    case none
    case active(Product)
    
    var isActive: Bool {
        switch self {
        case .none:
            return false
        case .active:
            return true
        }
    }
    
    var product: Product? {
        switch self {
        case .none:
            return nil
        case .active(let product):
            return product
        }
    }
}

// MARK: - Preview Support
#if DEBUG
struct MockProduct {
    let id: String
    let type: StoreKit.Product.ProductType
    let displayName: String
    let description: String
    let price: Decimal
    let displayPrice: String
    
    var subscription: StoreKit.Product.SubscriptionInfo? { nil }
    
    func purchase() async throws -> StoreKit.Transaction? {
        return nil
    }
}

extension MockProduct {
    static func == (lhs: MockProduct, rhs: MockProduct) -> Bool {
        lhs.id == rhs.id
    }
}
#endif 
