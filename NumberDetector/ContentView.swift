//
//  ContentView.swift
//  NumberDetector
//
//  Created by jk on 10/08/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NumberDetectionViewModel()
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
                
                if viewModel.isProcessing {
                    ProgressView()
                } else if !viewModel.detectedNumbers.isEmpty {
                    Text("Detected Numbers: \(viewModel.detectedNumbers.map { String($0) }.joined(separator: ", "))")
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                HStack {
                    Button("Choose Photo") {
                        imageSource = .photoLibrary
                        showingImagePicker = true
                    }
                    Button("Take Photo") {
                        imageSource = .camera
                        showingImagePicker = true
                    }
                }
                .padding()
                
                Button("Detect Numbers") {
                    if let image = image {
                        viewModel.detectNumbers(in: image)
                    }
                }
                .disabled(image == nil || viewModel.isProcessing)
            }
            .navigationTitle("Number Detector")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $image, sourceType: imageSource)
            }
        }
    }
}


#Preview {
    ContentView()
}
