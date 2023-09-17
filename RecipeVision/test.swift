//
//  test.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/16/23.
//

import SwiftUI

// 1. Use looped H/VStacks to create a grid
// 2. Conditionally increase spacing to grow/shrink the grid
// 3. Calculate the distance of each dot to the center and use the value to stagger the animation
// 4. Add random delay on top of the staggered delay value
struct ContentView: View {
    
    // const & state
    var dotSize: CGFloat = 4
    var gridWidth: Int = 24
    var gridHeight: Int = 32
    var defaultSpacing: CGFloat = 6
    var targetSpacing: CGFloat = 10
    
    @State var animated: Bool = false
    
    // computed
    var spacing: CGFloat {
        return  animated ? targetSpacing : defaultSpacing
    }
    
    // fn
    // play around with the t argument to speed up or slow down the effect
    func delay(t: Double, row: Int, col: Int) -> Double {
        let centerX = gridWidth / 2
        let centerY = gridHeight / 2
        
        let distance = sqrt(Double((row - centerY) * (row - centerY) + (col - centerX) * (col - centerX)))

        return (distance * Double.random(in: 0.1...0.3)) * t
    }
    
    var body: some View {
        ZStack {
            Color.black
            VStack(spacing: spacing) {
                ForEach(0..<gridHeight, id: \.self) { i in
                    HStack(spacing: spacing) {
                        ForEach(0..<gridWidth, id: \.self) { j in
                            Ellipse()
                                .fill(.white)
                                .frame(width: dotSize, height: dotSize)
                                .opacity(animated ? 0.75 : 0.5)
                                .animation(
                                    .interactiveSpring(
                                        response: 0.5,
                                        dampingFraction: animated ? 0.5 : 0.5)
                                        .delay(delay(t: animated ? 0.35 : -10.0, row: i, col: j)), value: animated
                                )
                        }
                    }
                }
            }
        }
        .gesture(
            // use DragGesture as a hacky "while touch down"
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    animated = true
                }
                .onEnded { _ in
                    animated = false
                }
        )
        .ignoresSafeArea()
    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
