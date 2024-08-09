//
//  NumberDetectViewModel.swift
//  NumberDetector
//
//  Created by jk on 10/08/2024.
//

import SwiftUI
import Vision

class NumberDetectionViewModel: ObservableObject {
    @Published var detectedNumbers: [Int] = []
    @Published var errorMessage: String?
    @Published var isProcessing = false
    
    func detectNumbers(in image: UIImage) {
        isProcessing = true
        errorMessage = nil
        
        guard let cgImage = image.cgImage else {
            errorMessage = "Failed to process the image."
            isProcessing = false
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            defer { self?.isProcessing = false }
            
            if let error = error {
                self?.errorMessage = "Text recognition failed: \(error.localizedDescription)"
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                self?.errorMessage = "No text observed in the image."
                return
            }
            
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            let numbersString = recognizedStrings.joined()
            let numbers = numbersString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Int($0) }
            
            DispatchQueue.main.async {
                self?.detectedNumbers = numbers
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            errorMessage = "Failed to perform recognition: \(error.localizedDescription)"
            isProcessing = false
        }
    }
}
