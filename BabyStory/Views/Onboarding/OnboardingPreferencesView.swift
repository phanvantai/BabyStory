import SwiftUI

struct OnboardingPreferencesView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  var onNext: () -> Void
  @State private var isAnimating = false
  @State private var showSuccessAnimation = false
  @State private var showTimePicker = false
  
  var body: some View {
    ZStack {
      // Background
      AppGradientBackground()
      
      // Floating decorative elements
      FloatingStars(count: 12)
      
      ScrollView {
        VStack(spacing: 40) {
          // Header section
          AnimatedEntrance(delay: 0.2) {
            VStack(spacing: 20) {
              // Success icon with celebration animation
              ZStack {
                // Outer celebration ring
                Circle()
                  .stroke(
                    LinearGradient(
                      gradient: Gradient(colors: [Color.orange, Color.pink, Color.purple]),
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                  )
                  .frame(width: 140, height: 140)
                  .scaleEffect(showSuccessAnimation ? 1.2 : 1.0)
                  .opacity(showSuccessAnimation ? 0.3 : 0.8)
                  .animation(
                    .easeOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                    value: showSuccessAnimation
                  )
                
                // Main icon background
                RoundedRectangle(cornerRadius: 20)
                  .fill(
                    LinearGradient(
                      gradient: Gradient(colors: [Color.green, Color.teal]),
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    )
                  )
                  .frame(width: 100, height: 100)
                  .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                
                // Clock icon
                Image(systemName: "clock.fill")
                  .font(.system(size: 45))
                  .foregroundColor(.white)
              }
              .rotationEffect(.degrees(isAnimating ? 3 : -3))
              .animation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true),
                value: isAnimating
              )
              
              // Title and description
              VStack(spacing: 16) {
                GradientText(
                  "Perfect! Almost Done",
                  font: .system(size: 32, weight: .bold, design: .rounded)
                )
                .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                  Text("When would you like story time?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                  
                  Text("Set your preferred time and we'll send gentle reminders for magical bedtime stories")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                }
              }
            }
          }
          
          // Story time picker section
          AnimatedEntrance(delay: 0.4) {
            VStack(spacing: 24) {
              // Story time picker
              VStack(spacing: 16) {
                HStack {
                  Image(systemName: "moon.stars.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
                  Text("Story Time")
                    .font(.headline)
                    .fontWeight(.semibold)
                  Spacer()
                }
                
                VStack(spacing: 16) {
                  // Time display
                  HStack {
                    Spacer()
                    VStack(spacing: 4) {
                      Text("Bedtime Stories at")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                      
                      Text(viewModel.storyTime, style: .time)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                          LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                        )
                    }
                    Spacer()
                  }
                  .padding(.vertical, 20)
                  .background(
                    RoundedRectangle(cornerRadius: 16)
                      .fill(AppTheme.cardBackground.opacity(0.9))
                      .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                      .shadow(color: .purple.opacity(0.1), radius: 8, x: 0, y: 4)
                  )
                  .onTapGesture {
                    showTimePicker = true
                  }
                }
                
                // Story recommendations based on selected time
                VStack(spacing: 12) {
                  HStack {
                    Image(systemName: "lightbulb.fill")
                      .foregroundColor(.orange)
                      .font(.title3)
                    Text("Perfect Time For")
                      .font(.headline)
                      .fontWeight(.semibold)
                    Spacer()
                  }
                  
                  LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(getStoryRecommendations(), id: \.self) { recommendation in
                      HStack {
                        Text(recommendation)
                          .font(.subheadline)
                          .fontWeight(.medium)
                          .multilineTextAlignment(.leading)
                        Spacer()
                      }
                      .padding(12)
                      .background(
                        RoundedRectangle(cornerRadius: 10)
                          .fill(Color.orange.opacity(0.1))
                          .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                      )
                    }
                  }
                }
              }
              .padding(.horizontal, 24)
              
              // Profile summary section
              AnimatedEntrance(delay: 0.8) {
                VStack(spacing: 16) {
                  HStack {
                    Image(systemName: "checkmark.circle.fill")
                      .foregroundColor(.green)
                      .font(.title2)
                    Text("Profile Summary")
                      .font(.headline)
                      .fontWeight(.semibold)
                    Spacer()
                  }
                  
                  VStack(spacing: 12) {
                    ProfileSummaryRow(icon: "person.circle.fill", label: "Name", value: viewModel.name.isEmpty ? "Not set" : viewModel.name)
                    ProfileSummaryRow(icon: "heart.circle.fill", label: "Stage", value: viewModel.babyStage.displayName)
                    if !viewModel.isPregnancy {
                      ProfileSummaryRow(icon: "calendar", label: "Age", value: viewModel.ageDisplayText)
                    }
                    if !viewModel.interests.isEmpty {
                      ProfileSummaryRow(icon: "star.circle.fill", label: "Interests", value: "\(viewModel.interests.count) selected")
                    }
                  }
                  .padding(16)
                  .appCardStyle()
                }
                .padding(.horizontal, 24)
              }
              
              // Finish button
              AnimatedEntrance(delay: 1.0) {
                VStack(spacing: 16) {
                  Button(action: {
                    viewModel.saveProfile()
                    onNext()
                  }) {
                    HStack(spacing: 12) {
                      Text("Start Creating Stories!")
                        .font(.headline)
                        .fontWeight(.semibold)
                      
                      Image(systemName: "sparkles")
                        .font(.title3)
                    }
                  }
                  .buttonStyle(PrimaryButtonStyle(colors: [Color.green, Color.teal]))
                  
                  // Final progress dots
                  HStack(spacing: 8) {
                    Circle()
                      .fill(Color.green.opacity(0.3))
                      .frame(width: 8, height: 8)
                    
                    Circle()
                      .fill(Color.green.opacity(0.3))
                      .frame(width: 8, height: 8)
                    
                    Circle()
                      .fill(Color.green)
                      .frame(width: 12, height: 12)
                  }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
              }
            }
            .padding(.top, 60)
          }
        }
      }
      .onAppear {
        isAnimating = true
        
        // Delayed success animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          showSuccessAnimation = true
        }
      }
      
      // Time picker popup overlay
      if showTimePicker {
        // Background overlay
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture {
            showTimePicker = false
          }
        
        // Popup content
        VStack(spacing: 0) {
          Spacer()
          
          VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
              HStack {
                Button("Cancel") {
                  showTimePicker = false
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Story Time")
                  .font(.headline)
                  .fontWeight(.semibold)
                  .foregroundColor(.primary)
                
                Spacer()
                
                Button("Done") {
                  showTimePicker = false
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
              }
              
              Divider()
                .background(Color.gray.opacity(0.3))
            }
            
            // Time picker
            DatePicker(
              "Story Time",
              selection: $viewModel.storyTime,
              displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 200)
          }
          .padding(24)
          .background(
            RoundedRectangle(cornerRadius: 20)
              .fill(AppTheme.cardBackground)
              .shadow(color: AppTheme.defaultCardShadow.opacity(0.15), radius: 20, x: 0, y: -5)
          )
          .padding(.horizontal, 20)
          .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showTimePicker)
      }
    }
  }
  
  // Helper function to get time-based story recommendations
  private func getStoryRecommendations() -> [String] {
    let hour = Calendar.current.component(.hour, from: viewModel.storyTime)
    
    switch hour {
      case 6...11:
        return ["Morning Adventures", "Wake-up Stories", "Breakfast Tales", "Sunny Day Fun"]
      case 12...17:
        return ["Afternoon Play", "Learning Stories", "Outdoor Adventures", "Friend Tales"]
      case 18...21:
        return ["Bedtime Stories", "Calm Adventures", "Dream Journeys", "Goodnight Tales"]
      default:
        return ["Peaceful Dreams", "Quiet Stories", "Sleep Adventures", "Gentle Tales"]
    }
  }
}

// Helper view for profile summary rows


#Preview {
  OnboardingPreferencesView(
    viewModel: OnboardingViewModel(),
    onNext: {
      print("Onboarding finished!")
    }
  )
}
