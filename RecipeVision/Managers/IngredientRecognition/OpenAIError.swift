//
//  OpenAIError.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/20/23.
//

import Foundation

enum OpenAIError: Error {
    /*
     Throw when ChatGPT returns a bad JSON String
     and we can't convert it to a JSON data object.
     */
    case badJSONString
}

extension OpenAIError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .badJSONString:
            return "ChatGPT returned an inconvertible JSON string or none at all."
        }
    }
}

extension OpenAIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badJSONString:
            return NSLocalizedString(
                "The API returned an unexpected result.",
                comment: "Received an unexpected result."
            )
        }
    }
}

