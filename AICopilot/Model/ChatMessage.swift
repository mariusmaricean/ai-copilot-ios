//
//  ChatMessage.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    var content: String

    enum Role {
        case user
        case assistant
    }
}
