# ✅ Setup Checklist

Use this checklist to set up your LLM iOS app from the boilerplate.

## 📋 Pre-Flight Check

- [ ] Xcode 15.0+ installed
- [ ] iOS 17+ SDK available
- [ ] LLM provider API key ready (OpenAI, Anthropic, etc.)
- [ ] Apple Developer account (for device testing)

---

## 🚀 Phase 1: Initial Setup (10 minutes)

### Step 1: Project Setup
- [ ] Open `boilerplate.xcodeproj` in Xcode
- [ ] Verify project builds (⌘B)
- [ ] Check target is set to iOS 17.0+

### Step 2: Add Source Files
- [ ] Drag `App/` folder into Xcode project navigator
- [ ] Drag `Core/` folder into Xcode project navigator
- [ ] Drag `Features/` folder into Xcode project navigator
- [ ] Drag `SharedUI/` folder into Xcode project navigator
- [ ] In dialog: Check "Copy items if needed" + "Create groups"
- [ ] Verify all files show in project navigator
- [ ] Build again (⌘B) - should compile successfully

### Step 3: Remove Legacy Files (Optional)
- [ ] Delete `AppDelegate.swift` from project
- [ ] Delete `SceneDelegate.swift` from project
- [ ] Delete `ViewController.swift` from project
- [ ] Keep `LaunchScreen.storyboard` (or replace with custom)

### Step 4: Basic Configuration
- [ ] Open `App/BoilerplateApp.swift`
- [ ] Verify environment objects are set up
- [ ] Check `Info.plist` is configured for SwiftUI

**✅ Checkpoint:** App should build and run, showing onboarding

---

## 🤖 Phase 2: LLM Integration (15 minutes)

### Step 5: Choose LLM Provider
- [ ] Decided on provider (OpenAI / Anthropic / Other)
- [ ] API key obtained
- [ ] Read provider's documentation

### Step 6: Configure OpenAI (Example)
- [ ] Open `App/BoilerplateApp.swift`
- [ ] Add this to `init()`:
```swift
let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
let service = OpenAIService(apiKey: apiKey)
let manager = LLMManager()
manager.configure(with: service)
_llmManager = StateObject(wrappedValue: manager)
```
- [ ] Set API key in Xcode scheme: Edit Scheme → Run → Arguments
- [ ] Add environment variable: `OPENAI_API_KEY` = your key

### Step 7: Test Chat
- [ ] Run app (⌘R)
- [ ] Complete onboarding
- [ ] Tap "Chat" tab
- [ ] Type a message
- [ ] Tap send
- [ ] Verify response appears

**✅ Checkpoint:** Chat should work end-to-end

---

## 💾 Phase 3: Data Persistence (20 minutes)

### Step 8: Implement Storage
- [ ] Open `Features/Prompt/PromptViewModel.swift`
- [ ] Find `// TODO: Save conversation to storage`
- [ ] Add storage implementation (see IMPLEMENTATION_GUIDE.md)
- [ ] Test: Send message, restart app, verify history saved

### Step 9: History Feature
- [ ] Open `Features/History/HistoryViewModel.swift`
- [ ] Implement `loadConversations()`
- [ ] Implement `deleteConversation()`
- [ ] Test: View history, delete conversation

**✅ Checkpoint:** Conversations persist across app restarts

---

## 🎨 Phase 4: Branding (30 minutes)

### Step 10: Visual Identity
- [ ] Change app name in Xcode project settings
- [ ] Update bundle identifier
- [ ] Design/add app icon to Assets.xcassets
- [ ] Configure accent color in Assets.xcassets

### Step 11: Color Scheme
- [ ] Open `SharedUI/Extensions/ColorExtensions.swift`
- [ ] Update `brandPrimary` color
- [ ] Update `brandSecondary` color
- [ ] Add custom colors to Assets.xcassets if needed

### Step 12: Onboarding Customization
- [ ] Open `Features/Onboarding/OnboardingViewModel.swift`
- [ ] Update page titles
- [ ] Update descriptions
- [ ] Change SF Symbols icons
- [ ] Or add custom images to Assets.xcassets

