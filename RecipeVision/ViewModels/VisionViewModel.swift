//
//  VisionViewModel.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/14/23.
//

import SwiftUI
import Vision

class VisionViewModel: NSObject, ObservableObject {
    @Published var imageToProcess: UIImage? = nil
    @Published var roi: CGRect? = nil
    
    @Published var openAIViewModel = OpenAIViewModel()
    
    public func setImageToProcess(_ image: UIImage, roi: CGRect) {
        imageToProcess = image
        self.roi = roi
        print("set processing image")
        processImage()
    }
    
    public func processImage() {
        guard let imageToProcess = imageToProcess else { return }
        guard let roi = roi else { return }
        guard let cgImage = imageToProcess.cgImage else { return }
        
        print("Current Thread: \(Thread.current)")
        
        let myImageTextRequest = VNImageRequestHandler(cgImage: cgImage, orientation: .right)
        
        // VNRecognizeTextRequest provides text-recognition capabilities.
        // The default is the "accurate" method which does neural-network based text detection and recognition.
        // It is slower but more accurate and since I am not using a live camera feed text recognition this is
        // a good option.
        let request = VNRecognizeTextRequest(completionHandler: addObservationsToList)
        request.recognitionLevel = .accurate
        request.progressHandler = myProgressHandler
        request.regionOfInterest = roi
        
        // For consistency, use revision 3 of the model.
        request.revision = 3
        // Prefer processing in the background.
        request.preferBackgroundProcessing = true
        
        do {
            try myImageTextRequest.perform([request])
        } catch {
            print("Could not perform request: \(error.localizedDescription)")
        }
    }
    
    // Completion handler for the image text recognition request.
    private func addObservationsToList(request: VNRequest, error: Error?) {
        // Retrieve the results of the request, which is an array of VNRecognizedTextObservation objects.
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        print("Current Thread: \(Thread.current). Should not be main.")
        
        let results = observations.compactMap { observation in
            // topCandidates returns an array of the top n candidates as VNRecognizedText objects.
            // Then we use first to get that top candidate.
            // Then we access the string parameter, which is the text as a String type.
            // The resulting type of recognizedStrings is then [String].
            
            // The bounding box is in normalized coordinates, so we need to convert it.
            //            return VNImageRectForNormalizedRect(
            //                observation.boundingBox,
            //                Int(image.size.width),
            //                Int(image.size.height)
            //            )
            
            return (observation.boundingBox, observation.topCandidates(1)[0].string)
        }
        
        let recognizedItems = results.map { result in
            return result.1
        }
        
        // We want to keep all the bounding boxes not just the ones that survive processing.
        let recognizedStringsBoundingBoxes = results.map { result in
            return result.0
        }
        
        print(recognizedItems.joined(separator: " "))
        print(recognizedStringsBoundingBoxes)
        
        let ingredients = recognizedItems.joined(separator: " ")
        
        Task {
            print("getopenaicompletion called")
            let content = """
             Separate this ingredient list into an array of strings of its
             components and output as a JSON object. The JSON object should
             have the following format: {"ingredients": []}.
             Here are the ingredients: \"\(ingredients)\"
            """
            try await openAIViewModel.postMessage(content: content, role: "system", model: Chat.chatgpt.rawValue)
        }
        
        //        DispatchQueue.main.async {
        //            print("Current Thread: \(Thread.current). Should be main.")
        //            recipeItems.recipeItems = recognizedItems
        //            recognizedTextBoundingBoxes = recognizedStringsBoundingBoxes
        //            withAnimation(.easeInOut(duration: 1)) {
        //                requestInProgress = false
        //            }
        //        }
    }
    
    private func myProgressHandler(request: VNRequest, progress: Double, error: Error?) {
        print(progress)
    }
    
    //    private func recognizeIngredientsByLineSpacing(_ observations: [(CGRect, String)]) -> [RecipeItem] {
    //        /* Process the results from the VNRecognizeTextRequest based on the spatial
    //         relationship between the observations. This does not generalize well. In this
    //         case, we will consider the situation where ingredients are wrapped on new lines
    //         and each is separated by a blank new line. Hence, if the spacing between one observation
    //         and the next is small, means those two lines are part of the same ingredient.
    //         */
    //        print("Current Thread: \(Thread.current). Should not be main")
    //        let lineHeightThreshold = 0.8
    //
    //        // Find the maximum and minimum space between observations.
    //        var minSpacing: CGFloat = .infinity  // Presumed to be the line spacing.
    //        var maxSpacing: CGFloat = -.infinity  // Presumed to be the paragraph spacing.
    //        for index in stride(from: 0, to: observations.count - 1, by: 1) {
    //            let firstObservation = observations[index]
    //
    //            if index + 1 < observations.count {
    //                let secondObservation = observations[index + 1]
    //
    //                let verticalSpacing = firstObservation.0.origin.y - secondObservation.0.origin.y
    //
    //                if verticalSpacing < minSpacing { minSpacing = verticalSpacing }
    //                if verticalSpacing >= maxSpacing { maxSpacing = verticalSpacing }
    //            }
    //        }
    //
    ////        print("The minimum space between observations is \(minSpacing).")
    ////        print("The maximum line spacing is \(maxSpacing).")
    //
    //        var groupedObservedStrings = [RecipeItem]()
    //        var buildIngredient = observations[0].1  // Start building on the first observation.
    //
    //        for index in stride(from: 0, to: observations.count - 1, by: 1) {
    //            let firstObservation = observations[index]
    //
    //            // Make sure we don't go out of index bounds.
    //            if index + 1 < observations.count {
    //                let secondObservation = observations[index + 1]
    //
    //                let verticalSpacing = firstObservation.0.origin.y - secondObservation.0.origin.y
    ////                print("The vertical spacing between \(firstObservation.1) and \(secondObservation.1) is \(verticalSpacing).")
    //
    //                // If the spacing between observations is less than lineHeightThreshold times the maximum spacing,
    //                // it's likely this is part of one ingredient.
    //                if verticalSpacing < (maxSpacing * lineHeightThreshold) {
    ////                    print("\(firstObservation.1) and \(secondObservation.1) are part of the same ingredient.")
    //                    buildIngredient = "\(buildIngredient) \(secondObservation.1)"
    ////                    print(buildIngredient)
    //                } else {
    //                    // The buildIngredient will be blank if this is the beginning of an ingredient after
    //                    // a blank line.
    //                    if !buildIngredient.isEmpty {
    //                        let recipeItem = RecipeItem(name: buildIngredient)
    //                        groupedObservedStrings.append(recipeItem)
    //                        buildIngredient = secondObservation.1
    //                    } else {
    //                        let recipeItem = RecipeItem(name: secondObservation.1)
    //                        groupedObservedStrings.append(recipeItem)
    //                    }
    //                }
    //            }
    //        }
    //
    //        if !buildIngredient.isEmpty {
    //            let recipeItem = RecipeItem(name: buildIngredient)
    //            groupedObservedStrings.append(recipeItem)
    //        }
    //
    //        return groupedObservedStrings
    //    }
}
