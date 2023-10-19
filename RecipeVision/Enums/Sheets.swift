//
//  Sheet.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 10/19/23.
//

import Foundation

enum Sheets: String, Identifiable {
    case cameraView, imageROI, ingredients
    var id: String { rawValue }
}
