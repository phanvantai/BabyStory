import SwiftUI

struct PaywallView: View {
    var onClose: () -> Void
    var onUpgrade: () -> Void
    let config: StoryGenerationConfig
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background using the app's standard gradient background
            AppGradientBackground()
            
            // Floating stars for visual interest and app consistency
            FloatingStars(count: 8)
            
            VStack(spacing: 24) {
                // Header with animated elements
                AnimatedEntrance(delay: 0.1) {
                    VStack(spacing: 12) {
                        // Icon container with gradient background (matching app style)
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 35))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        
                        VStack(spacing: 8) {
                            // Using GradientText for title (app consistency)
                            GradientText(
                                "Daily Limit Reached",
                                font: .system(size: 24, weight: .bold, design: .rounded),
                                colors: [Color.orange, Color.pink]
                            )
                            .multilineTextAlignment(.center)
                            
                            Text("You've used all your free stories for today")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.top, 16)
                
                // Usage display with animation
                AnimatedEntrance(delay: 0.3) {
                    StoryUsageLimitView(
                        storiesGenerated: config.storiesGeneratedToday,
                        dailyLimit: config.dailyStoryLimit,
                        tier: config.subscriptionTier
                    )
                    .padding(.horizontal)
                }
                
                // Premium features with animation - using AppCardStyle for consistency
                AnimatedEntrance(delay: 0.5) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Unlock Premium Benefits")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        FeatureRow(icon: "sparkles.rectangle.stack", text: "Up to \(SubscriptionTier.premium.dailyStoryLimit) stories every day")
                        FeatureRow(icon: "wand.and.stars", text: "Premium AI models for richer stories")
                        FeatureRow(icon: "gearshape.2", text: "Custom story settings")
                    }
                    .padding()
                    .appCardStyle(
                        backgroundColor: Color.purple.opacity(0.1),
                        borderColor: Color.purple.opacity(0.3),
                        shadowColor: Color.purple.opacity(0.2)
                    )
                    .padding(.horizontal)
                }
                
                // Buttons with animation - using app's standard button styles
                AnimatedEntrance(delay: 0.7) {
                    VStack(spacing: 16) {
                        Button(action: onUpgrade) {
                            HStack(spacing: 12) {
                                Text("Upgrade to Premium")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "sparkles")
                                    .font(.title3)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(colors: [Color.purple, Color.pink]))
                        
                        Button(action: onClose) {
                            Text("Maybe Later")
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 24)
                }
                
                // Reset message with animation
                AnimatedEntrance(delay: 0.8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        
                        Text("Your stories will reset tomorrow")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.cardBackground.opacity(0.95))
                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                    .shadow(color: AppTheme.defaultCardShadow.opacity(0.15), radius: 20, x: 0, y: 5)
            )
            .padding(.horizontal, 24)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Feature row component
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: AppTheme.primaryButton),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.system(size: 14))
            }
            
            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

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
