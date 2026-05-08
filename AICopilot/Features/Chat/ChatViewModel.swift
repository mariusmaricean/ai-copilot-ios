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

    func send(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        messages.append(ChatMessage(role: .user, content: text))
        inputText = ""

        let assistantMessage = ChatMessage(role: .assistant, content: "")
        messages.append(assistantMessage)
        isStreaming = true

        let fakeResponse = """
        Here is a concise summary:

        • The note contains key ideas that can be turned into actions.
        • The main intent is productivity and follow-up.
        • Suggested next step: create tasks from the extracted points.
        """

        for character in fakeResponse {
            try? await Task.sleep(nanoseconds: 20_000_000)

            guard let index = messages.lastIndex(where: { $0.id == assistantMessage.id }) else {
                continue
            }

            messages[index].content.append(character)
        }

        isStreaming = false
    }

    func startIfNeeded(with prompt: String?) async {
        guard messages.isEmpty, let prompt else { return }
        await send(prompt)
    }
}
