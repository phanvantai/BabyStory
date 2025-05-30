import SwiftUI

struct OnboardingProfileView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) private var colorScheme
  var onNext: () -> Void
  @State private var isAnimating = false
  @State private var showContent = false
  
  var body: some View {
    ZStack {
      // Background
      AppGradientBackground()
      
      // Floating decorative elements
      FloatingStars(count: 8)
      
      ScrollView {
        VStack(spacing: 32) {
          // Header section
          AnimatedEntrance(delay: 0.2) {
            OnboardingHeaderView(
              isAnimating: $isAnimating,
              title: "Tell us about your baby",
              subtitle: "This helps us create the perfect stories",
              iconName: "person.circle.fill"
            )
          }
          
          // Form content
          AnimatedEntrance(delay: 0.4) {
            VStack(spacing: 24) {
              // Baby stage selection
              BabyStageSelector(viewModel: viewModel)
            }
          }
          
          // Name input
          NameInputField(
            name: $viewModel.name,
            iconName: "textformat.abc",
            iconColor: .cyan,
            label: viewModel.isPregnancy ? "Baby's Name" : "Name",
            placeholder: viewModel.isPregnancy ? "What will you call your baby?" : "Enter your child's name"
          )
          
          // Gender selection
          GenderSelector(viewModel: viewModel)
          
          // Date of birth input (if not pregnancy)
          if viewModel.shouldShowDateOfBirth {
            DateOfBirthPicker(viewModel: viewModel)
          }
          
          // Due date (if pregnancy)
          if viewModel.shouldShowDueDate {
            DueDatePicker(dueDate: $viewModel.dueDate)
          }
          
          // Parent names (if pregnancy)
          if viewModel.shouldShowParentNames {
            ParentNamesInput(viewModel: viewModel)
          }
          
          // Interests selection
          InterestsSelector(viewModel: viewModel)
        }
        .padding(.horizontal, 24)
        
        // Continue button
        AnimatedEntrance(delay: 1.4) {
          ProfileContinueFooter(
            viewModel: viewModel,
            onNext: onNext,
            currentPageIndex: 1,
            totalPages: 3
          )
        }
        .padding(.top, 60)
      }
    }
    .onAppear {
      isAnimating = true
      showContent = true
    }
    // Theme is handled at app level in BabyStoryApp.swift
  }
}

#Preview {
  OnboardingProfileView(
    viewModel: OnboardingViewModel(),
    onNext: {
      print("Next button tapped")
    }
  )
  .environmentObject(ThemeManager.shared)
}
