//
//  OpenAIService.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import Foundation

protocol AIService {
    func sendMessage(_ text: String) async throws -> String
}

final class OpenAIService: AIService {
    func sendMessage(_ text: String) async throws -> String {
        ""
    }

}
