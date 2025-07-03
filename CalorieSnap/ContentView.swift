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
    
    private let classifier = FoodClassifier()

    var body: some View {
        NavigationView {
            VStack {
                Text("CalorieSnap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                        .opacity(selectedImage != nil ? 1 : 0)
                        .animation(.easeIn(duration: 0.5), value: selectedImage)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                        
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .foregroundColor(.gray)
                    }
                    .opacity(selectedImage == nil ? 1 : 0)
                    .animation(.easeIn(duration: 0.5), value: selectedImage)
                }

                HStack(spacing: 20) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Select Image")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .scaleEffect(showingImagePicker ? 1.1 : 1.0)
                    .animation(.spring(), value: showingImagePicker)

                    Button(action: {
                        // Camera action to be implemented
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Take Photo")
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .scaleEffect(showingImagePicker ? 1.0 : 1.1)
                    .animation(.spring(), value: showingImagePicker)
                }
                .padding()

                VStack(spacing: 10) {
                    if prediction != "N/A" {
                        Text("Prediction: \(prediction)")
                            .font(.title2)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .id(prediction)
                    }
                    if confidence > 0 {
                        Text(String(format: "Confidence: %.2f%%", confidence * 100))
                            .font(.subheadline)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .id(confidence)
                    }
                    if calories > 0 {
                        Text("Calories: \(calories) kcal")
                            .font(.subheadline)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .id(calories)
                    }
                }
                .padding()
                .animation(.easeInOut, value: prediction)
                .animation(.easeInOut, value: confidence)
                .animation(.easeInOut, value: calories)

                Button(action: {
                    let newLogEntry = LogEntry(foodName: prediction, calories: calories, date: Date())
                    withAnimation {
                        modelContext.insert(newLogEntry)
                    }
                }) {
                    Text("Log Calories")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .scaleEffect(prediction != "N/A" ? 1.05 : 1.0)
                .opacity(prediction != "N/A" ? 1 : 0.7)
                .animation(.spring(), value: prediction)
                .padding()
                
                Spacer()
                
                NavigationLink(destination: CalorieLogView().transition(.move(edge: .trailing))) {
                    Text("View Log")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 10)
                .animation(.easeInOut, value: prediction)
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $selectedImage)
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Classification Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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