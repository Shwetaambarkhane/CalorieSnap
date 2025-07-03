import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var prediction = "N/A"
    @State private var confidence: Double = 0.0
    @State private var calories: Int = 0
    @State private var showingImagePicker = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var logEntries: [LogEntry]
    
    private let classifier = FoodClassifier()
    let dailyGoal = 2000
    var todayRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!.addingTimeInterval(-1)
        return start...end
    }
    var todaysCalories: Int {
        logEntries.filter { todayRange.contains($0.date) }.reduce(0) { $0 + $1.calories }
    }
    var progress: Double { min(Double(todaysCalories) / Double(dailyGoal), 1.0) }

    var body: some View {
        TabView {
            // Home Tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 16)
                        ProgressCircle(progress: progress, label: "Calorie Snap", accentColor: .purple)
                            .padding(.top, 16)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Calorie Snap")
                                .font(.headline)
                            NavigationLink(destination: CalorieLogView()) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                                    .frame(height: 100)
                                    .overlay(
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Today's Calories")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                Text("\(todaysCalories) kcal")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                            }
                                            Spacer()
                                            Image(systemName: "chart.bar.xaxis")
                                                .font(.system(size: 36))
                                                .foregroundColor(.purple)
                                        }
                                        .padding()
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        Spacer(minLength: 32)
                    }
                }
                .padding()
                .navigationTitle("")
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            // Log Calories Tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 16)
                        Button(action: {
                            withAnimation(.spring()) {
                                showingImagePicker = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                Text("Scan Food")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.purple.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        // Image viewer
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                        // Food name and confidence section
                        if prediction != "N/A" || confidence > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                if prediction != "N/A" {
                                    HStack {
                                        Image(systemName: "fork.knife")
                                            .foregroundColor(.purple)
                                        Text(prediction)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                }
                                if confidence > 0 {
                                    HStack {
                                        Image(systemName: "percent")
                                            .foregroundColor(.purple)
                                        Text(String(format: "Confidence: %.2f%%", confidence * 100))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .shadow(color: Color.purple.opacity(0.07), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        // Log these calories button
                        if prediction != "N/A" && calories > 0 {
                            Button(action: {
                                let newLogEntry = LogEntry(foodName: prediction, calories: calories, date: Date())
                                withAnimation(.spring()) {
                                    modelContext.insert(newLogEntry)
                                }
                            }) {
                                Text("Log these calories")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                        }
                        Spacer(minLength: 32)
                    }
                }
                .padding()
                .navigationTitle("")
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: $selectedImage)
                }
                .alert(isPresented: $showingErrorAlert) {
                    Alert(title: Text("Classification Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("Log Calories")
            }
        }
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        
        classifier.classify(selectedImage) { result, confidence in
            print("Raw prediction: \(result)")
            if result == "Error" {
                self.errorMessage = "Failed to classify the image. Please try again."
                self.showingErrorAlert = true
                return
            }
            self.prediction = result
            self.confidence = confidence
            self.calories = CalorieService.shared.getCalories(for: result) ?? 0
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
