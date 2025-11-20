//
//  InputView 2.swift
//  AIChatApp
//
//  Created by Shivani Sisodiya on 20/11/25.
//


import SwiftUI

struct InputView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 12) {
            Toggle("Live Mode", isOn: $viewModel.isLiveMode)
                .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                .padding(.horizontal)
                .animation(.easeInOut, value: viewModel.isLiveMode)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.quickActions, id: \.self) { action in
                        Button(action: {
                            viewModel.performQuickAction(action)
                        }) {
                            Text(action)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            HStack(spacing: 12) {
                TextField("Type a message...", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.sendMessage(viewModel.inputText)
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .disabled(viewModel.inputText.isEmpty)
                .scaleEffect(viewModel.inputText.isEmpty ? 0.9 : 1.0)
                .animation(.spring(), value: viewModel.inputText.isEmpty)
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.toggleRecording()
                    }
                }) {
                    Image(systemName: viewModel.isRecording ? "mic.fill" : "mic")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            viewModel.isRecording ?
                                LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]), startPoint: .top, endPoint: .bottom) :
                                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(Circle())
                        .shadow(color: (viewModel.isRecording ? Color.red : Color.blue).opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
                .animation(.spring(), value: viewModel.isRecording)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(25)
        .padding(.horizontal)
    }
}

#Preview {
    InputView(viewModel: ChatViewModel())
}
