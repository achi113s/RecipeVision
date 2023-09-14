//
//  Image-Extensions.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/14/23.
//

import SwiftUI

extension Image {
    init(data: Data) {
        self.init(uiImage: UIImage(data: data) ?? UIImage(systemName: "questionmark")!)
    }
}
