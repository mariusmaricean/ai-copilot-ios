//
//  AICopilotApp.swift
//  AICopilot
//
//  Created by Marius Maricean on 06.05.2026.
//

import SwiftUI
import SwiftData

@main
struct AICopilotApp: App {
    var body: some Scene {
        WindowGroup {
            NotesListView()
        }
        .modelContainer(for: [Note.self,TaskItem.self])
    }
}
