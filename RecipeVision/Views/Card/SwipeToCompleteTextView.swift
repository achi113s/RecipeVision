//
//  SwipeToCompleteTextView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/18/23.
//

import CoreHaptics
import SwiftUI

struct SwipeToCompleteTextView: View {
    @EnvironmentObject var myHapticEngine: MyHapticEngine
    @Binding private var complete: Bool
    
    @State private var hapticEngine: CHHapticEngine?
    @State private var offset: CGSize = .zero
    
    private var text: String
    private var textColor: Color = .black
    private var strikethroughColor: Color = .black
    
    init(complete: Binding<Bool>, text: String) {
        self._complete = complete
        self.text = text
    }
    
    var swipeToComplete: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                guard dragValue.translation.width > 0 else { return }
                let limit: CGFloat = 100
                let factor = 1 / (dragValue.translation.width / limit + 1)
                self.offset.width = dragValue.translation.width * factor
            }
            .onEnded { dragValue in
                if self.offset.width > 30 {
                    withAnimation(.easeInOut) {
                        complete.toggle()
                        myHapticEngine.playSuccessHaptic()
                    }
                }
                
                withAnimation(.easeInOut) {
                    self.offset.width = .zero
                }
                
            }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .animatableStrikethrough(complete, textColor: textColor, color: strikethroughColor)
                .offset(offset)
                .gesture(
                    swipeToComplete
                )
        }
        // this causes several instances of the haptics engine to be created....
    }
    
    public func textColor(_ color: Color) -> SwipeToCompleteTextView {
        var view = self
        view.textColor = color
        return view
    }
    
    public func strikethroughColor(_ color: Color) -> SwipeToCompleteTextView {
        var view = self
        view.strikethroughColor = color
        return view
    }
}

#Preview {
    SwipeToCompleteTextView(complete: .constant(true), text: "Hello, World!")
}

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
}
