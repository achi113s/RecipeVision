//
//  ViewModel.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/16/23.
//

import SwiftUI

class ViewModel: NSObject, ObservableObject {
    @Published var path = NavigationPath()
    
    @Published var presentCameraView: Bool = false
    @Published var presentPhotosPicker: Bool = false
    @Published var presentImageROI: Bool = false
    @Published var presentRecognitionInProgress: Bool = false
    @Published var presentConfirmationDialog: Bool = false
    @Published var presentIngredientsView: Bool = false
    
    @Published var selectedIngredientCard: IngredientCard?
}
