import Foundation
import StoreKit

struct SubscriptionLocalization {
    let locale: Locale
    let monthlyPrice: Decimal
    let yearlyPrice: Decimal
    let currencySymbol: String
    let currencyCode: String
    
    // Localized strings
    let monthlyTitle: String
    let yearlyTitle: String
    let monthlyDescription: String
    let yearlyDescription: String
    let trialPeriod: String
    let cancelAnytime: String
    let premiumFeatures: String
    let features: [String]
    
    static let defaultLocalizations: [SubscriptionLocalization] = [
        // US
        SubscriptionLocalization(
            locale: Locale(identifier: "en_US"),
            monthlyPrice: 4.99,
            yearlyPrice: 39.99,
            currencySymbol: "$",
            currencyCode: "USD",
            monthlyTitle: "Premium Monthly",
            yearlyTitle: "Premium Yearly",
            monthlyDescription: "Monthly premium subscription",
            yearlyDescription: "Yearly premium subscription (Save 33%)",
            trialPeriod: "7-day free trial",
            cancelAnytime: "Cancel anytime",
            premiumFeatures: "Premium Features",
            features: [
                "20 stories per day",
                "Access to advanced AI models",
                //"Voice narration",
                "Custom story settings",
                //"Multiple baby profiles"
            ]
        ),
        // Vietnam
        SubscriptionLocalization(
            locale: Locale(identifier: "vi_VN"),
            monthlyPrice: 99000,
            yearlyPrice: 790000,
            currencySymbol: "₫",
            currencyCode: "VND",
            monthlyTitle: "Gói Premium Hàng Tháng",
            yearlyTitle: "Gói Premium Hàng Năm",
            monthlyDescription: "Đăng ký premium hàng tháng",
            yearlyDescription: "Đăng ký premium hàng năm (Tiết kiệm 33%)",
            trialPeriod: "Dùng thử miễn phí 7 ngày",
            cancelAnytime: "Hủy bất kỳ lúc nào",
            premiumFeatures: "Tính năng Premium",
            features: [
                "20 câu chuyện mỗi ngày",
                "Truy cập các mô hình AI nâng cao",
                //"Đọc chuyện bằng giọng nói",
                "Tùy chỉnh cài đặt câu chuyện",
                //"Nhiều hồ sơ bé"
            ]
        )
    ]
    
    static func localization(for locale: Locale) -> SubscriptionLocalization {
        // Get the preferred language from the locale
      let preferredLanguage = locale.language.languageCode?.identifier ?? "en"
        
        // First try to find exact locale match (e.g., en_US, vi_VN)
        if let exact = defaultLocalizations.first(where: { $0.locale.identifier == locale.identifier }) {
            return exact
        }
        
        // Then try to find a match for the same language but different region
        // This handles cases like en_GB, en_AU, etc.
      if let languageMatch = defaultLocalizations.first(where: { $0.locale.language.languageCode?.identifier == preferredLanguage }) {
            // Create a new localization with the matched language content but current locale's currency
            return createLocalizationWithCurrentCurrency(
                baseLocalization: languageMatch,
                targetLocale: locale
            )
        }
        
        // Fallback to US English
        return defaultLocalizations.first(where: { $0.locale.identifier == "en_US" })!
    }
    
    private static func createLocalizationWithCurrentCurrency(
        baseLocalization: SubscriptionLocalization,
        targetLocale: Locale
    ) -> SubscriptionLocalization {
        // Get the currency formatter for the target locale
        let formatter = NumberFormatter()
        formatter.locale = targetLocale
        formatter.numberStyle = .currency
        
        // Convert prices to the target currency
        // Note: In a real app, you would use a currency conversion service
        // This is just a placeholder for demonstration
        let monthlyPrice = baseLocalization.monthlyPrice
        let yearlyPrice = baseLocalization.yearlyPrice
        
        return SubscriptionLocalization(
            locale: targetLocale,
            monthlyPrice: monthlyPrice,
            yearlyPrice: yearlyPrice,
            currencySymbol: formatter.currencySymbol ?? "$",
            currencyCode: formatter.currencyCode ?? "USD",
            monthlyTitle: baseLocalization.monthlyTitle,
            yearlyTitle: baseLocalization.yearlyTitle,
            monthlyDescription: baseLocalization.monthlyDescription,
            yearlyDescription: baseLocalization.yearlyDescription,
            trialPeriod: baseLocalization.trialPeriod,
            cancelAnytime: baseLocalization.cancelAnytime,
            premiumFeatures: baseLocalization.premiumFeatures,
            features: baseLocalization.features
        )
    }
    
    func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: price as NSDecimalNumber) ?? "\(currencySymbol)\(price)"
    }
    
    func formatMonthlyPrice(_ yearlyPrice: Decimal) -> String {
        let monthlyPrice = yearlyPrice / 12
        return formatPrice(monthlyPrice)
    }
} 
