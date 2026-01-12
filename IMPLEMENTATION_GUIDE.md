//
//  IMPLEMENTATION_GUIDE.md
//  boilerplate
//
//  Step-by-step implementation guide
//

# Implementation Guide

This guide walks you through implementing the essential parts to get your LLM app running.

## Phase 1: Basic Setup (Required)

### Step 1: Add Files to Xcode Project

**Current State:** All Swift files exist in the file system but are not in Xcode project.

**Action:**
1. Open `boilerplate.xcodeproj` in Xcode
2. In Finder, navigate to the boilerplate folder
3. Select these folders: `App/`, `Core/`, `Features/`, `SharedUI/`
4. Drag them into Xcode's project navigator (under `boilerplate` group)
5. In the dialog:
   - ✅ Check "Copy items if needed"
   - ✅ Select "Create groups"
   - ✅ Add to target: boilerplate
   - Click "Finish"

**Verify:**
- Build the project (⌘B)
- Should compile with 0 errors

### Step 2: Configure LLM Provider (OpenAI Example)

**File:** `App/BoilerplateApp.swift`

Add at the top:
```swift
import SwiftUI

@main
struct BoilerplateApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var llmManager: LLMManager
    // ... other managers
    
    init() {
        // Configure OpenAI
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        let service = OpenAIService(apiKey: apiKey, networkManager: NetworkManager())
        
        let manager = LLMManager()
        manager.configure(with: service)
        _llmManager = StateObject(wrappedValue: manager)
        
        // TODO: Initialize Firebase here
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(authManager)
                .environmentObject(llmManager)
                // ... other environment objects
        }
    }
}
```

**Set API Key:**

Option A - Environment Variable:
1. Edit Scheme → Run → Arguments
2. Add Environment Variable: `OPENAI_API_KEY` = `your-actual-key`

Option B - Hardcode (for testing only):
```swift
let apiKey = "sk-your-key-here" // ⚠️ Don't commit this!
```

### Step 3: Test Basic Flow

**Run the app:**
1. ⌘R to run
2. Complete onboarding (3 screens)
3. Tap "Chat" tab
4. Type a message
5. Tap send
6. Should see response from OpenAI

**Troubleshooting:**
- **"No service configured"**: Check Step 2 configuration
- **Network error**: Verify API key is valid
- **Crashes**: Check all files are added to target

## Phase 2: Data Persistence (Recommended)

### Step 4: Implement Conversation Storage

**File:** `Features/Prompt/PromptViewModel.swift`

Find this TODO:
```swift
// TODO: Save conversation to storage
```

Replace with:
```swift
private let storage = StorageManager()

func saveCurrentConversation() {
    guard let conversation = currentConversation else { return }
    
    do {
        var savedConversations: [Conversation] = []
        if let existing = try storage.load([Conversation].self, forKey: StorageKeys.conversations) {
            savedConversations = existing
        }
        
        // Update or append
        if let index = savedConversations.firstIndex(where: { $0.id == conversation.id }) {
            savedConversations[index] = conversation
        } else {
            savedConversations.append(conversation)
        }
        
        try storage.save(savedConversations, forKey: StorageKeys.conversations)
    } catch {
        ErrorHandler.log(error, context: "Saving conversation")
    }
}
```

Call it after each message:
```swift
func sendMessage(using llmManager: LLMManager) async {
    // ... existing code
    messages.append(assistantMessage)
    
    // Save conversation
    updateCurrentConversation()
    saveCurrentConversation()
}

private func updateCurrentConversation() {
    if currentConversation == nil {
        currentConversation = Conversation(
            title: messages.first?.content.prefix(50).string ?? "New Chat",
            preview: messages.first?.content.prefix(100).string ?? "",
            messages: messages
        )
    } else {
        currentConversation?.messages = messages
    }
}
```

### Step 5: Load Conversations in History

**File:** `Features/History/HistoryViewModel.swift`

Replace `loadConversations()`:
```swift
private let storage = StorageManager()

private func loadConversations() {
    do {
        if let loaded = try storage.load([Conversation].self, forKey: StorageKeys.conversations) {
            conversations = loaded.sorted { $0.timestamp > $1.timestamp }
        }
    } catch {
        ErrorHandler.log(error, context: "Loading conversations")
    }
}
```

