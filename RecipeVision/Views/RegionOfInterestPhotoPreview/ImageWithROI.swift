//
//  ResizableSquare.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/8/23.
//

import SwiftUI

struct ImageWithROI: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var recognitionModel: RecognitionModel
    
    @Environment(\.dismiss) var dismiss
    
    var image: UIImage
    
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    @State private var location: CGPoint = .init(x: 200, y: 200)
    @State private var imageSize: CGSize = CGSize(width: 100, height: 100)
    
    @GestureState private var startLocation: CGPoint? = nil
    @GestureState private var startMagnification: CGFloat? = nil
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                var newLocation = startLocation ?? location
                // Set a minimum and maximum constraint on the x and y location
                // such that the bounding box cannot be dragged outside of the image frame.
                newLocation.x = min(max(0, newLocation.x + dragValue.translation.width), (imageSize.width - width))
                newLocation.y = min(max(0, newLocation.y + dragValue.translation.height), (imageSize.height - height))
                self.location = newLocation
            }
            .updating($startLocation) { dragValue, startLocation, transaction in
                startLocation = startLocation ?? location
            }
    }
    
    var resizeDrag: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                // When resizing, we want to constrain the location of the bounding
                // box so that it still cannot go out of the image frame.
                
                // If the box is hitting the left or right edge, only allow making the width
                // smaller (achieved by dragging toward the left).
                if (location.x + width) >= imageSize.width{
                    guard dragValue.translation.width < 0 else { return }
                }
                
                self.width = min(max(50, self.width + dragValue.translation.width), imageSize.width)
                
                // If the box is hitting the top or bottom edge, only allow making the height
                // smaller (achieved by dragging toward the top).
                if (location.y + height) >= imageSize.height {
                    guard dragValue.translation.height < 0 else { return }
                }
                
                self.height = min(max(50, self.height + dragValue.translation.height), imageSize.height)
            }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Drag and resize the yellow box around your ingredients!")
                .multilineTextAlignment(.center)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(Color("AccentColor"))
                .padding(.horizontal)
            
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        GeometryReader { geo in
                            Color.clear
                                .updateImageSizePreferenceKey(geo.size)
                        }
                    }
                
                VStack {
                    // The geometry reader resets the coordinate system so we can get the
                    // location of the bounding box relative to the image.
                    GeometryReader { geometry in
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
                        .position(x: location.x + width / 2, y: location.y + height / 2)
                        .gesture(
                            simpleDrag
                        )
                    }
                    .frame(width: imageSize.width, height: imageSize.height, alignment: .topLeading)
                }
            }
            
            Button {
                print(CGRect(origin: CGPoint(x: location.x, y: location.y), size: CGSize(width: width, height: height)))
                
                let roi = recognitionModel.convertBoundingBoxToNormalizedBoxForVisionROI(boxLocation: location, boxSize: CGSize(width: width, height: height), imageSize: imageSize)
                print(roi)
                
                recognitionModel.recognizeTextInImage(image: image, region: roi)
                
                viewModel.presentCameraView = false
                
                dismiss()
            } label: {
                ZStack {
                    Capsule()
                        .foregroundColor(.green.opacity(0.5))
                        .frame(width: 140, height: 50)
                    
                    HStack (spacing: 5) {
                        Image(systemName: "sparkle.magnifyingglass")
                            .foregroundColor(Color("AccentColor"))
                        Text("Identify")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
        }
        .onPreferenceChange(ImageSizePreferenceKey.self) { size in
            imageSize = size
        }
        .padding()
    }
}

struct ImageWithROI_Previews: PreviewProvider {
    static var previews: some View {
        ImageWithROI(image: UIImage(named: "choonsik")!)
    }
}
