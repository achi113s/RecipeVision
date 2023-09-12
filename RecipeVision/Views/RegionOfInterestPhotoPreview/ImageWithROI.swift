//
//  ResizableSquare.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/8/23.
//

import SwiftUI

struct ImageWithROI: View {
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    @State private var location: CGPoint = .init(x: 200, y: 200)
    
    @GestureState private var startLocation: CGPoint? = nil
    @GestureState private var startMagnification: CGFloat? = nil
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                var newLocation = startLocation ?? location
                newLocation.x = newLocation.x + dragValue.translation.width
                newLocation.y = newLocation.y + dragValue.translation.height
                self.location = newLocation
            }
            .updating($startLocation) { dragValue, startLocation, transaction in
                startLocation = startLocation ?? location
            }
    }
    
    var resizeDrag: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                self.width = min(max(100, self.width + dragValue.translation.width), 400)
                self.height = min(max(100, self.height + dragValue.translation.height), 400)
            }
    }
    
    var body: some View {
        ZStack {
            Image("choonsik")
                .resizable()
                .scaledToFit()
            
            VStack {
                // This is the view that's going to be resized by the gesture.
                ZStack(alignment: .bottomTrailing) {
                    Rectangle()
                        .stroke(style: .init(lineWidth: 2, dash: [5]))
                        .fill(.yellow)
                        .contentShape(Rectangle())
                        .frame(width: width, height: height)
                    // This is the "drag handle" positioned on the lower-left corner of this stack.
                    Rectangle()
                        .fill(.yellow)
                        .frame(width: 30, height: 30)
                        .gesture(
                            resizeDrag
                        )
                }
                .frame(width: width, height: height, alignment: .topLeading)
                .padding()
                .position(x: location.x, y: location.y)
                .gesture(
                    simpleDrag
                )
            }
            .frame(width: 430, height: 430)
        }
    }
}

struct ImageWithROI_Previews: PreviewProvider {
    static var previews: some View {
        ImageWithROI()
    }
}
