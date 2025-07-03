import Foundation

class CalorieService {
    static let shared = CalorieService()
    private var calorieData: [String: Int] = [:]

    private init() {
        loadCalorieData()
    }

    private func loadCalorieData() {
        guard let path = Bundle.main.path(forResource: "calories", ofType: "csv") else {
            print("calories.csv not found")
            return
        }
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let rows = content.components(separatedBy: "\n")

            for (index, row) in rows.enumerated() {
                if index == 0 { continue } // Skip header
                let columns = row.components(separatedBy: ",")
                if columns.count > 3 {
                    let foodName = columns[1].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    let calsString = columns[3].replacingOccurrences(of: " cal", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if let cals = Int(calsString) {
                        calorieData[foodName] = cals
                    }
                }
            }
        } catch {
            print("Error reading calories.csv: \(error)")
        }
    }

    func getCalories(for foodName: String) -> Int? {
        let cleanedFoodName = foodName.replacingOccurrences(of: ",.*", with: "", options: .regularExpression)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "_", with: " ") // Also match spaces
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        // Direct lookup
        if let calories = calorieData[cleanedFoodName] {
            return calories
        }
        
        // Fallback for partial matches (e.g., "Granny Smith Apples" -> "apple")
        let components = cleanedFoodName.components(separatedBy: " ")
        for component in components.reversed() {
            if let calories = calorieData[component] {
                return calories
            }
        }
        
        return nil
    }
} 