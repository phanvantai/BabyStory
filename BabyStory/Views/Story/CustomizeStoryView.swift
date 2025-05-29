import SwiftUI

struct CustomizeStoryView: View {
    @ObservedObject var viewModel: StoryGenerationViewModel
    var onGenerate: () -> Void
    @State private var charactersText: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Length")) {
                Picker("Length", selection: $viewModel.options.length) {
                    ForEach(StoryLength.allCases) { length in
                        Text(length.rawValue.capitalized).tag(length)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section(header: Text("Theme")) {
                TextField("Theme", text: $viewModel.options.theme)
            }
            Section(header: Text("Characters")) {
                TextField("Characters (comma separated)", text: $charactersText)
                    .onChange(of: charactersText) { newValue in
                        viewModel.options.characters = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    }
            }
            Button("Generate") {
                if !charactersText.isEmpty {
                    viewModel.options.characters = charactersText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                }
                onGenerate()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
