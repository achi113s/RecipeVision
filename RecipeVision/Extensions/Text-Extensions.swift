//
//  Text-Extensions.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/19/23.
//

import SwiftUI

extension Text {
    func animatableStrikethrough(_ isActive: Bool = true,
                                 pattern: Text.LineStyle.Pattern = .solid,
                                 textColor: Color? = nil,
                                 color: Color? = nil) -> some View {
        self
            .foregroundColor(textColor)
            .overlay(alignment:.leading) {
                self
                    .foregroundColor(.clear)
                    .strikethrough(isActive, color: color)
                    .scaleEffect(x: isActive ? 1 : 0, anchor: .leading)
            }
    }
    
    func animatableStrikethroughProgressive(_ progress: CGFloat = 0,
                                 pattern: Text.LineStyle.Pattern = .solid,
                                 textColor: Color? = nil,
                                 color: Color? = nil) -> some View {
        self
            .foregroundColor(textColor)
            .overlay(alignment:.leading) {
                self
                    .foregroundColor(.clear)
                    .strikethrough(true, color: color)
                    .scaleEffect(x: progress, anchor: .leading)
            }
    }
}

