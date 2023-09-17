//
//  PhotosPicker.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/14/23.
//

import PhotosUI
import SwiftUI

//struct ImagePicker: UIViewControllerRepresentable {
//    @EnvironmentObject var visionModel: VisionViewModel
//    
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var config = PHPickerConfiguration()
//        config.filter = .images
//        config.selectionLimit = 2
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        let parent: ImagePicker
//        
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//        
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            picker.dismiss(animated: true)
//            
//            guard let provider = results.first?.itemProvider else { return }
//            
//            if provider.canLoadObject(ofClass: UIImage.self) {
//                provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
//                    guard let image = image as? UIImage else { return }
//                    DispatchQueue.main.async {
//                        self?.parent.visionModel.setImageToProcess(image)
//                    }
//                }
//            }
//        }
//    }
//}
