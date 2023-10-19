//
//  OpenAIResponseModels.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/20/23.
//

import Foundation

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

struct DecodedIngredients: Codable {
    let ingredients: [String]
}
