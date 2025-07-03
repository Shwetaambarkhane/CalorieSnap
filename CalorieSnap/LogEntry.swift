import Foundation
import SwiftData

@Model
class LogEntry {
    var foodName: String
    var calories: Int
    var date: Date

    init(foodName: String, calories: Int, date: Date) {
        self.foodName = foodName
        self.calories = calories
        self.date = date
    }
} 