### Step 13: Copy & Messaging
- [ ] Update home screen welcome text
- [ ] Update tab labels if needed
- [ ] Update settings screen copy
- [ ] Update paywall messaging

**✅ Checkpoint:** App looks like your brand

---

## 🔥 Phase 5: Firebase (Optional, 30 minutes)

### Step 14: Firebase Setup
- [ ] Create Firebase project at console.firebase.google.com
- [ ] Add iOS app
- [ ] Download `GoogleService-Info.plist`
- [ ] Add plist to Xcode project root

### Step 15: Add Firebase SDK
- [ ] File → Add Package Dependencies
- [ ] URL: `https://github.com/firebase/firebase-ios-sdk`
- [ ] Select: FirebaseAuth, FirebaseFirestore, FirebaseAnalytics
- [ ] Wait for packages to download

### Step 16: Configure Firebase Auth
- [ ] Open `App/BoilerplateApp.swift`
- [ ] Add `import FirebaseCore` at top
- [ ] Add `FirebaseApp.configure()` in `init()`
- [ ] Open `Core/Auth/AuthManager.swift`
- [ ] Add `import FirebaseAuth`
- [ ] Implement Firebase auth methods (see IMPLEMENTATION_GUIDE.md)

### Step 17: Configure Analytics
- [ ] Open `Core/Analytics/AnalyticsManager.swift`
- [ ] Add `import FirebaseAnalytics`
- [ ] Implement `FirebaseAnalyticsProvider`
- [ ] Add provider in `BoilerplateApp.init()`

**✅ Checkpoint:** Firebase auth and analytics working

---

## 💰 Phase 6: Subscriptions (Optional, 45 minutes)

### Step 18: App Store Connect Setup
- [ ] Log in to App Store Connect
- [ ] Create app if needed
- [ ] Navigate to In-App Purchases
- [ ] Create subscription group

### Step 19: Create Products
- [ ] Create monthly subscription
  - Product ID: `com.yourcompany.yourapp.monthly`
  - Price: Set your price
- [ ] Create yearly subscription
  - Product ID: `com.yourcompany.yourapp.yearly`
  - Price: Set your price
- [ ] (Optional) Create lifetime purchase
  - Product ID: `com.yourcompany.yourapp.lifetime`

### Step 20: Update Product IDs
- [ ] Open `Core/Payments/SubscriptionManager.swift`
- [ ] Update `productIds` Set with your actual IDs
- [ ] Implement `loadProducts()` (see IMPLEMENTATION_GUIDE.md)
- [ ] Implement `purchase()` method

