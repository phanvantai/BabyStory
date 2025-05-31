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
              title: "onboarding_profile_title".localized,
              subtitle: "onboarding_profile_subtitle".localized,
              iconName: "person.circle.fill"
            )
          }
          
          // Form content
          AnimatedEntrance(delay: 0.4) {
            VStack(spacing: 24) {
              // First step: Pregnancy status selection
              PregnancyStatusSelector(viewModel: viewModel)
              
              // Show appropriate sections based on selection
              if viewModel.hasSelectedBabyStatus {
                if viewModel.isPregnancy {
                  // Pregnancy flow
                  VStack(spacing: 24) {
                    // Name input for pregnancy
                    NameInputField(
                      name: $viewModel.name,
                      iconName: "textformat.abc",
                      iconColor: .cyan,
                      label: "onboarding_profile_baby_name_label".localized,
                      placeholder: "onboarding_profile_baby_name_placeholder".localized
                    )
                    
                    // Gender selection
                    GenderSelector(viewModel: viewModel)
                    
                    // Due date
                    DueDatePicker(dueDate: $viewModel.dueDate)
                    
                    // Parent names
                    ParentNamesInput(viewModel: viewModel)
                    
                    // Interests selection
                    InterestsSelector(viewModel: viewModel)
                  }
                } else {
                  // Born baby flow
                  VStack(spacing: 24) {
                    // Baby stage selection (excluding pregnancy)
                    BornBabyStageSelector(viewModel: viewModel)
                    
                    // Name input for born baby
                    NameInputField(
                      name: $viewModel.name,
                      iconName: "textformat.abc",
                      iconColor: .cyan,
                      label: "onboarding_profile_child_name_label".localized,
                      placeholder: "onboarding_profile_child_name_placeholder".localized
                    )
                    
                    // Gender selection
                    GenderSelector(viewModel: viewModel)
                    
                    // Date of birth
                    DateOfBirthPicker(viewModel: viewModel)
                    
                    // Interests selection
                    InterestsSelector(viewModel: viewModel)
                  }
                }
              }
            }
          }
        }
        .padding(.horizontal, 24)
        
        // Continue button
        AnimatedEntrance(delay: 1.4) {
          ProfileContinueFooter(
            viewModel: viewModel,
            onNext: onNext,
            currentPageIndex: 2,
            totalPages: 4
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
