//
//  VisionViewModel.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/14/23.
//

import SwiftUI
import Vision

class VisionViewModel: NSObject, ObservableObject {
    @Published var recognitionProgress: CGFloat = 0.0
    @Published var lastResults: [String] = []
    
    public func performImageToTextRecognition(
        on image: UIImage, 
        inRegion region: CGRect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)) {
            guard let cgImage = image.cgImage else { return }
            
            print("Current Thread: \(Thread.current)")
            
            let myImageTextRequest = VNImageRequestHandler(cgImage: cgImage, orientation: .right)
            
            /*
             VNRecognizeTextRequest provides text-recognition capabilities.
             The default is the "accurate" method which does neural-network based text detection and recognition.
             It is slower but more accurate.
             */
            let request = VNRecognizeTextRequest(completionHandler: formatObservations)
            request.recognitionLevel = .accurate
            request.progressHandler = myProgressHandler
            request.regionOfInterest = region
            
            // For consistency, use revision 3 of the model.
            request.revision = 3
            // Prefer processing in the background.
            request.preferBackgroundProcessing = true
            
            
            do {
                try myImageTextRequest.perform([request])
            } catch {
                print("Something went wrong: \(error.localizedDescription)")
            }
    }
    
    // Completion handler for the image text recognition request.
    // Process the response and return an array of the results.
    private func formatObservations(request: VNRequest, error: Error?) {
        // Retrieve the results of the request, which is an array of VNRecognizedTextObservation objects.
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        print("Current Thread: \(Thread.current). Should not be main.")
        
        let results = observations.compactMap { observation in
            // topCandidates returns an array of the top n candidates as VNRecognizedText objects.
            // Then we use first to get that top candidate.
            // Then we access the string parameter, which is the text as a String type.
            // The resulting type of recognizedStrings is then [String].

            return observation.topCandidates(1)[0].string
        }
        
        lastResults = results
        
        // this shouldn't be in this class
        //        Task {
        //            print("getopenaicompletion called")
        //            let content = """
        //             Separate this ingredient list into an array of strings of its
        //             components and output as a JSON object. The JSON object should
        //             have the following format: {"ingredients": []}.
        //             Here are the ingredients: \"\(ingredients)\"
        //            """
        //            try await openAIViewModel.postMessage(content: content, role: "system", model: Chat.chatgpt.rawValue)
        //        }
    }
    
    private func myProgressHandler(request: VNRequest, progress: Double, error: Error?) {
        print(progress)
    }
}
