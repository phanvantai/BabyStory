import SwiftUI

struct OnboardingProfileView: View {
  @ObservedObject var viewModel: OnboardingViewModel
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
            VStack(spacing: 16) {
              // Icon
              ZStack {
                RoundedRectangle(cornerRadius: 16)
                  .fill(
                    LinearGradient(
                      gradient: Gradient(colors: [Color.pink, Color.purple]),
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
              .scaleEffect(isAnimating ? 1.05 : 1.0)
              .animation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true),
                value: isAnimating
              )
              
              VStack(spacing: 8) {
                GradientText(
                  "Tell us about your baby",
                  font: .system(size: 28, weight: .bold, design: .rounded),
                  colors: [Color.purple, Color.pink]
                )
                .multilineTextAlignment(.center)
                
                Text("This helps us create the perfect stories")
                  .font(.body)
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.center)
              }
            }
          }
          
          // Form content
          AnimatedEntrance(delay: 0.4) {
            VStack(spacing: 24) {
              // Baby stage selection
              VStack(spacing: 16) {
                HStack {
                  Image(systemName: "heart.circle.fill")
                    .foregroundColor(.pink)
                    .font(.title3)
                  Text("Baby Stage")
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
                                  Color.white.opacity(0.8))
                          .stroke(viewModel.babyStage == stage ?
                                  Color.purple :
                                    Color.gray.opacity(0.3), lineWidth: 2)
                      )
                    }
                    .foregroundColor(.primary)
                  }
                }
              }
            }
          }
          
          // Name input
          VStack(spacing: 12) {
            HStack {
              Image(systemName: "textformat.abc")
                .foregroundColor(.cyan)
                .font(.title3)
              Text(viewModel.isPregnancy ? "Baby's Name" : "Name")
                .font(.headline)
                .fontWeight(.semibold)
              Spacer()
            }
            
            TextField(viewModel.isPregnancy ? "What will you call your baby?" : "Enter your child's name", text: $viewModel.name)
              .textFieldStyle(CustomTextFieldStyle())
          }
          
          // Age input (if not pregnancy)
          if viewModel.shouldShowAge {
            VStack(spacing: 12) {
              HStack {
                Image(systemName: "calendar")
                  .foregroundColor(.green)
                  .font(.title3)
                Text("Age")
                  .font(.headline)
                  .fontWeight(.semibold)
                Spacer()
                
                // Show info for fixed ages
                if !viewModel.canEditAge {
                  Text("Fixed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                }
              }
              
              HStack {
                Button(action: viewModel.decreaseAge) {
                  Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(viewModel.canEditAge ? .purple : .gray)
                }
                .disabled(!viewModel.canEditAge)
                
                Spacer()
                
                Text(viewModel.ageDisplayText)
                  .font(.title3)
                  .fontWeight(.semibold)
                  .frame(minWidth: 120)
                
                Spacer()
                
                Button(action: viewModel.increaseAge) {
                  Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(viewModel.canEditAge ? .purple : .gray)
                }
                .disabled(!viewModel.canEditAge)
              }
              .padding(.horizontal, 16)
              .padding(.vertical, 12)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(viewModel.canEditAge ? Color.white.opacity(0.8) : Color.gray.opacity(0.1))
                  .stroke(Color.gray.opacity(0.3), lineWidth: 1)
              )
            }
          }
          
          // Due date (if pregnancy)
          if viewModel.shouldShowDueDate {
            VStack(spacing: 12) {
              HStack {
                Image(systemName: "heart.fill")
                  .foregroundColor(.pink)
                  .font(.title3)
                Text("Due Date")
                  .font(.headline)
                  .fontWeight(.semibold)
                Spacer()
              }
              
              DatePicker("", selection: $viewModel.dueDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                  RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.8))
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
          }
          
          // Parent names (if pregnancy)
          if viewModel.shouldShowParentNames {
            VStack(spacing: 12) {
              HStack {
                Image(systemName: "figure.2.and.child.holdinghands")
                  .foregroundColor(.orange)
                  .font(.title3)
                Text("Parent Names")
                  .font(.headline)
                  .fontWeight(.semibold)
                Spacer()
                
                if viewModel.parentNames.count < 2 {
                  Button(action: viewModel.addParentName) {
                    Image(systemName: "plus.circle.fill")
                      .foregroundColor(.purple)
                      .font(.title3)
                  }
                }
              }
              
              ForEach(Array(viewModel.parentNames.enumerated()), id: \.offset) { index, name in
                HStack {
                  TextField("Parent \(index + 1) name", text: $viewModel.parentNames[index])
                    .textFieldStyle(CustomTextFieldStyle())
                  
                  if viewModel.parentNames.count > 1 {
                    Button(action: {
                      viewModel.removeParentName(at: index)
                    }) {
                      Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                    }
                  }
                }
              }
            }
          }
          
          // Interests selection
          VStack(spacing: 16) {
            HStack {
              Image(systemName: "star.circle.fill")
                .foregroundColor(.yellow)
                .font(.title3)
              Text("Interests")
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
                              Color.white.opacity(0.8))
                      .stroke(viewModel.interests.contains(interest) ?
                              Color.green :
                                Color.gray.opacity(0.3), lineWidth: 1)
                  )
                }
                .foregroundColor(.primary)
              }
            }
          }
        }
        .padding(.horizontal, 24)
        
        // Continue button
        AnimatedEntrance(delay: 1.4) {
          VStack(spacing: 16) {
            Button(action: onNext) {
              HStack(spacing: 12) {
                Text("Continue")
                  .font(.headline)
                  .fontWeight(.semibold)
                
                Image(systemName: "arrow.right.circle.fill")
                  .font(.title3)
              }
            }
            .buttonStyle(PrimaryButtonStyle(
              colors: viewModel.canProceed ? [Color.purple, Color.pink] : [Color.gray, Color.gray.opacity(0.8)],
              isEnabled: viewModel.canProceed
            ))
            .disabled(!viewModel.canProceed)
            
            // Progress dots
            HStack(spacing: 8) {
              Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(width: 8, height: 8)
              
              Circle()
                .fill(Color.purple)
                .frame(width: 12, height: 12)
              
              Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(width: 8, height: 8)
            }
          }
          .padding(.horizontal, 32)
          .padding(.bottom, 32)
        }
        .padding(.top, 60)
      }
    }
    .onAppear {
      isAnimating = true
      showContent = true
      
      // Initialize parent names if pregnancy and empty
      if viewModel.isPregnancy && viewModel.parentNames.isEmpty {
        viewModel.addParentName()
      }
    }
  }
  
}

#Preview {
  OnboardingProfileView(
    viewModel: OnboardingViewModel(),
    onNext: {
      print("Next button tapped")
    }
  )
}
