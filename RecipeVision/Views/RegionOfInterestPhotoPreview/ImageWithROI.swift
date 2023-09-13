//
//  ResizableSquare.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/8/23.
//

import SwiftUI

struct ImageWithROI: View {
    var image: Image? = nil
    
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
                newLocation.x = min(max(width / 2, newLocation.x + dragValue.translation.width), (imageSize.width - width / 2))
                newLocation.y = min(max(height / 2, newLocation.y + dragValue.translation.height), (imageSize.height - height / 2))
                self.location = newLocation
            }
            .updating($startLocation) { dragValue, startLocation, transaction in
                startLocation = startLocation ?? location
            }
    }
    
    var resizeDrag: some Gesture {
        DragGesture()
            .onChanged { dragValue in
                self.width = min(max(50, self.width + dragValue.translation.width), imageSize.width)
                self.height = min(max(50, self.height + dragValue.translation.height), imageSize.height)
            }
    }
    
    var body: some View {
        VStack {
            ZStack {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            GeometryReader { geo in
                                Color.clear
                                    .updateImageSizePreferenceKey(geo.size)
                            }
                        }
                }
                
                VStack {
                    // This is the view that's going to be resized by the gesture.
                    GeometryReader { geometry in
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
                    .frame(width: imageSize.width, height: imageSize.height)
                }
            }
            
            Button {
                print(CGRect(origin: CGPoint(x: location.x, y: location.y), size: CGSize(width: width, height: height)))
                print(convertBoundingBoxToNormalizedBoxForVisionROI(boxLocation: location, boxSize: CGSize(width: width, height: height), imageSize: imageSize))
                
            } label: {
                ZStack {
                    Capsule()
                        .foregroundColor(.green.opacity(0.5))
                        .frame(width: 140, height: 50)
                    
                    Text("Use Image")
                }
            }
        }
        .onPreferenceChange(ImageSizePreferenceKey.self) { size in
            imageSize = size
        }
        .padding()
    }
    
    func convertBoundingBoxToNormalizedBoxForVisionROI(boxLocation: CGPoint, boxSize: CGSize, imageSize: CGSize) -> CGRect {
        // Calculate the size of the region of interest normalized to the size of the input image.
        let normalizedWidth = boxSize.width / imageSize.width
        let normalizedHeight = boxSize.height / imageSize.height
        print("normalizedWidth: \(normalizedWidth), normalizedHeight: \(normalizedHeight)")
        
        /*
         Now calculate the x and y coordinate of the region of interest assuming the lower
         left corner is the origin rather than the top left corner of the image.
         The origin of the bounding box is in its center, so we divide width and height by 2 to
         get the location of the lower left corner.
        */
        let newOriginX = boxLocation.x - (boxSize.width / 2)
        let newOriginY = imageSize.height - (boxLocation.y + (boxSize.height / 2))
        print("newOriginX: \(newOriginX), newOriginY: \(newOriginY)")
        
        // Now normalize the new origin to the size of the input image.
        let normalizedOriginX = newOriginX / imageSize.width
        let normalizedOriginY = newOriginY / imageSize.height
        print("normalizedOriginX: \(normalizedOriginX), normalizedOriginY: \(normalizedOriginY)")
        
        let finalROICGRect = CGRect(x: normalizedOriginX, y: normalizedOriginY, width: normalizedWidth, height: normalizedHeight)
        print("final CGRect: \(finalROICGRect)")
        return finalROICGRect
    }
}

struct ImageWithROI_Previews: PreviewProvider {
    static var previews: some View {
        ImageWithROI(image: Image("choonsik"))
    }
}
