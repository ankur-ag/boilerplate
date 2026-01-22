//
//  ViewExtensions.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

extension View {
    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Apply conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Apply error alert
    func errorAlert(error: Binding<Error?>) -> some View {
        alert("Error", isPresented: .constant(error.wrappedValue != nil)) {
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: {
            if let error = error.wrappedValue {
                Text(error.localizedDescription)
            }
        }
    }
    }
}

// MARK: - Environment Values

struct LLMManagerKey: EnvironmentKey {
    static let defaultValue: LLMManager = LLMManager()
}

struct ImageGenerationManagerKey: EnvironmentKey {
    static let defaultValue: ImageGenerationManager = ImageGenerationManager()
}

struct UsageManagerKey: EnvironmentKey {
    static let defaultValue: UsageManager = UsageManager()
}

struct AnalyticsManagerKey: EnvironmentKey {
    static let defaultValue: AnalyticsManager = AnalyticsManager()
}

extension EnvironmentValues {
    var llmManager: LLMManager {
        get { self[LLMManagerKey.self] }
        set { self[LLMManagerKey.self] = newValue }
    }
    
    var imageGenerationManager: ImageGenerationManager {
        get { self[ImageGenerationManagerKey.self] }
        set { self[ImageGenerationManagerKey.self] = newValue }
    }
    
    var usageManager: UsageManager {
        get { self[UsageManagerKey.self] }
        set { self[UsageManagerKey.self] = newValue }
    }
    
    var analyticsManager: AnalyticsManager {
        get { self[AnalyticsManagerKey.self] }
        set { self[AnalyticsManagerKey.self] = newValue }
    }
}
