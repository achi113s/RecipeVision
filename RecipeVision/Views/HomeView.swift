//
//  HomeView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/3/23.
//

import CoreHaptics
import PhotosUI
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: ViewModel = ViewModel()
    @StateObject private var recognitionModel: RecognitionModel = RecognitionModel()
    @StateObject private var myHapticEngine: MyHapticEngine = MyHapticEngine()
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    @StateObject private var cards: IngredientCards = IngredientCards()
    
    @State var showProgressView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
//                Color("BackgroundColor")
//                    .edgesIgnoringSafeArea(.all)
                // Use geometry reader to get the size of the ZStack
                // and force ScrollView to take up all that space.
                ScrollView(.vertical) {
                    VStack {
                        if cards.ingredientCards.isEmpty {
                            Text("Tap the camera icon to get started!")
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
//                                .foregroundColor(Color("AccentColor"))
                                .frame(width: .infinity) // Make the scroll view full-width
                                .frame(minHeight: 400) // Set the content’s min height to the parent.
                        } else {
                            LazyVStack(alignment: .center) {
                                ForEach(cards.ingredientCards, id: \.id) { ingredientCard in
                                    CardView(ingredientCard: $cards.ingredientCards[
                                        cards.ingredientCards.firstIndex(of: ingredientCard)!
                                    ])
                                }
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .refreshable {
                    print("refresh")
                }
                
                if recognitionModel.recognitionInProgress {
                    RecognitionInProgressView()
                }
            }  // ZStack
            .toolbar {
                Group {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("RecipeVision")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
//                            .foregroundColor(Color("AccentColor"))
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
//                                .foregroundColor(Color("AccentColor"))
                                .accessibilityLabel("Get an picture of ingredients")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print("camera")
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                }
            }
            .toolbarBackground(Color("ToolbarBackground"), for: .automatic)
            .sheet(isPresented: $viewModel.presentCameraView) {
                CameraView()
            }
            .photosPicker(isPresented: $viewModel.presentPhotosPicker, selection: $selectedPhoto, photoLibrary: .shared())
            // Present the ImageWithROI view after selecting a photo
            // from PhotosPicker
            .onChange(of: selectedPhoto) { newPhoto in
                Task {
                    if let data = try? await newPhoto?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            viewModel.presentImageROI = true
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.presentImageROI) {
                if let image = selectedImage {
                    ImageWithROI(image: image)
                }
            }
            .sheet(isPresented: $recognitionModel.presentNewIngredients) {
                EditIngredientCardView(ingredientCard: recognitionModel.lastIngredientGroupFromChatGPT!)
            }
            .confirmationDialog("", isPresented: $viewModel.presentConfirmationDialog) {
                Button  {
                    viewModel.presentIngredientsView = true
                } label: {
                    Text("Edit Ingredients Card")
                }
            }
            .sheet(isPresented: $viewModel.presentIngredientsView) {
                if let selectedIngredientCard = viewModel.selectedIngredientCard {
                    EditIngredientCardView(ingredientCard: selectedIngredientCard)
                }
            }
        }
        .environmentObject(viewModel)
        .environmentObject(recognitionModel)
        .environmentObject(myHapticEngine)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
