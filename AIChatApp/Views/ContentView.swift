import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ChatViewModel
    @State private var selectedTab = 0

    init() {
        let viewModel = ChatViewModel()
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ChatView(viewModel: viewModel)
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                .tag(0)
            HistoryView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)
        }
        .onAppear {
            viewModel.modelContext = modelContext
            // Auto-load most recent session on app launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.loadMostRecentSession()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Session.self, Message.self])
}
