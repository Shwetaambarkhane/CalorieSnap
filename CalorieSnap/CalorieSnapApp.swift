import SwiftUI
import SwiftData

@main
struct CalorieSnapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: LogEntry.self)
    }
} 