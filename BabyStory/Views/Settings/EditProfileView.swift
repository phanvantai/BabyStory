//
//  EditProfileView.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct EditProfileView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = EditProfileViewModel()
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) private var colorScheme
  @State private var showContent = false
  @State private var showSaveConfirmation = false
  @State private var showCancelConfirmation = false
  
  var body: some View {
    NavigationStack {
      ZStack {
        AppGradientBackground()
        
        // Floating decorative elements
        FloatingStars(count: 6)
        
        if viewModel.isLoading {
          LoadingCard(message: "Saving profile...")
        } else {
          ScrollView {
            VStack(spacing: 24) {
              // Header section
              AnimatedEntrance(delay: 0.2) {
                EditProfileHeaderView()
              }
              
              // Form content
              AnimatedEntrance(delay: 0.4) {
                VStack(spacing: 20) {
                  // Baby stage selection
                  EditProfileBabyStageSelector(viewModel: viewModel)
                  
                  // Name input
                  NameInputField(
                    name: $viewModel.name,
                    iconName: "textformat.abc",
                    iconColor: .cyan,
                    label: viewModel.isPregnancy ? "Baby's Name" : "Name",
                    placeholder: viewModel.isPregnancy ? "What will you call your baby?" : "Enter your child's name"
                  )
                  
                  // Gender selection
                  EditProfileGenderSelector(viewModel: viewModel)
                  
                  // Date of birth input (if not pregnancy)
                  if viewModel.shouldShowDateOfBirth {
                    EditProfileDateOfBirthPicker(viewModel: viewModel)
                  }
                  
                  // Due date (if pregnancy)
                  if viewModel.shouldShowDueDate {
                    DueDatePicker(dueDate: $viewModel.dueDate)
                  }
                  
                  // Parent names (if pregnancy)
                  if viewModel.shouldShowParentNames {
                    EditProfileParentNamesInput(viewModel: viewModel)
                  }
                  
                  // Interests selection
                  EditProfileInterestsSelector(viewModel: viewModel)
                  
                  // Story time picker
                  StoryTimePicker(
                    storyTime: $viewModel.storyTime,
                    showTimePicker: $viewModel.showTimePicker
                  )
                  
                  // Save button
                  AnimatedEntrance(delay: 0.6) {
                    SaveButtonView()
                  }
                }
                .padding(.horizontal, 24)
              }
              
              Spacer(minLength: 50)
            }
            .padding(.top, 20)
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            if viewModel.hasChanges {
              showCancelConfirmation = true
            } else {
              dismiss()
            }
          }
          .foregroundColor(.secondary)
        }
        

      }
      .alert("Error", isPresented: .constant(viewModel.error != nil)) {
        Button("OK") {
          viewModel.error = nil
        }
      } message: {
        Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
      }
      .confirmationDialog("Unsaved Changes", isPresented: $showCancelConfirmation) {
        Button("Discard Changes", role: .destructive) {
          viewModel.cancelEditing()
          dismiss()
        }
        Button("Keep Editing", role: .cancel) { }
      } message: {
        Text("You have unsaved changes. What would you like to do?")
      }
      .sheet(isPresented: $viewModel.showTimePicker) {
        TimePickerOverlay(
          showTimePicker: $viewModel.showTimePicker,
          storyTime: $viewModel.storyTime
        )
      }
      .onAppear {
        showContent = true
      }
    }
  }
  
  // MARK: - Subviews
  @ViewBuilder
  private func EditProfileHeaderView() -> some View {
    VStack(spacing: 16) {
      // Icon
      ZStack {
        RoundedRectangle(cornerRadius: 20)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [Color.blue, Color.purple]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 80, height: 80)
          .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        
        Image(systemName: "person.circle.fill")
          .font(.system(size: 35))
          .foregroundColor(.white)
      }
      
      VStack(spacing: 8) {
        GradientText(
          "Edit Profile",
          font: .system(size: 28, weight: .bold, design: .rounded),
          colors: [Color.blue, Color.purple]
        )
        .multilineTextAlignment(.center)
        
        Text("Update baby information")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
    }
  }
  
  @ViewBuilder
  private func SaveButtonView() -> some View {
    Button(action: {
      Task {
        let success = await viewModel.saveProfile()
        if success {
          dismiss()
        }
      }
    }) {
      HStack {
        if viewModel.isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(0.8)
        } else {
          Image(systemName: "checkmark.circle.fill")
            .font(.title3)
        }
        
        Text(viewModel.isLoading ? "Saving..." : "Save Changes")
          .font(.headline)
          .fontWeight(.semibold)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 56)
      .background(
        LinearGradient(
          gradient: Gradient(colors: viewModel.canSave ? [Color.green, Color.teal] : [Color.gray, Color.gray.opacity(0.8)]),
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .foregroundColor(.white)
      .cornerRadius(28)
    }
    .disabled(!viewModel.canSave)
    .padding(.horizontal, 24)
    .padding(.top, 16)
  }
}

#Preview {
    EditProfileView()
}
