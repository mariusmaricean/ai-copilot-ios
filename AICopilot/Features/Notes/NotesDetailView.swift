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
    @State private var extractedTasks: [ExtractedTask] = []
    @State private var showTaskReview = false
    @State private var showTasks = false
    
    @Query(sort: \Note.createdAt, order: .reverse)
    private var notes: [Note]

    @Query(sort: \TaskItem.createdAt, order: .reverse)
    private var tasks: [TaskItem]

    private let taskExtractionService = TaskExtractionService()
    private let memoryContextBuilder = MemoryContextBuilder()

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
        .sheet(isPresented: $showTaskReview) {
            TaskReviewView(
                extractedTasks: extractedTasks,
                onSave: saveTasks
            )
        }
        .navigationDestination(isPresented: $showTasks) {
            TasksListView()
        }
        .overlay {
            if isExtractingTasks {
                ZStack {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Extracting tasks...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
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
            await extractAndReviewTasks(from: content)
        }
    }

    @MainActor
    private func extractAndReviewTasks(from content: String) async {
        isExtractingTasks = true
        extractionError = nil
        extractedTasks = []

        do {
            let memoryContext = memoryContextBuilder.build(
                notes: notes,
                tasks: tasks
            )

            let suggestedTasks = try await taskExtractionService.extractTasks(
                from: content,
                memoryContext: memoryContext
            )
            
            extractedTasks = suggestedTasks
            showTaskReview = true
        } catch {
            extractionError = "Could not extract tasks. Please try again."
        }

        isExtractingTasks = false
    }
    
    private func saveTasks(_ tasks: [ExtractedTask]) {
        for extractedTask in tasks {
            let task = TaskItem(title: extractedTask.title)
            modelContext.insert(task)
        }

        do {
            try modelContext.save()
            showTasks = true
        } catch {
            extractionError = "Could not save tasks."
        }
    }
}
