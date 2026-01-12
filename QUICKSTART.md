//
//  QUICKSTART.md
//  boilerplate
//
//  Quick Start Guide for iOS LLM Boilerplate
//

# Quick Start Guide

## Project Setup

### 1. Open in Xcode

1. Open `boilerplate.xcodeproj` in Xcode 15+
2. Select your development team in Signing & Capabilities
3. Build the project (⌘B) to verify everything compiles

### 2. Add Your Files to Xcode

All Swift files have been created in the file system. To add them to Xcode:

**Option A: Drag & Drop**
1. In Finder, select all folders: App/, Core/, Features/, SharedUI/
2. Drag them into the Xcode project navigator
3. Check "Copy items if needed" and "Create groups"

**Option B: Add Files**
1. Right-click on `boilerplate` group in Xcode
2. Select "Add Files to boilerplate..."
3. Navigate to each folder and add them

### 3. Remove Old Files (Optional)

You can remove these legacy UIKit files:
- AppDelegate.swift
- SceneDelegate.swift
- ViewController.swift
- Base.lproj/Main.storyboard
- Base.lproj/LaunchScreen.storyboard (or keep for launch screen)

## Configuration Checklist

### Required: LLM Provider

Pick ONE and implement:

**Option 1: OpenAI**
```swift
// Create: Core/LLM/OpenAIService.swift
class OpenAIService: LLMServiceProtocol {
    private let apiKey: String
    private let networkManager: NetworkManaging
    
    init(apiKey: String, networkManager: NetworkManaging) {
        self.apiKey = apiKey
        self.networkManager = networkManager
    }
    
    func sendRequest(_ request: LLMRequest) async throws -> LLMResponse {
        // Implement OpenAI API call
        let endpoint = OpenAIEndpoint.chat(request: request, apiKey: apiKey)
        let response: OpenAIResponse = try await networkManager.request(endpoint)
        return response.toLLMResponse()
    }
    
    func streamRequest(...) async throws {
        // Implement streaming
    }
}
```

**Option 2: Anthropic Claude**
```swift
// Similar implementation for Anthropic
class AnthropicService: LLMServiceProtocol { ... }
```

**Then configure in App/BoilerplateApp.swift:**
```swift
init() {
    // Option 1: OpenAI
    let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    let service = OpenAIService(apiKey: apiKey, networkManager: NetworkManager())
    _llmManager = StateObject(wrappedValue: LLMManager())
    llmManager.configure(with: service)
}
```

### Optional: Firebase Setup

1. **Add Firebase Package**
   - File → Add Package Dependencies
   - Add: `https://github.com/firebase/firebase-ios-sdk`
   - Select: FirebaseAuth, FirebaseFirestore, FirebaseAnalytics

2. **Download GoogleService-Info.plist**
   - Go to Firebase Console
   - Download configuration file
   - Add to Xcode project

3. **Configure in BoilerplateApp.swift**
```swift
import FirebaseCore
import FirebaseAuth

init() {
    FirebaseApp.configure()
    // Rest of initialization
}
```

4. **Update AuthManager.swift**
```swift
import FirebaseAuth

func signInAnonymously() async {
    do {
        let result = try await Auth.auth().signInAnonymously()
        let user = User(
            id: result.user.uid,
            isAnonymous: true
        )
        currentUser = user
        isAuthenticated = true
    } catch {
        self.error = .signInFailed(error.localizedDescription)
    }
}
```

### Optional: In-App Purchases

1. **Create Products in App Store Connect**
   - Monthly subscription
   - Yearly subscription
   - Lifetime purchase

2. **Update SubscriptionManager.swift**
```swift
let productIds: Set<String> = [
    "com.yourcompany.yourapp.monthly",
    "com.yourcompany.yourapp.yearly",
    "com.yourcompany.yourapp.lifetime"
]
```

3. **Test in Sandbox**
   - Create sandbox test account
   - Run app and test purchases

## Testing the Boilerplate

### Run the App

1. Select a simulator or device
2. Press ⌘R to run
3. You should see:
   - Onboarding flow (3 screens)
   - Bottom tab navigation
   - Placeholder screens

### Test Flows

**Onboarding → Home**
- Complete onboarding
- See home screen with quick actions

**Chat Flow**
- Tap Chat tab
- Type a message
- Currently won't work until you add LLM provider

**Settings**
- View account info
- Check subscription status (Free)
- Toggle preferences

## Next Steps

### Essential (in order):

1. ✅ **Implement LLM Service** (see above)
2. ✅ **Add API Keys** (environment variables or config)
3. ✅ **Test Chat Flow** (send/receive messages)
4. 🔲 **Add Data Persistence** (implement StorageManager save/load)
5. 🔲 **Style the UI** (customize colors, fonts, branding)

### Recommended:

6. 🔲 **Add Firebase** (auth, analytics, remote config)
7. 🔲 **Configure IAP** (set up products)
8. 🔲 **Add Unit Tests** (for ViewModels and Managers)
9. 🔲 **Error Handling** (implement all TODOs)
10. 🔲 **Analytics Events** (track user actions)

### Advanced:

11. 🔲 **Conversation Persistence** (save/load history)
12. 🔲 **Streaming Support** (implement streaming UI)
13. 🔲 **Push Notifications**
14. 🔲 **Share Extension**
15. 🔲 **Widget Support**

## Project Customization

### Change App Name

1. In Xcode, select project
2. Change "Display Name" in Build Settings
3. Update bundle identifier

### Customize Colors

Edit `SharedUI/Extensions/ColorExtensions.swift`:
```swift
static let brandPrimary = Color("YourCustomColor")
```

Add colors to Assets.xcassets

### Customize Onboarding

Edit `Features/Onboarding/OnboardingViewModel.swift`:
```swift
let pages: [OnboardingPage] = [
    OnboardingPage(
        imageName: "your.icon",
        title: "Your Title",
        description: "Your description"
    )
]
```

## Environment Variables

Create a scheme with environment variables:

1. Edit Scheme → Run → Arguments
2. Add Environment Variables:
   - `OPENAI_API_KEY` = your-key
   - `API_BASE_URL` = your-backend-url

Or use a Config.xcconfig file.

## Common Issues

### Build Errors
- **Issue**: Missing files
- **Fix**: Ensure all files are added to target membership

### Runtime Crashes
- **Issue**: "No LLM service configured"
- **Fix**: Configure LLM service in BoilerplateApp.init()

### Empty Screens
- **Issue**: No data showing
- **Fix**: Implement TODOs in ViewModels

## File Organization

Keep this structure:
```
App/          → Entry point, routing
Core/         → Business logic, managers
Features/     → Feature modules (View + ViewModel)
SharedUI/     → Reusable components
```

## Getting Help

All files have extensive `// TODO:` comments marking:
- Integration points
- Missing implementations
- Customization spots

Search for "TODO" to find what needs completion.

## Production Checklist

Before shipping:

- [ ] Remove all debug prints
- [ ] Add proper error handling
- [ ] Implement analytics
- [ ] Add crash reporting
- [ ] Test on real devices
- [ ] Test IAP thoroughly
- [ ] Privacy policy & terms
- [ ] App Store assets
- [ ] TestFlight beta testing

---

**You're ready to build your LLM app! 🚀**
