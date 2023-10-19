//
//  RecognitionModel.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/20/23.
//

import Combine
import SwiftUI
import Vision

/*
 This class manages calls to Vision for image-to-text
 recognition and also sends the output to ChatGPT
 for analysis and formatting.
 */
class IngredientRecognitionHandler: ObservableObject {
    let recognitionSessionQueue = DispatchQueue(label: K.recognitionSessionQueueName, qos: .background)
    
    @Published var progressMessage: String = ""
    @Published var recognitionInProgress: Bool = false
    @Published var presentNewIngredients: Bool = false
    
    private var lastResultsFromVision: [String]? = nil
    private var lastResponseFromChatGPT: OpenAIResponse? = nil
    public var lastIngredientGroupFromChatGPT: IngredientCard? = nil
    
    // ChatGPT Information
    private let completionsEndpoint = "https://api.openai.com/v1/chat/completions"
    
    private var apiKey: String {
        Bundle.main.infoDictionary?["OPENAI_API_KEY"] as! String
    }
    
    private var organization: String {
        Bundle.main.infoDictionary?["OPENAI_ORGANIZATION"] as! String
    }
    
    private enum RecognitionProgressMessages: String {
        case startingVision = "Recognizing ingredients..."
        case doneWithVision = "Done recognizing ingredients!"
        case parsingIngredients = "Parsing ingredients..."
        case doneParsingIngredients = "Done parsing ingredients!"
        case done = "Done!"
    }
    
    private let separateIngredientsCompletion = """
         Separate this ingredient list into an array of strings of its
         components and output as a JSON object. The JSON object should
         have the following format: {"ingredients": []}.
         Here are the ingredients:
        """
    
    // The public function for performing ingredients in an image.
    public func recognizeIngredientsInImage(image: UIImage, region: CGRect) {
        // Move to the recognitionSessionQueue.
        recognitionSessionQueue.async { [weak self] in
            DispatchQueue.main.async { [weak self] in
                // First set these two progress variables on main thread.
                print("Setting recognitionInProgress to true and setting progressMessage")
                print("Current Thread: \(Thread.current)")
                self?.recognitionInProgress = true
                self?.progressMessage = RecognitionProgressMessages.startingVision.rawValue
            }
            
            self?.performImageToTextRecognition(on: image, inRegion: region)
        }
                
        recognitionSessionQueue.async { [weak self] in
            DispatchQueue.main.async {
                print("Setting progressMessage to parsing ingredients")
                print("Current Thread: \(Thread.current)")
                self?.progressMessage = RecognitionProgressMessages.parsingIngredients.rawValue
            }
            
            self?.processVisionText()
        }
    }
}