Update delete methods:
```swift
func deleteConversation(_ conversation: Conversation) {
    conversations.removeAll { $0.id == conversation.id }
    
    do {
        try storage.save(conversations, forKey: StorageKeys.conversations)
    } catch {
        ErrorHandler.log(error, context: "Deleting conversation")
    }
}
```

## Phase 3: Firebase Integration (Optional)

### Step 6: Add Firebase

**Add Package:**
1. File → Add Package Dependencies
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Select packages:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseAnalytics
   - FirebaseRemoteConfig (for feature flags)

**Download Config:**
1. Go to Firebase Console
2. Add iOS app
3. Download `GoogleService-Info.plist`
4. Add to Xcode project root

### Step 7: Configure Firebase Auth

**File:** `App/BoilerplateApp.swift`

```swift
import FirebaseCore

init() {
    FirebaseApp.configure()
    
    // ... rest of initialization
}
```

**File:** `Core/Auth/AuthManager.swift`

```swift
import FirebaseAuth

func signInAnonymously() async {
    do {
        let result = try await Auth.auth().signInAnonymously()
        
        let anonymousUser = User(
            id: result.user.uid,
            email: nil,
            displayName: "Anonymous User",
            isAnonymous: true
        )
        
        currentUser = anonymousUser
        isAuthenticated = true
        error = nil
        
    } catch {
        self.error = .signInFailed(error.localizedDescription)
    }
}

func signOut() async {
    do {
        try Auth.auth().signOut()
        currentUser = nil
        isAuthenticated = false
        error = nil
    } catch {
        self.error = .signOutFailed(error.localizedDescription)
    }
}
```

### Step 8: Add Firebase Analytics

**File:** `Core/Analytics/AnalyticsManager.swift`

```swift
import FirebaseAnalytics

class FirebaseAnalyticsProvider: AnalyticsProvider {
    func logEvent(_ event: String, parameters: [String: Any]?) {
        Analytics.logEvent(event, parameters: parameters)
    }
    
    func setUserProperty(_ value: String, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
    
    func setUserId(_ userId: String?) {
        Analytics.setUserId(userId)
    }
}
```

**File:** `App/BoilerplateApp.swift`

```swift
init() {
    FirebaseApp.configure()
    
    // Configure analytics
    let analytics = AnalyticsManager()
    analytics.addProvider(FirebaseAnalyticsProvider())
    
    // Use throughout app
}
```

## Phase 4: Subscriptions (Optional)

### Step 9: Configure StoreKit

**File:** `Core/Payments/SubscriptionManager.swift`

Replace product IDs:
```swift
let productIds: Set<String> = [
    "com.yourcompany.yourapp.monthly",
    "com.yourcompany.yourapp.yearly",
    "com.yourcompany.yourapp.lifetime"
]
```

Implement `loadProducts()`:
```swift
func loadProducts() async {
    isLoading = true
    
    do {
        let productIds: Set<String> = [
            "com.yourcompany.yourapp.monthly",
            "com.yourcompany.yourapp.yearly",
            "com.yourcompany.yourapp.lifetime"
        ]
        
        availableProducts = try await Product.products(for: productIds)
        
    } catch {
        self.error = .productLoadFailed(error.localizedDescription)
    }
    
    isLoading = false
}
```

Implement `purchase()`:
```swift
func purchase(_ product: Product) async throws {
    isLoading = true
    
    defer {
        isLoading = false
    }
    
    do {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateEntitlements()
            await transaction.finish()
            
        case .userCancelled:
            throw SubscriptionError.cancelled
            
        case .pending:
            // Handle pending state
            break
            
        @unknown default:
            break
        }
        
    } catch {
        let subError = error as? SubscriptionError ?? .purchaseFailed(error.localizedDescription)
        self.error = subError
        throw subError
    }
}

private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .unverified:
        throw SubscriptionError.verificationFailed
    case .verified(let safe):
        return safe
    }
}
```

### Step 10: Test Purchases

**Create Sandbox Account:**
1. App Store Connect → Users and Access
2. Sandbox Testers → Add tester
3. Use in Settings → App Store → Sandbox Account

**Create Products:**
1. App Store Connect → Your App → Subscriptions
2. Create subscription group
3. Add products matching your product IDs

**Test:**
1. Run app on device (not simulator for IAP)
2. Tap Settings → Subscription → Upgrade
3. Complete test purchase

## Phase 5: Polish (Recommended)

### Step 11: Customize UI

