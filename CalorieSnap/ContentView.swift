//
//  ContentView.swift
//  CalorieSnap
//
//  Created by Shweta Ambarkhane on 21/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FoodClassifierViewModel()
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            VStack {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                        .overlay(Text("Select or Capture Food Image"))
                        .cornerRadius(12)
                }

                Button("Choose Image") {
                    showImagePicker = true
                }
                .padding()

                if let prediction = viewModel.prediction {
                    VStack(spacing: 10) {
                        Text("Food: \(prediction.label)")
                        Text("Confidence: \(String(format: "%.2f", prediction.confidence * 100))%")
                        Text("Calories: \(prediction.calories) kcal")
                    }
                    .padding()
                }

                Divider()

                Text("Today's Calorie Log")
                    .font(.headline)
                List(viewModel.calorieLog) { item in
                    HStack {
                        Text(item.label)
                        Spacer()
                        Text("\(item.calories) kcal")
                    }
                }

                Text("Total: \(viewModel.totalCalories()) kcal")
                    .bold()
                    .padding()
            }
            .padding()
            .navigationTitle("CalorieSnap")
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(image: $viewModel.selectedImage)
                    .onDisappear {
                        if let image = viewModel.selectedImage {
                            viewModel.classifyImage(image)
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
