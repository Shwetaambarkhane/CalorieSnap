//
//  FoodClassifierViewModel.swift
//  CalorieSnap
//
//  Created by Shweta Ambarkhane on 21/06/25.
//

import Foundation
import Vision
import CoreML
import UIKit

// MARK: - ViewModel
class FoodClassifierViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var prediction: FoodPrediction?
    @Published var calorieLog: [FoodPrediction] = []

    private var model: VNCoreMLModel
    private let calorieDatabase: [String: Int] = [
        "Pizza": 285,
        "Burger": 354,
        "Pasta": 221,
        "Salad": 152,
        "Fries": 365,
        "Apple": 95
        // Add more as per your model classes
    ]

    init() {
        guard let modelURL = Bundle.main.url(forResource: "CalorieModel", withExtension: "mlmodelc"),
              let compiledModel = try? MLModel(contentsOf: modelURL) else {
            fatalError("Model loading failed")
        }
        model = try! VNCoreMLModel(for: compiledModel)
    }

    func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }

        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else { return }

            let food = topResult.identifier
            let confidence = Double(topResult.confidence)
            let calories = self?.calorieDatabase[food] ?? 0

            DispatchQueue.main.async {
                let prediction = FoodPrediction(label: food, confidence: confidence, calories: calories)
                self?.prediction = prediction
                self?.logCalorie(prediction)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }

    func logCalorie(_ prediction: FoodPrediction) {
        calorieLog.append(prediction)
    }

    func totalCalories() -> Int {
        calorieLog.reduce(0) { $0 + $1.calories }
    }
}
