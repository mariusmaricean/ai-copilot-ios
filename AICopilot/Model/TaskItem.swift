//
//  Task.swift
//  AICopilot
//
//  Created by Marius Maricean on 11.05.2026.
//

import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    init(
        title: String,
        isCompleted: Bool = false
    ) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}

struct ExtractedTask: Decodable {
    let title: String
}
