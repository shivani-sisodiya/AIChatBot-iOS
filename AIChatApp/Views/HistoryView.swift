import SwiftUI
import SwiftData

struct HistoryView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var selectedTab: Int
    @State private var showDeleteAlert = false
    @State private var sessionToDelete: Session?

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.1),
                    Color.blue.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            NavigationView {
                VStack {
                    List {
                        ForEach(viewModel.sessions, id: \.id) { session in
                            sessionRow(session)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .onAppear {
                        viewModel.sessions = viewModel.getAllSessions()
                    }
                }
                .navigationTitle("Session History")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.startNewSession(
                                    title: "New Session \(Date().formatted(date: .abbreviated, time: .shortened))"
                                )
                                selectedTab = 0
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Session"),
                message: Text("Are you sure you want to delete this session? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    if let session = sessionToDelete {
                        viewModel.deleteSession(session)
                        viewModel.sessions = viewModel.getAllSessions()
                    }
                    sessionToDelete = nil
                },
                secondaryButton: .cancel {
                    sessionToDelete = nil
                }
            )
        }
    }

    // MARK: - Session Row UI
    private func sessionRow(_ session: Session) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "message.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text(session.title)
                        .font(.headline)
                    Text(session.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(session.messages.count) messages")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }

            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.loadSession(session)
                        selectedTab = 0
                    }
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Resume")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .buttonStyle(.borderless)

                Button(action: {
                    sessionToDelete = session
                    showDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                        Text("Delete")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(20)
                    .shadow(color: Color.red.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.25),
                    Color.purple.opacity(0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
        .shadow(color: Color.purple.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                sessionToDelete = session
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                withAnimation(.spring()) {
                    viewModel.loadSession(session)
                    selectedTab = 0
                }
            } label: {
                Label("Resume", systemImage: "play.fill")
            }
            .tint(.blue)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab = 0

        var body: some View {
            HistoryView(viewModel: ChatViewModel(), selectedTab: $selectedTab)
        }
    }
    return PreviewWrapper()
}
