import CoreML
import Vision
import UIKit

class FoodClassifier {
    private var model: VNCoreMLModel?

    init() {
        do {
            let coreMLModel = try SeeFood(configuration: MLModelConfiguration()).model
            model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            print("Failed to load model: \(error)")
        }
    }

    func classify(_ image: UIImage, completion: @escaping (String, Double) -> Void) {
        guard let model = model, let ciImage = CIImage(image: image) else {
            completion("Error", 0.0)
            return
        }
        /*
        
        guard let input = model.preprocess(image: previewImage!) else {
                    print("preprocessing failed")
                    return
        }
                
        guard let result = try? model.prediction(image: input) else {
                    print("prediction failed")
                    return
        }

        let confidence = result.foodConfidence["\(result.classLabel)"]! * 100.0
        
        completion(topResult.identifier, Double(topResult.confidence))
        */

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion("Error", 0.0)
                return
            }

            DispatchQueue.main.async {
                completion(topResult.identifier, Double(topResult.confidence))
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform classification: \(error)")
                DispatchQueue.main.async {
                    completion("Error", 0.0)
                }
            }
        }
    }
} 
