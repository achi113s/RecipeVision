//
//  CameraView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/9/23.
//

import SwiftUI

struct CameraView: View {
    @ObservedObject var viewModel: ViewModel
    @StateObject var cameraModel = CameraViewModel()
    @EnvironmentObject var visionModel: VisionViewModel
    
    @State private var currentZoomFactor: CGFloat = 1.0
    @State private var lastZoomFactor: CGFloat = 1.0
    @GestureState private var startZooming: CGFloat? = nil
    @State private var shouldShowMagnificationProgress: Bool = false
    
    @State private var path = NavigationPath()
    
    var captureButton: some View {
        Button(action: {
            cameraModel.capturePhoto()
        }, label: {
            Circle()
                .foregroundColor(Color("AccentColor"))
                .frame(width: 80, height: 80, alignment: .center)
        })
    }
    
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { magValue in
                // Constrain zoom factor between 1x and 5x.
                currentZoomFactor = min(max(lastZoomFactor * magValue, 1), 5)
                cameraModel.zoom(with: currentZoomFactor)
                withAnimation {
                    shouldShowMagnificationProgress = currentZoomFactor > 1
                }
            }
            .onEnded { value in
                lastZoomFactor = currentZoomFactor
            }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                ZStack {
                    CameraPreview(session: cameraModel.session)
                        .ignoresSafeArea()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .onAppear {
                            cameraModel.configure()
                        }
                        .alert(isPresented: $cameraModel.showAlertError, content: {
                            Alert(title: Text(cameraModel.alertError.title), message: Text(cameraModel.alertError.message), dismissButton: .default(Text(cameraModel.alertError.primaryButtonTitle), action: {
                                cameraModel.alertError.primaryAction?()
                            }))
                        })
                        .overlay(
                            Group {
                                if cameraModel.willCapturePhoto {
                                    Color.black
                                }
                            }
                        )
                        .gesture(
                            zoomGesture
                        )
                    
                    VStack {
                        Button(action: {
                            cameraModel.switchFlash()
                        }, label: {
                            ZStack {
                                Capsule()
                                    .foregroundStyle(.black)
                                    .frame(width: 75, height: 40)
                                    .opacity(0.3)
                                Image(systemName: cameraModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            }
                        })
                        .accentColor(cameraModel.isFlashOn ? .yellow : .white)
                        
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("-")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                                
                                ProgressView(value: currentZoomFactor - 1, total: CGFloat(4))
                                    .tint(.yellow)
                                    .offset(y: 2)
                                
                                Text("+")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                            }
                            .padding(EdgeInsets(top: 0, leading: 25, bottom: 25, trailing: 25))
                            .opacity(shouldShowMagnificationProgress ? 1.0 : 0.0)
                            
                            HStack {
                                captureButton
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: cameraModel.photo) { _ in
                        if cameraModel.photo != nil {
                            path.append("PhotoPreview")
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { view in
                if view == "PhotoPreview" {
//                    ImageWithROI(viewModel: viewModel, image: Image(uiImage: UIImage(data: cameraModel.photo.originalData)!))
                    ImageWithROI(viewModel: viewModel, image: UIImage(data: cameraModel.photo.originalData)!)
                }
            }
            .onAppear {
                cameraModel.safelyRestartSession()
            }
            .onDisappear {
                cameraModel.safelyStopSession()
            }
        }
    }
}

//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView()
//    }
//}
