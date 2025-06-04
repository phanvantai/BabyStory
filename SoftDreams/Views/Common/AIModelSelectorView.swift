import SwiftUI

struct AIModelSelectorView: View {
    @Binding var selectedModel: AIModel
    let subscriptionTier: SubscriptionTier
    var onSelectModel: ((AIModel) -> Void)?
    
    private var availableModels: [AIModel] {
        return subscriptionTier.availableModels
    }
    
    private var lockedModels: [AIModel] {
        return AIModel.allCases.filter { !subscriptionTier.availableModels.contains($0) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ai_model_selection_title".localized)
                .font(.headline)
                .padding(.bottom, 4)
            
            Text("ai_model_selection_description".localized)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            
            // Available models
            ForEach(availableModels, id: \.self) { model in
                ModelRow(
                    model: model,
                    isSelected: selectedModel == model,
                    isLocked: false,
                    onTap: {
                        selectedModel = model
                        onSelectModel?(model)
                    }
                )
            }
            
            // Locked models (for non-premium users)
            if subscriptionTier == .free && !lockedModels.isEmpty {
                Text("Premium Models")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
                
                ForEach(lockedModels, id: \.self) { model in
                    ModelRow(
                        model: model,
                        isSelected: false,
                        isLocked: true,
                        onTap: {}
                    )
                }
                
                // Upgrade prompt
                Text("ai_model_upgrade_prompt".localized)
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct ModelRow: View {
    let model: AIModel
    let isSelected: Bool
    let isLocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: isLocked ? {} : onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(model.displayName)
                            .font(.subheadline)
                            .fontWeight(isSelected ? .semibold : .regular)
                        
                        if model.isPremium {
                            Text("ai_model_premium_badge".localized)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.15))
                                )
                                .foregroundStyle(.blue)
                        } else {
                            Text("ai_model_free_badge".localized)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.15))
                                )
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Text(model.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Free User Model Selector") {
  AIModelSelectorView(
      selectedModel: .constant(.gpt35Turbo),
      subscriptionTier: .free
  )
}

#Preview("Premium User") {
  AIModelSelectorView(
      selectedModel: .constant(.gpt4o),
      subscriptionTier: .premium
  )
}
