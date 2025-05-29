import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @StateObject private var storyGenVM = StoryGenerationViewModel()
    @StateObject private var libraryVM = LibraryViewModel()
    @StateObject private var settingsVM = SettingsViewModel()
    @State private var showCustomize = false
    @State private var showLibrary = false
    @State private var showProgress = false
    @State private var showStory = false
    @State private var showSettings = false
    @State private var generatedStory: Story? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Home Screen")
                    .font(.largeTitle)
                    .bold()
                Button("Today's Story") {
                    Task {
                        if let profile = viewModel.profile {
                            await storyGenVM.generateStory(profile: profile, options: nil)
                            generatedStory = storyGenVM.generatedStory
                            showStory = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Customize a Story") {
                    showCustomize = true
                }
                .buttonStyle(.bordered)
                Button("Library") {
                    showLibrary = true
                }
                .buttonStyle(.bordered)
                Button("Progress") {
                    showProgress = true
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationDestination(isPresented: $showCustomize) {
                CustomizeStoryView(viewModel: storyGenVM) {
                    if let profile = viewModel.profile {
                        Task {
                            await storyGenVM.generateStory(profile: profile, options: storyGenVM.options)
                            generatedStory = storyGenVM.generatedStory
                            showStory = true
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showLibrary) {
                LibraryView(viewModel: libraryVM)
            }
            .navigationDestination(isPresented: $showProgress) {
                Text("Progress Screen (TODO)")
            }
            .navigationDestination(isPresented: $showStory) {
                if let story = generatedStory {
                    StoryView(story: story, onSave: {
                        viewModel.saveStory(story)
                        libraryVM.loadStories()
                    }, showSave: true)
                } else {
                    Text("No story generated.")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: settingsVM)
            }
        }
    }
}
