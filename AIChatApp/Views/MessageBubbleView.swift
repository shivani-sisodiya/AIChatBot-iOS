import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.text)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(16)
                        .foregroundColor(.primary)
                    if let feedback = message.feedback {
                        HStack {
                            Button(action: { viewModel.provideFeedback(for: message, feedback: .thumbsUp) }) {
                                Image(systemName: feedback == .thumbsUp ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundColor(.green)
                            }
                            Button(action: { viewModel.provideFeedback(for: message, feedback: .thumbsDown) }) {
                                Image(systemName: feedback == .thumbsDown ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                    .foregroundColor(.red)
                            }
                        }
                        .font(.caption)
                    }
                }
                .transition(.opacity)
                .animation(.easeIn, value: message.id)
            } else {
                VStack(alignment: .leading) {
                    Text(message.text)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(16)
                        .foregroundColor(.primary)
                    HStack {
                        Button(action: { viewModel.provideFeedback(for: message, feedback: .thumbsUp) }) {
                            Image(systemName: message.feedback == .thumbsUp ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .foregroundColor(.green)
                        }
                        Button(action: { viewModel.provideFeedback(for: message, feedback: .thumbsDown) }) {
                            Image(systemName: message.feedback == .thumbsDown ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                .foregroundColor(.red)
                        }
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= (message.starRating ?? 0) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        message.starRating = star
                                        viewModel.saveSession()
                                    }
                            }
                        }
                        .font(.caption)
                    }
                    .font(.caption)
                }
                .transition(.opacity)
                .animation(.easeIn, value: message.id)
                Spacer()
            }
        }
    }
}

#Preview {
    MessageBubbleView(message: Message(text: "Hello", isUser: true), viewModel: ChatViewModel())
}
