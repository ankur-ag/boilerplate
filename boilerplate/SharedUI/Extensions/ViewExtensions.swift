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
    
    /// Track screen view using AnalyticsManager
    func trackScreenView(_ screenName: String) -> some View {
        self.modifier(ScreenTrackingModifier(screenName: screenName))
    }
}

private struct ScreenTrackingModifier: ViewModifier {
    let screenName: String
    @Environment(\.analyticsManager) private var analyticsManager
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                analyticsManager.logScreenView(screenName)
            }
    }
}

// MARK: - Environment Values

struct LLMManagerKey: EnvironmentKey {
    @MainActor static let defaultValue: LLMManager = LLMManager()
}

struct ImageGenerationManagerKey: EnvironmentKey {
    @MainActor static let defaultValue: ImageGenerationManager = ImageGenerationManager()
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
