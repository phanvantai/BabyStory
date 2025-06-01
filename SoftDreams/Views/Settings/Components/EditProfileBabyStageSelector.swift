//
//  EditProfileBabyStageSelector.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 30/5/25.
//

import SwiftUI

struct EditProfileBabyStageSelector: View {
  @ObservedObject var viewModel: EditProfileViewModel
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "heart.circle.fill")
          .foregroundColor(.pink)
          .font(.title3)
        Text("settings_baby_stage_title".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
        ForEach(BabyStage.allCases, id: \.self) { stage in
          Button(action: {
            viewModel.updateBabyStage(stage)
          }) {
            VStack(spacing: 8) {
              Text(stage.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(viewModel.babyStage == stage ? .primary : .primary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
              
              Text(stage.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80) // Fixed height for consistent sizing
            .padding(12)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.babyStage == stage ?
                      Color.purple.opacity(0.2) :
                        AppTheme.cardBackground.opacity(0.8))
                .stroke(viewModel.babyStage == stage ?
                        Color.purple :
                          AppTheme.defaultCardBorder, lineWidth: 2)
            )
          }
          .foregroundColor(.primary)
        }
      }
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    EditProfileBabyStageSelector(viewModel: EditProfileViewModel())
      .padding()
  }
}
