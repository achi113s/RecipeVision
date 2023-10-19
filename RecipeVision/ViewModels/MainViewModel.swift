//
//  ViewModel.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/16/23.
//

import SwiftUI

class MainViewModel: NSObject, ObservableObject {
    @Published var path = NavigationPath()
    
    @Published var sheet: Sheets?
    
    @Published var presentPhotosPicker: Bool = false
    @Published var presentRecognitionInProgress: Bool = false
    @Published var presentConfirmationDialog: Bool = false
    
    @Published var selectedIngredientCard: IngredientCard?
}
