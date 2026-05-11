//
//  TasksListView.swift
//  AICopilot
//
//  Created by Marius Maricean on 11.05.2026.
//

import SwiftUI
import SwiftData

struct TasksListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]

    var body: some View {
        List {
            if tasks.isEmpty {
                ContentUnavailableView( 
                    "No Tasks Yet",
                    systemImage: "checklist",
                    description: Text("Extract tasks from a note to see them here.")
                )
            } else {
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                }
                .onDelete(perform: deleteTasks)
            }
        }
        .navigationTitle("Tasks")
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
}
