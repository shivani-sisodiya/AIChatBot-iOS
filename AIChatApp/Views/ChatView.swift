import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var showSteps = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.10),
                    Color.purple.opacity(0.10)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                ScrollView {
                    LazyVStack(spacing: 12) {

                        // Processing Steps Card
                        if !viewModel.processingSteps.isEmpty {
                            DisclosureGroup(isExpanded: $showSteps) {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(viewModel.processingSteps, id: \.self) { step in
                                        Text(step)
                                            .font(.caption)
                                    }
                                }
                                .padding(.top, 8)
                            } label: {
                                Text("Processing Steps")
                                    .font(.headline)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.purple.opacity(0.7),
                                        Color.blue.opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.purple.opacity(0.3), radius: 6, x: 0, y: 3)
                            .padding(.horizontal)
                        }

                        // Chat messages
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message, viewModel: viewModel)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .scale))
                                .animation(.easeInOut(duration: 0.3), value: viewModel.messages.count)
                        }

                        // Processing Indicator UI
                        if viewModel.isProcessing {
                            HStack {
                                Spacer()
                                VStack(spacing: 6) {
                                    ProgressView()
                                        .scaleEffect(1.3)
                                    Text("Processing...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(10)
                                .cornerRadius(12)
                                .shadow(color: Color.gray.opacity(0.3), radius: 6, x: 0, y: 3)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                }

                // Bottom Input
                InputView(viewModel: viewModel)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -3)
            }
        }
        .navigationTitle(viewModel.currentSession?.title ?? "AI Chat")
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel())
}
