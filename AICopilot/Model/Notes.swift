//
//  Notes.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import Foundation
import SwiftData

@Model
final class Note {
    var title: String
    var content: String
    var createdAt: Date

    init(title: String, content: String = "") {
        self.title = title
        self.content = content
        self.createdAt = Date()
    }
}
