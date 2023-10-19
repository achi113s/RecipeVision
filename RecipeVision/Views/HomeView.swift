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
    @StateObject private var mainViewModel: MainViewModel = MainViewModel()
    @StateObject private var textRecognitionModel: IngredientRecognitionHandler = IngredientRecognitionHandler()
    @StateObject private var myHapticEngine: MyHapticEngine = MyHapticEngine()
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    @StateObject private var cards: IngredientCards = IngredientCards()
    
    @State var showProgressView: Bool = false
    
    var body: some View {
        NavigationStack(path: $mainViewModel.path) {
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
                                .frame(width: 300) // Make the scroll view full-width
                                .frame(minHeight: 600) // Set the content’s min height to the parent.
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
                
                if textRecognitionModel.recognitionInProgress {
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
                                mainViewModel.sheet = .cameraView
                            } label: {
                                HStack {
                                    Text("Take a Picture")
                                    Image(systemName: "camera")
                                }
                            }
                            
                            Button {
                                mainViewModel.presentPhotosPicker = true
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
                            mainViewModel.path.append("Settings")
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                }
            }
//            .toolbarBackground(Color("ToolbarBackground"), for: .automatic)
            .navigationDestination(for: String.self) { destination in
                if destination == "Settings" {
                    SettingsView(path: $mainViewModel.path)
                }
            }
            .sheet(item: $mainViewModel.sheet, content: makeSheet)
            .sheet(isPresented: $textRecognitionModel.presentNewIngredients) {
                EditIngredientCardView(ingredientCard: textRecognitionModel.lastIngredientGroupFromChatGPT)
            }
            // Present the ImageWithROI view after selecting a photo
            // from PhotosPicker
            .photosPicker(isPresented: $mainViewModel.presentPhotosPicker,
                          selection: $selectedPhoto, photoLibrary: .shared())
            .onChange(of: selectedPhoto) { newPhoto in
                Task {
                    if let data = try? await newPhoto?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            mainViewModel.sheet = .imageROI
                        }
                    }
                }
            }
            .confirmationDialog("", isPresented: $mainViewModel.presentConfirmationDialog) {
                Button  {
                    mainViewModel.sheet = .ingredients
                } label: {
                    Text("Edit Ingredients Card")
                }
            }
        }
        .environmentObject(mainViewModel)
        .environmentObject(textRecognitionModel)
        .environmentObject(myHapticEngine)
    }
    
    @ViewBuilder private func makeSheet(_ sheet: Sheets) -> some View {
        switch sheet {
        case .cameraView:
            CameraView()
        case .imageROI:
            if let image = selectedImage {
                ImageWithROI(image: image)
            }
        case .ingredients:
            if let selectedIngredientCard = mainViewModel.selectedIngredientCard {
                EditIngredientCardView(ingredientCard: selectedIngredientCard)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
