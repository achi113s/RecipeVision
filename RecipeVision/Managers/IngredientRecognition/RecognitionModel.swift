//
//  RecognitionModel.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/20/23.
//

import SwiftUI
import Vision

/*
 This class manages calls to Vision for image-to-text
 recognition and also sends the output to ChatGPT
 for analysis and formatting.
*/
@MainActor class RecognitionModel: ObservableObject {
//    private var visionModel: VisionViewModel = VisionViewModel()
//    private var openAIModel: OpenAIViewModel = OpenAIViewModel()
    
    @Published var recognitionProgress: CGFloat = 0.0 {
        didSet {
            print("Recognition in Progress: \(recognitionProgress)")
        }
    }
    
    @Published var recognitionInProgress: Bool = false {
        didSet{
            print("Recognition is in Progress: \(recognitionInProgress)")
        }
    }
    
    @Published var lastResultsFromVision: [String] = []
    @Published var lastResponseFromChatGPT: DecodedIngredients? = nil
}

//MARK: - Vision Image-to-Text Recognition Handlers
extension RecognitionModel {
    public func recognizeTextInImage(image: UIImage, region: CGRect) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.performImageToTextRecognition(on: image, inRegion: region)
        }
    }
    
    // This will be performed on a background thread.
    private func performImageToTextRecognition(on image: UIImage,
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
            self.recognitionInProgress = true
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
        
        DispatchQueue.main.async { [weak self] in
            self?.lastResultsFromVision = results
            self?.recognitionInProgress = false
        }
        
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
        DispatchQueue.main.async { [weak self] in
            self?.recognitionProgress = CGFloat(progress)
        }
    }
    
    public func convertBoundingBoxToNormalizedBoxForVisionROI(boxLocation: CGPoint, boxSize: CGSize, imageSize: CGSize) -> CGRect {
        // Calculate the size of the region of interest normalized to the size of the input image.
        let normalizedWidth = boxSize.width / imageSize.width
        let normalizedHeight = boxSize.height / imageSize.height
        print("normalizedWidth: \(normalizedWidth), normalizedHeight: \(normalizedHeight)")
        
        /*
         Now calculate the x and y coordinate of the region of interest assuming the lower
         left corner is the origin rather than the top left corner of the image.
         The origin of the bounding box is in its top leading corner. So the x
         is the same for the unnormalized and normalized regions.
         For y, we need to calculate the
         normalized coordinate of the lower left corner.
         */
        let newOriginX = max(boxLocation.x, 0)
        let newOriginY = max(imageSize.height - (boxLocation.y + boxSize.height), 0)
        print("newOriginX: \(newOriginX), newOriginY: \(newOriginY)")
        
        // Now normalize the new origin to the size of the input image.
        let normalizedOriginX = newOriginX / imageSize.width
        let normalizedOriginY = newOriginY / imageSize.height
        print("normalizedOriginX: \(normalizedOriginX), normalizedOriginY: \(normalizedOriginY)")
        
        let finalROICGRect = CGRect(x: normalizedOriginX, y: normalizedOriginY, width: normalizedWidth, height: normalizedHeight)
        print("final CGRect: \(finalROICGRect)")
        return finalROICGRect
    }
}
