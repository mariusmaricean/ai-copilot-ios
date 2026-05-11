//
//  OpenAIService.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import Foundation

protocol AIService {
    func streamResponse(for prompt: String) -> AsyncThrowingStream<String, Error>
}

final class OpenAIService: AIService {
    private let apiKey: String
    private let session: URLSession

    init(
        apiKey: String = Secrets.openAIAPIKey,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.session = session
    }

    func streamResponse(for prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    let body: [String: Any] = [
                        "model": "gpt-4.1-mini",
                        "input": prompt,
                        "stream": true
                    ]

                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await session.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        throw URLError(.badServerResponse)
                    }

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }

                        let jsonString = String(line.dropFirst(6))

                        if jsonString == "[DONE]" {
                            continuation.finish()
                            return
                        }

                        if let delta = Self.extractTextDelta(from: jsonString) {
                            continuation.yield(delta)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private static func extractTextDelta(from jsonString: String) -> String? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String,
              type == "response.output_text.delta",
              let delta = json["delta"] as? String else {
            return nil
        }

        return delta
    }
}