//MARK: - Vision Image-to-Text Recognition Handlers
extension IngredientRecognitionHandler {
    // This will be performed on a background thread.
    private func performImageToTextRecognition(on image: UIImage,
                                               inRegion region: CGRect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)) {
        guard let cgImage = image.cgImage else { return }
        
        print("Starting performImagetoTextRecognition.")
        print("Current Thread: \(Thread.current)")
        
        let myImageTextRequest = VNImageRequestHandler(cgImage: cgImage, orientation: .right)
        
        /*
         VNRecognizeTextRequest provides text-recognition capabilities.
         The default is the "accurate" method which does neural-network based text detection and recognition.
         It is slower but more accurate.
         */
        let request = VNRecognizeTextRequest(completionHandler: formatObservations)
        request.recognitionLevel = .accurate
        request.progressHandler = myProgressHandler
        request.regionOfInterest = region
        
        // For consistency, use revision 3 of the model.
        request.revision = 3
        // Prefer processing in the background.
        request.preferBackgroundProcessing = true
        
        
        do {
            print("Will try performing the recognize text request.")
            print("Current Thread: \(Thread.current)")
            try myImageTextRequest.perform([request])
        } catch {
            print("Something went wrong: \(error.localizedDescription)")
        }
        
        print("Exiting performImagetoTextRecognition")
    }
    
    // Completion handler for the image text recognition request.
    // Process the response and return an array of the results.
    private func formatObservations(request: VNRequest, error: Error?) {
        // Retrieve the results of the request, which is an array of VNRecognizedTextObservation objects.
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        
        print("Starting formatObservations.")
        print("Current Thread: \(Thread.current). Should not be main.")
        
        let results = observations.compactMap { observation in
            // topCandidates returns an array of the top n candidates as VNRecognizedText objects.
            // Then we use first to get that top candidate.
            // Then we access the string parameter, which is the text as a String type.
            // The resulting type of recognizedStrings is then [String].
            
            return observation.topCandidates(1)[0].string
        }
        
        print("Setting lastResultsFromVision.")
        lastResultsFromVision = results
        
        print("Exiting formatObservations.")
    }
    
    private func myProgressHandler(request: VNRequest, progress: Double, error: Error?) {
        //        DispatchQueue.main.async { [weak self] in
        //            self?.recognitionProgress = CGFloat(progress)
        //        }
    }
    
    public func convertBoundingBoxToNormalizedBoxForVisionROI(boxLocation: CGPoint, boxSize: CGSize, imageSize: CGSize) -> CGRect {
        // Calculate the size of the region of interest normalized to the size of the input image.
        let normalizedWidth = boxSize.width / imageSize.width
        let normalizedHeight = boxSize.height / imageSize.height
        print("normalizedWidth: \(normalizedWidth), normalizedHeight: \(normalizedHeight)")
        
        /*
         Now calculate the x and y coordinate of the region of interest assuming the lower
         left corner is the origin rather than the top left corner of the image.
         The origin of the bounding box is in its top leading corner. So the x
         is the same for the unnormalized and normalized regions.
         For y, we need to calculate the
         normalized coordinate of the lower left corner.
         */
        let newOriginX = max(boxLocation.x, 0)
        let newOriginY = max(imageSize.height - (boxLocation.y + boxSize.height), 0)
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

//MARK: - ChatGPT Ingredient Parsing and Formatting
extension IngredientRecognitionHandler {
    // Process text that was output from Vision.
    public func processVisionText() {
        print("Starting processVisionText")
        guard let ingredients = lastResultsFromVision?.joined(separator: " ") else {
            print("lastResultsFromVision was empty. Exiting processVisionText")
            return
        }
        
        let content = separateIngredientsCompletion + "\"\(ingredients)\""
        
        postMessageToCompletionsEndpoint(content: content, role: "system", model: Chat.chatgpt.rawValue)
        print("Exiting processVisionText")
    }
    
    // Post a message to OpenAI's Chat Completions API endpoint.
    private func postMessageToCompletionsEndpoint(content: String, role: String, model: String, temperature: Double = 0.7) {
        guard let url = URL(string: completionsEndpoint) else {
            print("Bad URL")
            return
        }
        
        print("Starting postMessageToCompletionsEndpoint")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let message = Message(role: role, content: content)
        let requestObject = CompletionRequest(model: model, max_tokens: 1000, messages: [message], temperature: temperature, stream: false)
        let requestData = try? JSONEncoder().encode(requestObject)
        request.httpBody = requestData
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("There was an error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    let responseObject = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    
                    self?.lastResponseFromChatGPT = responseObject
                    print("set lastResponseFromChatGPT")
                } catch {
                    print("There was an error decoding the JSON object: \(error.localizedDescription)")
                }
            }
            
            do {
                try self?.convertOpenAIResponseToIngredients()
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        task.resume()
        print("Exiting postMessageToCompletionsEndpoint")
    }
    
    private func convertOpenAIResponseToIngredients() throws {
        guard let response = lastResponseFromChatGPT else {
            print("last response was nil")
            return
        }
        
        let ingredientJSONString = response.choices[0].message.content
        
        // Try to convert the JSON string from ChatGPT into a JSON Data object.
        guard let ingredientJSON = ingredientJSONString.data(using: .utf8) else { throw OpenAIError.badJSONString }
        
        // Try to decode the JSON object into a DecodedIngredients object.
        let decodedIngredientsObj = try JSONDecoder().decode(DecodedIngredients.self, from: ingredientJSON)
        
        let ingredientsGroup = IngredientCard(decodedIngredients: decodedIngredientsObj)
        
        lastIngredientGroupFromChatGPT = ingredientsGroup
        
        DispatchQueue.main.async { [weak self] in
            print("Setting progressMessage to done")
            print("Current Thread: \(Thread.current)")
            self?.progressMessage = RecognitionProgressMessages.done.rawValue
            self?.recognitionInProgress = false
            
            if self?.lastIngredientGroupFromChatGPT != nil {
                self?.presentNewIngredients = true
            }
        }
    }
}
