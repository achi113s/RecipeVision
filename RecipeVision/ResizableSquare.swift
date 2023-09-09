//
//  ResizableSquare.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/8/23.
//

import SwiftUI

struct ResizableSquare: View {
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    @State private var location: CGPoint = .init(x: 50, y: 50)
    @State private var magnification: CGFloat = 1.0
    
    @State private var circleDiam: CGFloat = 25
    
    @GestureState private var startLocation: CGPoint? = nil
    @GestureState private var startMagnification: CGFloat? = nil
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                var newLocation = startLocation ?? location
                newLocation.x += dragValue.translation.width
                newLocation.y += dragValue.translation.height
                self.location = newLocation
            }
            .updating($startLocation) { dragValue, startLocation, transaction in
                startLocation = startLocation ?? location
            }
    }
    
    var magnificationEffect: some Gesture {
        MagnificationGesture()
            .onChanged { magValue in
                magnification = magValue.magnitude
            }
            .updating($startMagnification) { value, startMagnification, transaction in
                startMagnification = startMagnification ?? magnification
            }
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                Rectangle()
                    .stroke(style: .init(lineWidth: 2, dash: [5]))
                    .fill(Color.yellow)
                    .contentShape(Rectangle())
                    .frame(width: self.width * magnification, height: self.height * magnification)
                    .position(self.location)
                    .gesture(
                        simpleDrag
                    )
                    .gesture(
                        magnificationEffect
                    )
            }
        }
    }
}

struct ResizableSquare_Previews: PreviewProvider {
    static var previews: some View {
        ResizableSquare()
    }
}
