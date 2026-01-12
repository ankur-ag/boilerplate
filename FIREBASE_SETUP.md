# Firebase Setup for RoastGPT

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add Project** or select existing project
3. Enter project name: `RoastGPT` (or your choice)
4. Disable Google Analytics (optional for now)
5. Click **Create Project**

## Step 2: Add iOS App to Firebase

1. In Firebase Console, click the iOS icon (⊕ Add app)
2. Enter your **iOS Bundle ID**: Check in Xcode → Target → General → Bundle Identifier
   - Should be something like: `com.yourname.boilerplate`
3. Enter **App Nickname**: `RoastGPT`
4. Skip App Store ID for now
5. Click **Register App**

## Step 3: Download GoogleService-Info.plist

1. Download the `GoogleService-Info.plist` file
2. **IMPORTANT**: Add it to your Xcode project:
   - Drag it into Xcode project navigator
   - Check "Copy items if needed"
   - Select your app target
   - Place it in the `boilerplate/` folder (same level as `Info.plist`)

## Step 4: Add Firebase SDK via Swift Package Manager

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
3. Select version: **Up to Next Major Version** (10.0.0 or latest)
4. Click **Add Package**
5. Select the following products:
   - ✅ `FirebaseAuth`
   - ✅ `FirebaseFirestore`
   - ✅ `FirebaseStorage`
   - ✅ `FirebaseAnalytics` (optional)
6. Click **Add Package**

## Step 5: Enable Firestore Database

1. In Firebase Console, go to **Build → Firestore Database**
2. Click **Create Database**
3. Select **Start in Test Mode** (for development)
   - Test mode rules expire in 30 days
   - We'll update to production rules later
4. Choose a Firestore location (e.g., `us-central1`)
5. Click **Enable**

## Step 6: Enable Anonymous Authentication

1. In Firebase Console, go to **Build → Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Click **Anonymous**
5. Toggle **Enable**
6. Click **Save**

## Step 7: Enable Firebase Storage (Optional - for images)

1. In Firebase Console, go to **Build → Storage**
2. Click **Get Started**
3. Select **Start in Test Mode**
4. Click **Next** and **Done**

## Step 8: Update Firestore Security Rules

For development, use these rules (in Firebase Console → Firestore → Rules):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all authenticated users (including anonymous) to read/write their own data
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    
    match /usage/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

For production, use stricter rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Sessions: Users can only access their own sessions
    match /sessions/{sessionId} {
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow read, update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    
    // Usage: Users can only access their own usage data
    match /usage/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 9: Update Storage Security Rules (Optional)

In Firebase Console → Storage → Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 10: Verify Setup in Xcode

After completing the above steps, run the app and check the console for:

```
✅ Firebase configured successfully
✅ Anonymous sign-in successful
```

---

## Firestore Data Structure

### Collections

#### `sessions/{sessionId}`
```json
{
  "id": "uuid-string",
  "userId": "firebase-auth-uid",
  "inputText": "Original input text",
  "roastText": "Generated roast",
  "imageURL": "https://...", // optional
  "ocrText": "Extracted text from image", // optional
  "timestamp": Timestamp,
  "source": "text" | "image"
}
```

#### `usage/{userId}`
```json
{
  "userId": "firebase-auth-uid",
  "roastsGenerated": 42,
  "lastRoastAt": Timestamp,
  "totalTokensUsed": 15000
}
```

---

## Testing Firebase

1. Run the app
2. Generate a roast
3. Check Firebase Console → Firestore → Data
4. You should see a new document in `sessions/` collection
5. Check Authentication → Users for anonymous user

---

## Troubleshooting

### "GoogleService-Info.plist not found"
- Make sure the file is in your Xcode project
- Check it's added to the app target
- Clean build folder (⌘⇧K) and rebuild

### "Pod installation error"
- We're using SPM, not CocoaPods
- If you have a Podfile, you can remove it

### "Permission denied" in Firestore
- Check your Firestore security rules
- Verify anonymous auth is enabled
- Check user is authenticated before writing

### "Module 'Firebase' not found"
- Make sure you added Firebase packages via SPM
- Clean and rebuild (⌘⇧K, then ⌘B)

---

## Next Steps

After Firebase is configured:
1. ✅ Initialize Firebase in app
2. ✅ Implement anonymous sign-in
3. ✅ Save roasts to Firestore
4. ✅ Load history from Firestore
5. ✅ (Optional) Upload images to Storage