**Colors:** `SharedUI/Extensions/ColorExtensions.swift`
```swift
static let brandPrimary = Color(red: 0.2, green: 0.4, blue: 1.0)
// Or use asset catalog colors
static let brandPrimary = Color("BrandPrimary")
```

**Onboarding:** `Features/Onboarding/OnboardingViewModel.swift`
```swift
let pages: [OnboardingPage] = [
    OnboardingPage(
        imageName: "your.custom.icon",
        title: "Your Unique Value Prop",
        description: "Explain what makes your app special"
    )
    // Add more pages
]
```

**App Icon:**
1. Design 1024x1024 icon
2. Add to Assets.xcassets/AppIcon.appiconset
3. Or use SF Symbols for placeholder

### Step 12: Error Handling

Find all `// TODO: Show error to user` and add:

```swift
.alert("Error", isPresented: .constant(viewModel.error != nil)) {
    Button("OK") {
        viewModel.clearError()
    }
} message: {
    if let error = viewModel.error {
        Text(error.localizedDescription)
    }
}
```

Or use the extension:
```swift
.errorAlert(error: $viewModel.error)
```

### Step 13: Loading States

Add loading indicators:

```swift
if viewModel.isLoading {
    ProgressView()
} else {
    // Content
}
```

Use `LoadingButton` component:
```swift
LoadingButton(
    title: "Send",
    isLoading: viewModel.isLoading,
    action: { await viewModel.sendMessage() }
)
```

## Testing Checklist

Before launch, test these flows:

### Onboarding
- [ ] First launch shows onboarding
- [ ] Can navigate back/forward
- [ ] Completing onboarding saves state
- [ ] Doesn't show again on relaunch

### Authentication
- [ ] Anonymous sign-in works
- [ ] User ID is generated
- [ ] Sign-out works
- [ ] State persists on relaunch

### Chat
- [ ] Can send messages
- [ ] Receives responses
- [ ] Messages display correctly
- [ ] Scrolls to new messages
- [ ] Keyboard dismisses properly

### History
- [ ] Conversations are saved
- [ ] Can delete conversations
- [ ] Grouped by date correctly
- [ ] Tapping opens conversation

### Settings
- [ ] Displays user info
- [ ] Sign out works
- [ ] Preferences save
- [ ] Links open correctly

### Subscriptions
- [ ] Paywall displays
- [ ] Can purchase (sandbox)
- [ ] Restore purchases works
- [ ] Entitlements update

## Performance Optimization

### Lazy Loading
- Tab views load on first access
- ViewModels initialize only when needed
- Heavy operations on background queue

### Caching
```swift
// Cache responses
private var responseCache: [String: LLMResponse] = [:]

func sendPrompt(_ prompt: String) async throws -> LLMResponse {
    if let cached = responseCache[prompt] {
        return cached
    }
    
    let response = try await actualAPICall(prompt)
    responseCache[prompt] = response
    return response
}
```

### Debouncing
```swift
// For search/typing
@Published var searchText: String = ""

var debouncedSearch: AnyPublisher<String, Never> {
    $searchText
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

## Common Pitfalls

### ❌ Forgetting @MainActor
```swift
// Wrong - will crash
class ViewModel: ObservableObject {
    @Published var data: String = ""
    
    func update() async {
        data = "new value" // ❌ Publishing changes from background threads
    }
}

// Right
@MainActor
class ViewModel: ObservableObject { ... }
```

### ❌ Blocking Main Thread
```swift
// Wrong
Button("Load") {
    let data = loadHeavyData() // ❌ Blocks UI
}

// Right
Button("Load") {
    Task {
        await viewModel.loadData() // ✅ Async
    }
}
```

### ❌ Hardcoding API Keys
```swift
// Wrong
let apiKey = "sk-abc123..." // ❌ Never commit secrets

// Right
let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
```

## Next Steps

You now have a fully functional LLM app boilerplate!

**Suggested order:**
1. ✅ Add your branding and copy
2. ✅ Set up backend/database
3. ✅ Implement proper analytics
4. ✅ Add unit tests
5. ✅ Beta test with TestFlight
6. ✅ Submit to App Store

**Advanced features to add:**
- Voice input (Speech framework)
- Image generation
- Document upload
- Share extension
- Widgets
- Push notifications

---

**Need help?** Check the TODO comments throughout the codebase for specific integration points.
