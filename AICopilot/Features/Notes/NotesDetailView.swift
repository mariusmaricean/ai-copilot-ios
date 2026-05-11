//
//  NotesDetailView.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import SwiftUI

struct NoteDetailView: View {
    @Bindable var note: Note
    @State private var chatRoute: ChatRoute?
    
    var body: some View {
        VStack(spacing: 20) {
            titleField
            contentEditor
            copilotActions
        }
        .padding()
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $chatRoute) { route in
            ChatView(initialPrompt: route.prompt)
        }
    }
}

private extension NoteDetailView {
    var titleField: some View {
        TextField("Title", text: $note.title)
            .font(.title2.bold())
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .padding(.bottom, 8)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }
    
    var contentEditor: some View {
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
        }
        .frame(minHeight: 220, maxHeight: 360)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }
    
    var copilotActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Copilot")
                .font(.headline)
            
            HStack(spacing: 12) {
                Button(action: summarizeNote) {
                    Label("Summarize", systemImage: "text.alignleft")
                        .frame(maxWidth: .infinity)
                }

                Button(action: extractTasks) {
                    Label("Extract Tasks", systemImage: "checklist")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }
    
    
    func summarizeNote() {
        let content = note.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        chatRoute = ChatRoute(
            prompt: "Summarize this note:\n\n\(content)")
    }
    
    func extractTasks() {
        let content = note.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        chatRoute = ChatRoute(
            prompt: "Summarize this note:\n\n\(content)")
    }
}

private struct ChatRoute: Identifiable {
    let id = UUID()
    let prompt: String
}
