//
//  EditProfileInterestsSelector.swift
//  BabyStory
//
//  Created by Tai Phan Van on 30/5/25.
//

import SwiftUI

struct EditProfileInterestsSelector: View {
  @ObservedObject var viewModel: EditProfileViewModel
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "star.circle.fill")
          .foregroundColor(.yellow)
          .font(.title3)
        Text("settings_interests_title".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
        ForEach(viewModel.availableInterests, id: \.self) { interest in
          Button(action: {
            viewModel.toggleInterest(interest)
          }) {
            HStack {
              Text(interest)
                .font(.subheadline)
                .fontWeight(.medium)
              Spacer()
              if viewModel.interests.contains(interest) {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundColor(.green)
              }
            }
            .padding(12)
            .background(
              RoundedRectangle(cornerRadius: 10)
                .fill(viewModel.interests.contains(interest) ?
                      Color.green.opacity(0.2) :
                        AppTheme.cardBackground.opacity(0.8))
                .stroke(viewModel.interests.contains(interest) ?
                        Color.green :
                          AppTheme.defaultCardBorder, lineWidth: 1)
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
    EditProfileInterestsSelector(viewModel: {
      let vm = EditProfileViewModel()
      return vm
    }())
    .padding()
  }
}
