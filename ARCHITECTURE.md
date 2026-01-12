//
//  ARCHITECTURE.md
//  boilerplate
//
//  Architecture Documentation
//

# Architecture Documentation

## Overview

This boilerplate follows **MVVM (Model-View-ViewModel)** architecture with SwiftUI, designed for scalability and maintainability across multiple LLM-powered apps.

## Design Principles

### 1. Separation of Concerns
- **Views**: Only UI and user interactions
- **ViewModels**: Business logic and state management
- **Managers**: Core services (Auth, Network, etc.)
- **Models**: Data structures

### 2. Protocol-Oriented Design
- All managers expose protocols
- Enables testing with mock implementations
- Provider-agnostic (swap Firebase, OpenAI, etc.)

### 3. Async/Await First
- No Combine unless necessary
- Clean async code with structured concurrency
- @MainActor for UI updates

### 4. Environment-Based Dependency Injection
- Core managers as @EnvironmentObject
- Injected at app root
- Accessible throughout view hierarchy

## Architecture Layers

```
┌─────────────────────────────────────────┐
│              Views (SwiftUI)            │  ← User Interface
├─────────────────────────────────────────┤
│           ViewModels (@MainActor)       │  ← Presentation Logic
├─────────────────────────────────────────┤
│       Managers (@MainActor/@Observable) │  ← Business Logic
├─────────────────────────────────────────┤
│     Services (Protocol-based)           │  ← External Integrations
├─────────────────────────────────────────┤
│        Models (Codable/Identifiable)    │  ← Data Structures
└─────────────────────────────────────────┘
```

## Core Components

### App Layer

**BoilerplateApp**
- App entry point using SwiftUI App protocol
- Creates and injects all environment objects
- One-time initialization (Firebase, Analytics)

**AppRootView**
- Top-level routing logic
- Decides: Loading → Onboarding → Auth → Main
- Handles app-level state transitions

**MainTabView**
- Bottom tab navigation container
- Lazy-loads feature modules
- Tab state management

### Core Layer

#### AuthManager
```swift
@MainActor class AuthManager: ObservableObject
```
**Responsibilities:**
- User authentication state
- Sign in/out operations
- Session management
- Account upgrades

**Key Features:**
- Anonymous auth by default
- Apple Sign In ready
- Firebase-compatible
- Backend token management

#### LLMManager
```swift
@MainActor class LLMManager: ObservableObject
```
**Responsibilities:**
- LLM API communication
- Request/response handling
- Streaming support
- Error handling

**Key Features:**
- Provider-agnostic (via LLMServiceProtocol)
- Streaming and non-streaming
- Token usage tracking
- Conversation context management

#### SubscriptionManager
```swift
@MainActor class SubscriptionManager: ObservableObject
```
**Responsibilities:**
- StoreKit 2 integration
- Subscription state
- Entitlements management
- Purchase restoration

**Key Features:**
- Entitlements-based access
- Multi-tier support
- Transaction verification
- Cross-platform sync ready

#### NetworkManager
```swift
class NetworkManager: NetworkManaging
```
**Responsibilities:**
- HTTP requests
- Response parsing
- Error mapping
- Streaming support

**Key Features:**
- Protocol-based (testable)
- Generic with Codable
- Timeout handling
- SSE streaming support

#### AnalyticsManager
```swift
class AnalyticsManager
```
**Responsibilities:**
- Event tracking
- User properties
- Multi-provider support

**Key Features:**
- Provider-agnostic
- Type-safe events
- Automatic screen tracking
- Debug logging

#### FeatureFlagManager
```swift
@MainActor class FeatureFlagManager: ObservableObject
```
**Responsibilities:**
- Feature toggles
- A/B testing
- Remote configuration

**Key Features:**
- Local defaults
- Remote overrides
- Type-safe flags
- Runtime updates

#### AppConfigManager
```swift
@MainActor class AppConfigManager: ObservableObject
```
**Responsibilities:**
- App-level configuration
- Onboarding state
- Version management

**Key Features:**
- Persistent state
- First launch detection
- Version checks

### Feature Layer

Each feature follows this structure:

```
Feature/
  ├── FeatureView.swift        # SwiftUI View
  └── FeatureViewModel.swift   # @MainActor ViewModel
```

**View Responsibilities:**
- UI layout and styling
- User interaction handling
- Observes ViewModel state
- No business logic

**ViewModel Responsibilities:**
- Presentation logic
- State management
- Calls managers for operations
- Transforms data for view

**Example: PromptViewModel**
```swift
@MainActor
class PromptViewModel: ObservableObject {
    @Published var messages: [LLMMessage] = []
    @Published var inputText: String = ""
    @Published var isStreaming: Bool = false
    
    func sendMessage(using llmManager: LLMManager) async {
        // Business logic here
    }
}
```

### SharedUI Layer

**Components**
- Reusable UI components
- Styled consistently
- Generic and configurable

**Extensions**
- View helpers
- Color palette
- Type extensions

**Constants**
- App-wide constants
- Configuration values
- URLs and limits

## Data Flow

