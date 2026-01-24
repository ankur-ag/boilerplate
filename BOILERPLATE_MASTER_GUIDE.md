# 🚀 Boilerplate Master Setup Guide

This guide covers everything you need to know to take this boilerplate and turn it into a production-ready iOS app.

---

## 1. Core Services Setup

### 🔥 Firebase (Database & Auth)
1. **Create Project**: Go to [Firebase Console](https://console.firebase.google.com/).
2. **Add iOS App**: Use your bundle ID (e.g., `com.yourcompany.appname`).
3. **Download Config**: Place `GoogleService-Info.plist` into the `boilerplate/` root folder and add it to the Xcode project.
4. **Enable Auth**: Enable **Anonymous**, **Google**, and **Apple** providers in the Firebase Auth dashboard.

### 💳 RevenueCat (Subscriptions)
1. **Create Project**: Go to [RevenueCat](https://app.revenuecat.com/).
2. **Add iOS App**: Add your App Store shared secret and bundle ID.
3. **Set Entitlements**: Create an entitlement called `premium`.
4. **API Key**: Add your **Public SDK Key** to the Xcode Environment Variables as `REVENUECAT_API_KEY`.

### 🖼️ ImageKit.io (Image Storage)
1. **Create Account**: Go to [ImageKit.io](https://imagekit.io/).
2. **Get Keys**: Navigate to the Developer Options.
3. **Environment Variables**: Add these to your Xcode Scheme:
   - `IMAGEKIT_PUBLIC_KEY`
   - `IMAGEKIT_PRIVATE_KEY`
   - `IMAGEKIT_URL_ENDPOINT` (e.g., `https://ik.imagekit.io/your_id/`)

### 💬 Slack Integration (Feedback)
1. **Create App**: Go to [Slack API Apps](https://api.slack.com/apps).
2. **Enable Webhooks**: Create an "Incoming Webhook" for a specific channel.
3. **Copy URL**: Paste that URL into `Core/Config/Config.swift`.

---

## 2. Xcode Configuration

### Environment Variables
To keep secrets out of git, we use Xcode Scheme environment variables.
1. **Edit Scheme** (`⌘<`) -> **Run** -> **Arguments**.
2. Add the following keys:
   - `GEMINI_API_KEY` (For AI features)
   - `OPENAI_API_KEY` (Fallback AI)
   - `REVENUECAT_API_KEY`
   - `IMAGEKIT_PUBLIC_KEY`
   - `IMAGEKIT_PRIVATE_KEY`
   - `IMAGEKIT_URL_ENDPOINT`

### Symbol Uploads (dSYM Fix)
We have pre-configured the `.pbxproj` to avoid the "Upload Symbols Failed" error commonly seen with Firebase. If you create a new project from scratch, ensure:
- `DEBUG_INFORMATION_FORMAT` is set to `dwarf-with-dsym`.
- `STRIP_INSTALLED_PRODUCT` is set to `YES` for Release.

---

## 3. Implementation Details

### 🔑 Authentication
- `AuthManager` handles the lifecycle.
- Users are signed in **anonymously** by default.
- Use `authManager.signInWithGoogle()` for social login.

### 💰 Subscriptions
- `SubscriptionManager` uses RevenueCat.
- Check `subscriptionManager.isPremium` to gate features.
- Products are loaded via `loadProducts()`.

### 📤 Image Uploads
- Use `ImageKitService.shared.uploadImage(data, fileName: "id.png")`.
- Returns a permanent URL you can store in Firebase.

### 📣 Feedback
- Use `SlackService.shared.sendFeedback(category: .bug, message: "xxx")`.
- Automatically includes device info and system version.

---

## 4. Launch Checklist
- [ ] Update `Config.swift` with your App Name and Support Email.
- [ ] Replace `GoogleService-Info.plist`.
- [ ] Set your own Bundle ID and Team in Signing & Capabilities.
- [ ] Configure RevenueCat Offerings/Packages in their dashboard.
- [ ] Add your Privacy Policy and Terms URLs to `AppConstants.swift`.

---

**Happy Building! 🚀**
