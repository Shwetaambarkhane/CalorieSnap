import SwiftUI
import SwiftData

struct CalorieLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LogEntry.date, order: .reverse) private var logEntries: [LogEntry]

    var body: some View {
        List {
            ForEach(logEntries) { entry in
                HStack {
                    Text(entry.foodName.capitalized)
                    Spacer()
                    Text("\(entry.calories) kcal")
                }
                .transition(.slide.combined(with: .opacity))
            }
            .onDelete(perform: deleteEntries)
        }
        .animation(.easeInOut, value: logEntries)
        .navigationTitle("Today's Log")
        .toolbar {
            EditButton()
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        withAnimation(.easeInOut) {
            for offset in offsets {
                let entry = logEntries[offset]
                modelContext.delete(entry)
            }
        }
    }
}

struct CalorieLogView_Previews: PreviewProvider {
    static var previews: some View {
        // This preview will be empty as it doesn't have a model context by default.
        // For a more complete preview, you would set up an in-memory SwiftData container.
        CalorieLogView()
    }
} 
