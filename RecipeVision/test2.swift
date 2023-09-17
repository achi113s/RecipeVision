//
//  test2.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/17/23.
//

import SwiftUI

struct test2: View {
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    var body: some View {
        VStack { // <-- Wrapping VStack with alignment modifier
            // This is the view that's going to be resized.
            ZStack(alignment: .bottomTrailing) {
                Text("Hello, world!")
                    .frame(width: width, height: height)
                // This is the "drag handle" positioned on the lower-left corner of this stack.
                Text("")
                    .frame(width: 30, height: 30)
                    .background(.red)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Enforce minimum dimensions.
                                width = max(100, width + value.translation.width)
                                height = max(100, height + value.translation.height)
                            }
                    )
            }
            .frame(width: width, height: height, alignment: .topLeading)
            .border(.red, width: 5)
            .background(.yellow)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct test2_Previews: PreviewProvider {
    static var previews: some View {
        test2()
    }
}
