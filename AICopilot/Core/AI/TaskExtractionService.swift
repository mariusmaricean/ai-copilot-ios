//
//  TaskExtractionService.swift
//  AICopilot
//
//  Created by Marius Maricean on 11.05.2026.
//

import Foundation

final class TaskExtractionService {
    private let aiService: AIService

    init(aiService: AIService = OpenAIService()) {
        self.aiService = aiService
    }

    func extractTasks(from noteContent: String,  memoryContext: String) async throws -> [ExtractedTask] {
        let prompt = """
        You are an AI productivity assistant.

        Context:
        \(memoryContext)

        Extract clear, actionable tasks from the following note.

        Rules:
        - Return ONLY valid JSON
        - Do not include markdown
        - Do not include explanations
        - Keep task titles concise
        - Avoid duplicates
        - Ignore vague ideas
        - Only extract tasks that require action

        Format:
        [
          {
            "title": "Task title"
          }
        ]

        Note:
        \(noteContent)
        """

        let response = try await aiService.sendMessage(prompt)
        let cleanedResponse = cleanJSON(response)

        guard let data = cleanedResponse.data(using: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }

        return try JSONDecoder().decode([ExtractedTask].self, from: data)
    }

    private func cleanJSON(_ text: String) -> String {
        text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
