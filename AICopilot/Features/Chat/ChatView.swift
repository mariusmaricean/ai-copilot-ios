//
//  ChatView.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import SwiftUI

struct ChatView: View {
    let initialPrompt: String?

    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) {
                        scrollToBottom(proxy)
                    }
                }

                Divider()

                HStack {
                    TextField("Ask Copilot...", text: $viewModel.inputText)
                        .textFieldStyle(.roundedBorder)

                    Button("Send") {
                        Task {
                            await viewModel.send(viewModel.inputText)
                        }
                    }
                    .disabled(viewModel.isStreaming)
                }
                .padding()
            }
            .navigationTitle("AI Copilot")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.startIfNeeded(with: initialPrompt)
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let last = viewModel.messages.last else { return }

        withAnimation {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble
                Spacer()
            } else {
                Spacer()
                bubble
            }
        }
    }

    private var bubble: some View {
        Text(message.content)
            .padding()
            .background(message.role == .assistant ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(Color.blue.opacity(0.15)))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: 300, alignment: message.role == .assistant ? .leading : .trailing)
    }
}
