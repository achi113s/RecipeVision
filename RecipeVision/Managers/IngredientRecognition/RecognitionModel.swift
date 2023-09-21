//
//  RecognitionModel.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/20/23.
//

import SwiftUI

/*
 This class manages calls to Vision for image-to-text
 recognition and also sends the output to ChatGPT
 for analysis and formatting.
*/
class RecognitionModel: ObservableObject {
    @Published private var visionModel: VisionViewModel = VisionViewModel()
    @Published private var openAIModel: OpenAIViewModel = OpenAIViewModel()
    
    @Published var lastResponse: DecodedIngredients? = nil
    
    public func recognizeTextInImage(image: UIImage, region: CGRect) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.visionModel.performImageToTextRecognition(on: image, inRegion: region)
        }
    }
}