### Step 21: Test Purchases
- [ ] Create sandbox tester account
- [ ] Sign out of App Store on device
- [ ] Sign in with sandbox account
- [ ] Run app on device (IAP doesn't work in simulator)
- [ ] Test purchase flow
- [ ] Test restore purchases

**✅ Checkpoint:** Purchases working in sandbox

---

## 🧪 Phase 7: Testing (30 minutes)

### Step 22: Manual Testing
- [ ] Test onboarding flow (all 3 screens)
- [ ] Test sign in flow
- [ ] Test chat (send multiple messages)
- [ ] Test history (view, delete)
- [ ] Test settings (toggle preferences)
- [ ] Test sign out
- [ ] Test app lifecycle (background/foreground)

### Step 23: Error Scenarios
- [ ] Test with no internet connection
- [ ] Test with invalid API key
- [ ] Test with rate limiting
- [ ] Verify error messages are user-friendly

### Step 24: Edge Cases
- [ ] Test with very long messages
- [ ] Test with empty input
- [ ] Test rapid-fire messages
- [ ] Test app restart mid-conversation

**✅ Checkpoint:** All major flows work correctly

---

## 📝 Phase 8: Polish (Ongoing)

### Step 25: Error Handling
- [ ] Search for `// TODO: Show error to user`
- [ ] Implement error alerts
- [ ] Test all error paths
- [ ] Add retry mechanisms

### Step 26: Loading States
- [ ] Add loading indicators where needed
- [ ] Test all async operations
- [ ] Ensure UI doesn't freeze

### Step 27: Analytics Events
- [ ] Review `AnalyticsEvent` enum
- [ ] Add events for key user actions
- [ ] Verify events are firing
- [ ] Check Firebase console

### Step 28: Feature Flags
- [ ] Review feature flags in `FeatureFlagManager`
- [ ] Add any app-specific flags
- [ ] Test flag toggling
- [ ] Plan for remote config

**✅ Checkpoint:** App feels polished

---

## 🚢 Phase 9: Pre-Launch (1-2 days)

### Step 29: App Store Prep
- [ ] Create App Store listing
- [ ] Prepare screenshots (required sizes)
- [ ] Write app description
- [ ] Prepare preview video (optional)
- [ ] Add privacy policy URL
- [ ] Add terms of service URL

### Step 30: TestFlight
- [ ] Archive app (⌘⇧B → Distribute)
- [ ] Upload to TestFlight
- [ ] Add internal testers
- [ ] Collect feedback
- [ ] Fix critical issues

### Step 31: Final Checks
- [ ] Remove all debug prints
- [ ] Remove test code
- [ ] Set build number
- [ ] Set version number
- [ ] Update CHANGELOG if using
- [ ] Archive release build

### Step 32: Submission
- [ ] Submit for App Review
- [ ] Monitor review status
- [ ] Respond to reviewer questions
- [ ] Celebrate! 🎉

**✅ Checkpoint:** App submitted to App Store!

---

## 📊 Progress Tracking

### Overall Progress
- [ ] Phase 1: Initial Setup (10 min)
- [ ] Phase 2: LLM Integration (15 min)
- [ ] Phase 3: Data Persistence (20 min)
- [ ] Phase 4: Branding (30 min)
- [ ] Phase 5: Firebase (30 min) - Optional
- [ ] Phase 6: Subscriptions (45 min) - Optional
- [ ] Phase 7: Testing (30 min)
- [ ] Phase 8: Polish (Ongoing)
- [ ] Phase 9: Pre-Launch (1-2 days)

### Time Estimates
- **Minimum viable**: ~1.5 hours (Phases 1-4, 7)
- **Feature complete**: ~3 hours (+ Phases 5-6)
- **Production ready**: +2 days (+ Phases 8-9)

---

## 🆘 Troubleshooting

### Build Errors
- **Issue**: Files not found
- **Fix**: Ensure all folders added to target membership
- **Verify**: Check Build Phases → Compile Sources

### Runtime Errors
- **Issue**: "No LLM service configured"
- **Fix**: Configure service in `BoilerplateApp.init()`
- **Verify**: Check initialization code

### Network Errors
- **Issue**: API calls fail
- **Fix**: Verify API key is set correctly
- **Verify**: Check environment variables

### UI Issues
- **Issue**: Views not updating
- **Fix**: Ensure ViewModels are `@MainActor`
- **Verify**: Check `@Published` properties

---

## 📖 Reference Documents

| Need Help With... | Read This... |
|------------------|--------------|
| Quick setup | [QUICKSTART.md](QUICKSTART.md) |
| Step-by-step guide | [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) |
| Architecture understanding | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Feature overview | [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) |
| General info | [README.md](README.md) |

---

## 🎯 Success Criteria

Your setup is successful when:
- ✅ App builds without errors
- ✅ Onboarding flow works
- ✅ Chat sends/receives messages
- ✅ History saves conversations
- ✅ Settings work correctly
- ✅ No crashes during normal use
- ✅ App looks branded

---

## 🎓 Tips for Success

1. **Follow the order**: Phases are designed to build on each other
2. **Test frequently**: Don't wait until the end to test
3. **Read the TODOs**: Code has helpful comments throughout
4. **Use the guides**: Refer to documentation when stuck
5. **Start simple**: Get basics working before adding features
6. **Commit often**: Use git to track your changes
7. **Ask questions**: Check documentation or search online

---

**Ready to start? Begin with Phase 1! 🚀**

*Last updated: January 12, 2026*
