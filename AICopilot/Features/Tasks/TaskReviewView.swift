//
//  TaskReviewView.swift
//  AICopilot
//
//  Created by Marius Maricean on 11.05.2026.
//

import SwiftUI

struct TaskReviewView: View {
    let extractedTasks: [ExtractedTask]
    let onSave: ([ExtractedTask]) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var selectedTasks: Set<String> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                ScrollView {
                    VStack(spacing: 20) {
                        header
                        tasksList
                    }
                    .padding()
                }
                
                saveButton
                    .padding()
                    .background(.ultraThinMaterial)
            }
            .navigationTitle("Suggested Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                selectedTasks = Set(extractedTasks.map(\.title))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI extracted the following tasks")
                .font(.headline)

            Text("Review and select which tasks you want to save.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var tasksList: some View {
        VStack(spacing: 12) {
            ForEach(extractedTasks, id: \.title) { task in
                taskRow(task)
            }
        }
    }

    private func taskRow(_ task: ExtractedTask) -> some View {
        Button {
            toggle(task)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected(task)
                      ? "checkmark.circle.fill"
                      : "circle")
                    .font(.title3)

                Text(task.title)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var saveButton: some View {
        Button {
            let tasksToSave = extractedTasks.filter {
                selectedTasks.contains($0.title)
            }

            onSave(tasksToSave)
            dismiss()

        } label: {
            Text(selectedTasks.isEmpty ? "Select Tasks" : "Save \(selectedTasks.count) Tasks")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(selectedTasks.isEmpty)
    }

    private func isSelected(_ task: ExtractedTask) -> Bool {
        selectedTasks.contains(task.title)
    }

    private func toggle(_ task: ExtractedTask) {
        if selectedTasks.contains(task.title) {
            selectedTasks.remove(task.title)
        } else {
            selectedTasks.insert(task.title)
        }
    }
}
