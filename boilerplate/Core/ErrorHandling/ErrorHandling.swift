//
//  ErrorHandling.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation

/// Centralized error handling utilities
enum ErrorHandler {
    /// Log error to analytics and crash reporting
    static func log(_ error: Error, context: String? = nil) {
        #if DEBUG
        print("❌ Error: \(error.localizedDescription)")
        if let context = context {
            print("   Context: \(context)")
        }
        #endif
        
        // TODO: Send to crash reporting service (Crashlytics, Sentry, etc.)
        // TODO: Log to analytics
    }
    
    /// Handle error with user-friendly message
    static func handle(_ error: Error) -> String {
        switch error {
        case let networkError as NetworkError:
            return handleNetworkError(networkError)
        case let authError as AuthError:
            return authError.localizedDescription
        case let llmError as LLMError:
            return llmError.localizedDescription
        case let subError as SubscriptionError:
            return subError.localizedDescription
        default:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    private static func handleNetworkError(_ error: NetworkError) -> String {
        switch error {
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "Request timed out. Please try again."
        case .httpError(let statusCode):
            if statusCode >= 500 {
                return "Server error. Please try again later."
            } else if statusCode == 401 {
                return "Authentication required. Please sign in."
            } else {
                return "Request failed with status code \(statusCode)"
            }
        default:
            return error.localizedDescription
        }
    }
}
