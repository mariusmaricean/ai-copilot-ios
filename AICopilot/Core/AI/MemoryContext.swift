//
//  MemoryContext.swift
//  AICopilot
//
//  Created by Marius Maricean on 12.05.2026.
//


import Foundation

struct MemoryContext {
    let recentNotes: [Note]
    let pendingTasks: [TaskItem]
}

final class MemoryContextBuilder {

    func build(notes: [Note], tasks: [TaskItem]) -> String {
        let recentNotes = notes
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3)

        let pendingTasks = tasks
            .filter { !$0.isCompleted }
            .prefix(5)

        var context = ""

        if !recentNotes.isEmpty {
            context += "Recent Notes:\n"

            for note in recentNotes {
                context += "- \(note.title)\n"
            }

            context += "\n"
        }

        if !pendingTasks.isEmpty {
            context += "Pending Tasks:\n"

            for task in pendingTasks {
                context += "- \(task.title)\n"
            }

            context += "\n"
        }

        return context
    }
}
