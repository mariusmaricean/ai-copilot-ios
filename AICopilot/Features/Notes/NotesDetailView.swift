//
//  NotesDetailView.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var note: Note

    @FocusState private var isContentFocused: Bool

    @State private var chatRoute: ChatRoute?
    @State private var isExtractingTasks = false
    @State private var extractionError: String?

    private let taskExtractionService = TaskExtractionService()

    private struct ChatRoute: Identifiable {
        let id = UUID()
        let prompt: String
    }

    var body: some View {
        VStack(spacing: 20) {
            titleField
            contentEditor
            copilotActions

            if let extractionError {
                Text(extractionError)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $chatRoute) { route in
            ChatView(initialPrompt: route.prompt)
        }
    }

    private var titleField: some View {
        TextField("Title", text: $note.title)
            .font(.title2.bold())
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var contentEditor: some View {
        ZStack(alignment: .topLeading) {
            if note.content.isEmpty {
                Text("Write your note here...")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
            }

            TextEditor(text: $note.content)
                .font(.body)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .padding(8)
                .focused($isContentFocused)
        }
        .frame(minHeight: 220, maxHeight: 360)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var copilotActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Copilot")
                .font(.headline)

            HStack(spacing: 12) {
                Button(action: summarizeNote) {
                    Label("Summarize", systemImage: "text.alignleft")
                        .frame(maxWidth: .infinity)
                }

                Button(action: extractTasks) {
                    if isExtractingTasks {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Label("Extract Tasks", systemImage: "checklist")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isExtractingTasks)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summarizeNote() {
        isContentFocused = false

        let content = note.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }

        chatRoute = ChatRoute(
            prompt: "Summarize this note:\n\n\(content)"
        )
    }

    private func extractTasks() {
        isContentFocused = false

        let content = note.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }

        Task {
            await extractAndSaveTasks(from: content)
        }
    }

    @MainActor
    private func extractAndSaveTasks(from content: String) async {
        isExtractingTasks = true
        extractionError = nil

        do {
            let extractedTasks = try await taskExtractionService.extractTasks(from: content)

            for extractedTask in extractedTasks {
                let task = TaskItem(title: extractedTask.title)
                modelContext.insert(task)
            }

            try modelContext.save()
        } catch {
            extractionError = "Could not extract tasks. Please try again."
        }

        isExtractingTasks = false
    }
}
