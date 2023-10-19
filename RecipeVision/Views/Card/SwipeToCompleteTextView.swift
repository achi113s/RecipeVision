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
    
    /*
     Monitor the progress of the drag to perform
     the strikethrough animation as you drag.
     */
    @State private var progress: CGFloat = 0.0
    
    @State private var offset: CGSize = .zero
    
    private var text: String
    @State private var textColor: Color = .black
    private var strikethroughColor: Color = .black
    
    init(complete: Binding<Bool>, text: String) {
        self._complete = complete
        self.text = text
    }
    
    var swipeToComplete: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                // Can only drag left to right.
                guard dragValue.translation.width > 0 else { return }
                
                // Drag with resistance.
                // Asymptotically limits drag offset.
                let limit: CGFloat = 100
                let factor = 1 / (dragValue.translation.width / limit + 1)
                self.offset.width = dragValue.translation.width * factor
                
                if !self.complete {
                    self.progress = self.offset.width / limit
                }
            }
            .onEnded { dragValue in
                // If full drag was completed, toggle complete and
                // set strikethrough accoordingly.
                if self.offset.width > 50 {
                    withAnimation(.easeInOut) {
                        complete.toggle()
                        
                        if self.complete {
                            self.progress = 1.0
                        } else {
                            self.progress = 0.0
                        }
                        
                        myHapticEngine.playHaptic(.simpleSuccess)
                    }
                } else {
                    /*
                     If the full drag wasn't completed and the item
                     is not completed, set strikethrough progress
                     back to zero.
                     */
                    if !complete {
                        withAnimation(.easeInOut) {
                            self.progress = 0.0
                        }
                    }
                }
                
                // Always return the text back to its original
                // location.
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.offset.width = .zero
                }
            }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .animatableStrikethroughProgressive(progress, textColor: textColor, color: strikethroughColor)
                .offset(offset)
                .gesture(
                    swipeToComplete
                )
        }
        // this causes several instances of the haptics engine to be created....
    }
    
    public func textColor(_ color: Color) -> SwipeToCompleteTextView {
        let view = self
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