### Standard Flow
```
User Action
    ↓
View (Button tap)
    ↓
ViewModel (async function)
    ↓
Manager (business logic)
    ↓
Service (API call)
    ↓
Manager (process response)
    ↓
ViewModel (update @Published)
    ↓
View (SwiftUI updates UI)
```

### Example: Sending a Message
```swift
// 1. User taps send
Button("Send") {
    Task {
        await viewModel.sendMessage(using: llmManager)
    }
}

// 2. ViewModel processes
func sendMessage(using llmManager: LLMManager) async {
    messages.append(userMessage)
    isStreaming = true
    
    // 3. Call manager
    let response = try await llmManager.sendPrompt(inputText)
    
    // 4. Update state
    messages.append(response.toLLMMessage())
    isStreaming = false
}

// 5. View automatically updates (SwiftUI)
```

## State Management

### Published Properties
```swift
@Published var property: Type
```
- For ViewModel/Manager state
- Auto-triggers view updates
- Must be on @MainActor

### Environment Objects
```swift
@EnvironmentObject var manager: Manager
```
- For app-wide managers
- Injected at root
- Accessed by descendants

### State vs StateObject
```swift
@State private var localValue          // View-local state
@StateObject private var viewModel     // View-owned ViewModel
@EnvironmentObject var manager         // Injected manager
```

## Error Handling

### Three-Level Strategy

**1. Service Level**
- Throw specific errors
- Map network errors
```swift
throw LLMError.rateLimitExceeded
```

**2. Manager Level**
- Catch and log errors
- Update error state
```swift
@Published private(set) var error: LLMError?
```

**3. View Level**
- Display to user
- Provide retry action
```swift
.alert(error: $viewModel.error)
```

### Centralized Error Handling
```swift
ErrorHandler.log(error, context: "Sending message")
let message = ErrorHandler.handle(error)
```

## Navigation

### Tab Navigation
```swift
TabView(selection: $selectedTab)
```
- Bottom tabs for main features
- State preservation
- Deep linking ready

### Stack Navigation
```swift
NavigationStack
```
- Within each tab
- Detail views
- Modal presentations

### Sheet Modals
```swift
.sheet(isPresented: $showPaywall) {
    PaywallView()
}
```
- Paywall
- Settings
- Full-screen overlays

## Testing Strategy

### ViewModels
- Pure logic, easy to test
- Mock managers via protocols
```swift
let mockLLM = MockLLMManager()
let viewModel = PromptViewModel()
await viewModel.sendMessage(using: mockLLM)
XCTAssertEqual(viewModel.messages.count, 2)
```

### Managers
- Test with mock services
```swift
let mockNetwork = MockNetworkManager()
let authManager = AuthManager(network: mockNetwork)
```

### Views
- SwiftUI Preview tests
- UI tests for critical flows

## Performance Considerations

### Lazy Loading
- Features load on-demand
- ViewModels created per-view
- Heavy operations in background

### Async/Await
- All network operations async
- UI updates on @MainActor
- Structured concurrency

### Memory Management
- @StateObject for ownership
- @ObservedObject for injection
- Weak references where needed

## Scalability

### Adding New Features
1. Create folder in Features/
2. Add View + ViewModel
3. Add tab in MainTabView if needed
4. No changes to core layer

### Adding New Managers
1. Create protocol
2. Implement manager
3. Inject in BoilerplateApp
4. Use as @EnvironmentObject

### Supporting Multiple Apps
1. Keep core layer unchanged
2. Customize features per app
3. Different LLM services per app
4. Shared SharedUI library

## Security Considerations

### API Keys
- Never hardcode
- Use environment variables
- Or secure backend proxy

### User Data
- Encrypt sensitive data
- Use Keychain for tokens
- GDPR-compliant deletion

### Authentication
- Token expiration
- Refresh token flow
- Secure session storage

## Best Practices

### 1. Keep Views Dumb
```swift
// ❌ Bad
Button("Send") {
    let response = await sendToAPI(text)
    messages.append(response)
}

// ✅ Good
Button("Send") {
    Task {
        await viewModel.sendMessage()
    }
}
```

### 2. Use Protocols
```swift
// ✅ Testable
protocol LLMServiceProtocol { ... }
class LLMManager {
    let service: LLMServiceProtocol
}
```

### 3. Async/Await
```swift
// ❌ Callback hell
fetchUser { user in
    fetchPosts(user) { posts in
        updateUI(posts)
    }
}

// ✅ Clean async
let user = try await fetchUser()
let posts = try await fetchPosts(user)
updateUI(posts)
```

### 4. Error Propagation
```swift
// Throw from services
// Catch in managers
// Display in views
```

## Future Enhancements

### Planned
- [ ] Core Data / SwiftData integration
- [ ] CloudKit sync
- [ ] Background processing
- [ ] Widgets
- [ ] App Clips
- [ ] SharePlay

### Considerations
- Keep architecture flexible
- Protocol-based additions
- Maintain separation of concerns

---

This architecture is designed to scale from prototype to production while maintaining clean, testable, and maintainable code.
