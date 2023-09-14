//
//  VisionViewModel.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/14/23.
//

import SwiftUI

class VisionViewModel: NSObject, ObservableObject {
    @Published var imageToProcess: Image? = nil
    
    public func setImageToProcess(_ image: Image) {
        imageToProcess = image
        print("set processing image")
    }
}
