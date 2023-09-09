//
//  MainView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/5/23.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    VStack {
                        Text("Tap the Camera icon to get started!")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("AccentColor"))
                    }
                    .frame(width: geometry.size.width)      // Make the scroll view full-width
                    .frame(minHeight: geometry.size.height) // Set the content’s min height to the parent
                }
            }
        }  // ZStack
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView()
    }
}
