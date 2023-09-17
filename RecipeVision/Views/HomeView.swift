//
//  HomeView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/3/23.
//

import PhotosUI
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: ViewModel = ViewModel()
    @StateObject private var visionModel: VisionViewModel = VisionViewModel()
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                ContentIsEmptyView()
            }
            .toolbar {
                Group {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("RecipeVision")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("AccentColor"))
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                viewModel.presentCameraView = true
                            } label: {
                                HStack {
                                    Text("Take a Picture")
                                    Image(systemName: "camera")
                                }
                            }

                            Button {
                                viewModel.presentPhotosPicker = true
                            } label: {
                                HStack {
                                    Text("Select from Photos")
                                    Image(systemName: "photo.stack")
                                }
                            }
                        } label: {
                            Image(systemName: "camera.on.rectangle")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("AccentColor"))
                                .accessibilityLabel("Get an picture of ingredients")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print("camera")
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                }
            }
            .toolbarBackground(Color("ToolbarBackground"), for: .automatic)
            .sheet(isPresented: $viewModel.presentCameraView) {
                CameraView(viewModel: viewModel)
            }
            .photosPicker(isPresented: $viewModel.presentPhotosPicker, selection: $selectedPhoto, photoLibrary: .shared())
            .onChange(of: selectedPhoto) { newPhoto in
                Task {
                    if let data = try? await newPhoto?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
//                            let image = Image(uiImage: uiImage)
                            selectedImage = uiImage
                            viewModel.presentImageROI = true
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.presentImageROI) {
                ImageWithROI(viewModel: viewModel, image: selectedImage!)
            }
        }
        .environmentObject(visionModel)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
