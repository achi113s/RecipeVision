//
//  FrameView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/7/23.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    var error: Error?
    private let label = Text("Camera Feed")
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if let image = image {
                GeometryReader { geometry in
                    Image(image, scale: 1.0, orientation: .upMirrored, label: label)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            alignment: .center
                        )
                        .clipped()
                }
            } else {
                Color.black
            }
            
            VStack {
                if let error = error {
                    ErrorView(error: error)
                }
                
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Capsule()
                                .frame(width: 75, height: 50)
                                .foregroundColor(Color("BackgroundColor"))
                            Text("Exit")
                                .foregroundColor(Color("AccentColor"))
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                        }
                    }
                }
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))
                
                Spacer()
                
                Button {
                    print("snap pic")
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 75, height: 75)
                }

            }
            .padding(.bottom, 50)
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        FrameView()
    }
}
