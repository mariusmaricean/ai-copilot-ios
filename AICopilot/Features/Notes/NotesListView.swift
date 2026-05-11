//
//  NotesListView.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import SwiftUI
import SwiftData

struct NotesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]

    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    NavigationLink {
                        NoteDetailView(note: note)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title)
                                .font(.headline)

                            Text(note.content.isEmpty ? "No content yet" : note.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("AI Copilot")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        TasksListView()
                    } label: {
                        Image(systemName: "checklist")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addNote()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func addNote() {
        let note = Note(
            title: "New Note",
            content: ""
        )
        modelContext.insert(note)
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(notes[index])
        }
    }
}
