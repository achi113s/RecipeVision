//
//  OpenAIViewModel.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/17/23.
//

import Foundation

class OpenAIViewModel: NSObject, ObservableObject {
    private let completionsEndpoint = "https://api.openai.com/v1/chat/completions"
    
    @Published var lastResponse: Ingredients? = nil
    
    private var apiKey: String {
        ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!
    }
    
    private var organization: String {
        ProcessInfo.processInfo.environment["OPENAI_ORGANIZATION"]!
    }
    
    func postMessage(content: String, role: String, model: String, temperature: Double = 0.7) async throws {
        guard let url = URL(string: completionsEndpoint) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let message = Message(role: role, content: content)
        let requestObject = CompletionRequest(model: model, max_tokens: 1000, messages: [message], temperature: temperature, stream: false)
        let requestData = try JSONEncoder().encode(requestObject)
        request.httpBody = requestData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            let responseObject = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            print(responseObject.choices[0].message.content)
            let ingredientJSONString = responseObject.choices[0].message.content
            if let ingredientJSON = ingredientJSONString.data(using: .utf8) {
                lastResponse = try JSONDecoder().decode(Ingredients.self, from: ingredientJSON)
            }
            print(lastResponse ?? "")
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let usage: Usage
    let choices: [Choice]
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct Choice: Codable {
    let message: Message
    let finish_reason: String
}

struct Message: Codable {
    let role: String
    let content: String
}

struct CompletionRequest: Codable {
    let model: String
    let max_tokens: Int
    let messages: [Message]
    let temperature: Double
    let stream: Bool
}

struct Ingredients: Codable {
    let ingredients: [String]
}
