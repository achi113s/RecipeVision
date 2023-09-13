//
//  ImagePreferenceKey.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/13/23.
//

import SwiftUI

struct ImageSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = CGSize(width: 150, height: 150)
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    public func updateImageSizePreferenceKey(_ size: CGSize) -> some View {
        preference(key: ImageSizePreferenceKey.self, value: size)
    }
}
