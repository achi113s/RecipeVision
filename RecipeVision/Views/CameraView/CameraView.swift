//
//  CameraView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/9/23.
//

import SwiftUI

struct CameraView: View {
    @StateObject var model = CameraViewModel()
    
    @State private var currentZoomFactor: CGFloat = 1.0
    @GestureState private var startZooming: CGFloat? = nil
    
    @State private var path = NavigationPath()
    
    var captureButton: some View {
        Button(action: {
            model.capturePhoto()
        }, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
        })
    }
    
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { magValue in
                // Constrain zoom factor between 1x and 2x.
                currentZoomFactor = min(max(magValue.magnitude, 1), 5)
                model.zoom(with: currentZoomFactor)
            }
            .updating($startZooming) { value, startZooming, transaction in
                startZooming = startZooming ?? currentZoomFactor
            }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                ZStack {
                    CameraPreview(session: model.session)
                        .ignoresSafeArea()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .onAppear {
                            model.configure()
                        }
                        .alert(isPresented: $model.showAlertError, content: {
                            Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                                model.alertError.primaryAction?()
                            }))
                        })
                        .overlay(
                            Group {
                                if model.willCapturePhoto {
                                    Color.black
                                }
                            }
                        )
                        .gesture(
                            zoomGesture
                        )
                    
                    VStack {
                        Button(action: {
                            model.switchFlash()
                        }, label: {
                            ZStack {
                                Capsule()
                                    .foregroundStyle(.black)
                                    .frame(width: 75, height: 40)
                                    .opacity(0.3)
                                Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            }
                        })
                        .accentColor(model.isFlashOn ? .yellow : .white)
                        
                        Spacer()
                        
                        HStack {
                            captureButton
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: model.photo) { _ in
                        if model.photo != nil {
                            path.append("PhotoPreview")
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { view in
                if view == "PhotoPreview" {
                    ImageWithROI(image: Image(uiImage: UIImage(data: model.photo.originalData)!))
                }
            }
            .onAppear {
                model.safelyRestartSession()
            }
            .onDisappear {
                model.safelyStopSession()
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
