//
//  ChatViewModel.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isStreaming = false
    @Published var errorMessage: String?

    private let aiService: AIService

    init(aiService: AIService = OpenAIService()) {
        self.aiService = aiService
    }

    func send(_ text: String) async {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        messages.append(ChatMessage(role: .user, content: trimmedText))
        inputText = ""

        let assistantMessage = ChatMessage(role: .assistant, content: "")
        messages.append(assistantMessage)

        isStreaming = true
        errorMessage = nil

        do {
            for try await delta in aiService.streamResponse(for: trimmedText) {
                guard let index = messages.lastIndex(where: { $0.id == assistantMessage.id }) else {
                    continue
                }

                messages[index].content.append(delta)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isStreaming = false
    }

    func startIfNeeded(with prompt: String?) async {
        guard messages.isEmpty, let prompt else { return }
        await send(prompt)
    }
}
