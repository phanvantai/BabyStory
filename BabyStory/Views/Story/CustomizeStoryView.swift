import SwiftUI

struct CustomizeStoryView: View {
    @ObservedObject var viewModel: StoryGenerationViewModel
    var onGenerate: () -> Void
    @State private var charactersText: String = ""
    @State private var selectedTheme: StoryTheme = .adventure
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background
            AppGradientBackground()
            
            // Floating decorative elements
            FloatingStars(count: 8)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    AnimatedEntrance(delay: 0.2) {
                        VStack(spacing: 16) {
                            // Icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.purple, Color.blue]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "paintbrush.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                GradientText(
                                    "Customize Your Story",
                                    font: .system(size: 28, weight: .bold, design: .rounded),
                                    colors: [Color.purple, Color.blue]
                                )
                                .multilineTextAlignment(.center)
                                
                                Text("Create the perfect adventure")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    
                    // Story Length Section
                    AnimatedEntrance(delay: 0.4) {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                Text("Story Length")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            StoryLengthSelector(selectedLength: $viewModel.options.length)
                        }
                        .padding(20)
                        .appCardStyle()
                    }
                    
                    // Theme Selection Section
                    AnimatedEntrance(delay: 0.6) {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.pink)
                                    .font(.title3)
                                Text("Story Theme")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                ForEach(StoryTheme.allCases, id: \.self) { theme in
                                    Button(action: {
                                        selectedTheme = theme
                                        viewModel.options.theme = theme.rawValue
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: theme.icon)
                                                .font(.title2)
                                                .foregroundColor(selectedTheme == theme ? .white : .primary)
                                            
                                            Text(theme.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(selectedTheme == theme ? .white : .primary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 80)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedTheme == theme ?
                                                      LinearGradient(
                                                        gradient: Gradient(colors: [Color.purple, Color.pink]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                      ) :
                                                      LinearGradient(
                                                        gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.8)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                      )
                                                )
                                                .stroke(selectedTheme == theme ? Color.purple : Color.gray.opacity(0.3), lineWidth: selectedTheme == theme ? 2 : 1)
                                                .shadow(color: selectedTheme == theme ? Color.purple.opacity(0.3) : Color.black.opacity(0.1), radius: selectedTheme == theme ? 8 : 4, x: 0, y: 2)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            if selectedTheme != .adventure {
                                Text(selectedTheme.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                            }
                        }
                        .padding(20)
                        .appCardStyle()
                    }
                    
                    // Characters Section
                    AnimatedEntrance(delay: 0.8) {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.cyan)
                                    .font(.title3)
                                Text("Characters")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                TextField("Add characters (e.g., brave princess, friendly dragon)", text: $charactersText)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .onChange(of: charactersText) { newValue in
                                        viewModel.options.characters = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                                    }
                                
                                Text("Separate multiple characters with commas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(20)
                        .appCardStyle()
                    }
                    
                    // Generate Button
                    AnimatedEntrance(delay: 1.0) {
                        Button(action: {
                            if !charactersText.isEmpty {
                                viewModel.options.characters = charactersText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                            }
                            onGenerate()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "wand.and.stars")
                                    .font(.title3)
                                Text("Create My Story")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(colors: [Color.purple, Color.pink]))
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            showContent = true
            // Initialize selected theme from viewModel
            if let currentTheme = StoryTheme.allCases.first(where: { $0.rawValue == viewModel.options.theme }) {
                selectedTheme = currentTheme
            }
            // Initialize characters text from viewModel
            charactersText = viewModel.options.characters.joined(separator: ", ")
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CustomizeStoryView(
            viewModel: {
                let vm = StoryGenerationViewModel()
                // Initialize with some sample data
                vm.options.theme = "Adventure"
                vm.options.length = .medium
                vm.options.characters = ["brave knight", "friendly dragon"]
                return vm
            }()
        ) {
            print("Generate story tapped in preview")
        }
        .navigationTitle("Customize")
    }
}
