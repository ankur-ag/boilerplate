// README.md
// iOS SwiftUI Boilerplate for LLM Apps
// ======================================

# SwiftUI LLM App Boilerplate

A production-ready SwiftUI boilerplate for building AI/LLM-powered iOS applications with clean architecture and scalability.

## Architecture

- **MVVM** pattern with protocol-based abstractions
- **iOS 17+** requirement
- SwiftUI-first with async/await
- Backend-agnostic design
- Modular and reusable

## Project Structure

```
boilerplate/
├── App/
│   ├── BoilerplateApp.swift      # App entry point with environment setup
│   ├── AppRootView.swift          # Root view with routing logic
│   └── MainTabView.swift          # Bottom tab navigation
│
├── Core/
│   ├── Auth/
│   │   └── AuthManager.swift     # Authentication (anonymous + Apple Sign In)
│   ├── LLM/
│   │   └── LLMManager.swift      # LLM network layer (provider-agnostic)
│   ├── Payments/
│   │   └── SubscriptionManager.swift  # StoreKit 2 subscriptions
│   ├── Networking/
│   │   └── NetworkManager.swift  # Generic networking layer
│   ├── Analytics/
│   │   └── AnalyticsManager.swift # Multi-provider analytics
│   ├── FeatureFlags/
│   │   └── FeatureFlagManager.swift # Feature flags & A/B testing
│   ├── AppConfig/
│   │   └── AppConfigManager.swift # App configuration & state
│   ├── Storage/
│   │   └── StorageManager.swift  # Local data persistence
│   └── ErrorHandling/
│       └── ErrorHandling.swift   # Centralized error handling
│
├── Features/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── OnboardingViewModel.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Prompt/
│   │   ├── PromptView.swift      # Chat interface
│   │   └── PromptViewModel.swift
│   ├── Output/
│   │   └── OutputView.swift      # Formatted LLM responses
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── HistoryViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── SettingsViewModel.swift
│   └── Paywall/
│       ├── PaywallView.swift
│       └── PaywallViewModel.swift
│
└── SharedUI/
    ├── Components/
    │   ├── LoadingButton.swift
    │   ├── ErrorView.swift
    │   ├── EmptyStateView.swift
    │   └── PrimaryButton.swift
    ├── Extensions/
    │   ├── ViewExtensions.swift
    │   └── ColorExtensions.swift
    └── Constants/
        └── AppConstants.swift
```

## Core Features

### Authentication
- Anonymous authentication by default
- Apple Sign In support (TODO)
- Account upgrade flow
- Session management

### LLM Integration
- Provider-agnostic design
- Support for both streaming and non-streaming
- Token usage tracking
- Conversation history
- **📸 NEW: Multimedia support (photos, videos, documents)**
- **🤖 NEW: Vision AI integration (GPT-4 Vision ready)**

### Subscriptions
- StoreKit 2 implementation
- Entitlements-based access control
- Multi-tier support (monthly/yearly/lifetime)
- Purchase restoration

### Feature Flags
- Remote configuration ready
- A/B testing support
- Local defaults with remote overrides

### Analytics
- Multi-provider support
- Event tracking
- User properties
- Screen view tracking

### 📸 Media Upload (NEW!)
- Photo library picker (multi-select)
- Camera capture
- Video upload
- Document picker (PDF, TXT, DOC)
- Automatic image compression & resize
- Thumbnail generation
- Base64 encoding for APIs
- Chat integration with media preview
- Permission handling

## Usage

### Adding an LLM Provider

1. Implement the `LLMServiceProtocol`:

```swift
class OpenAIService: LLMServiceProtocol {
    func sendRequest(_ request: LLMRequest) async throws -> LLMResponse {
        // Your implementation
    }
    
    func streamRequest(...) async throws {
        // Your streaming implementation
    }
}
```

2. Configure in `BoilerplateApp.swift`:

```swift
init() {
    let openAIService = OpenAIService()
    llmManager.configure(with: openAIService)
}
```

### Adding Firebase

1. Add Firebase SDK via SPM
2. Configure in `BoilerplateApp.swift`:

```swift
init() {
    FirebaseApp.configure()
}
```

3. Update managers to use Firebase:
   - `AuthManager`: Firebase Auth
   - `SubscriptionManager`: RevenueCat or Firebase
   - `AnalyticsManager`: Firebase Analytics
   - `FeatureFlagManager`: Firebase Remote Config

## TODO Items

Throughout the codebase, look for `// TODO:` comments marking:
- Backend integration points
- Firebase configuration
- Analytics implementation
- Error handling improvements
- Feature completions

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Notes

- All managers use `@MainActor` for UI updates
- Async/await preferred over Combine
- Protocol-based abstractions for testability
- No hardcoded business logic in Views
- Error handling at all network boundaries

## Next Steps

1. Add Firebase dependencies
2. Configure LLM provider
3. Set up StoreKit products
4. Add analytics provider
5. Customize UI branding
6. Implement data persistence
7. Add unit tests

## License

This boilerplate is designed for internal use and can be customized for multiple LLM apps.
