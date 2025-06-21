//
//  FoodPrediction.swift
//  CalorieSnap
//
//  Created by Shweta Ambarkhane on 21/06/25.
//

import Foundation

// MARK: - Model Wrapper
struct FoodPrediction: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double
    let calories: Int
}
