# Firebase Quick Start - RoastGPT

## ⚡️ 5-Minute Setup

### Step 1: Add Firebase SDK (2 min)

1. In Xcode: **File → Add Package Dependencies**
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Version: **Up to Next Major** (latest)
4. Select these packages:
   - ✅ `FirebaseAuth`
   - ✅ `FirebaseFirestore`
   - ✅ `FirebaseStorage`
5. Click **Add Package**

### Step 2: Download Config File (1 min)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create project (or use existing)
3. Add iOS app with your Bundle ID
4. Download `GoogleService-Info.plist`
5. Drag it into Xcode project (check "Copy items if needed")
6. **IMPORTANT**: Place it in the `boilerplate/` folder

### Step 3: Enable Firebase Features (2 min)

**In Firebase Console:**

1. **Firestore Database**
   - Build → Firestore Database → Create Database
   - Start in **Test Mode** (30 days)
   - Choose location (e.g., `us-central1`)

2. **Authentication**
   - Build → Authentication → Get Started
   - Sign-in method → Anonymous → Enable

3. **Storage** (Optional, for images)
   - Build → Storage → Get Started
   - Start in Test Mode

### Step 4: Build & Run! ✅

```bash
# Clean build
⌘⇧K

# Build
⌘B

# Run
⌘R
```

---

## 🎯 What You'll See

After setup, the app will:

1. ✅ Auto-initialize Firebase on launch
2. ✅ Sign in anonymously (you'll see user in Firebase Console)
3. ✅ Save roasts to Firestore when you generate them
4. ✅ Show history from Firestore in History tab
5. ✅ Track usage statistics

**Console logs to look for:**
```
✅ Firebase configured
✅ Anonymous sign-in successful: [user-id]
✅ Session saved: [session-id]
✅ Loaded X sessions
```

---

## 📊 View Your Data

**Firestore Collections:**
- `sessions/` - All roast sessions
  - View in: Firebase Console → Firestore → Data
- `usage/` - User statistics
  - Each user's total roasts and token usage

**Authentication:**
- Firebase Console → Authentication → Users
- You'll see anonymous users with UIDs

---

## 🔒 Production Security Rules

**For production, update Firestore rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own sessions
    match /sessions/{sessionId} {
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow read, update, delete: if request.auth != null && 
                                     resource.data.userId == request.auth.uid;
    }
    
    // Users can only access their own usage data
    match /usage/{userId} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == userId;
    }
  }
}
```

---

## 🐛 Troubleshooting

### "GoogleService-Info.plist not found"
- Make sure the file is in your Xcode project
- Check it's added to the app target (File Inspector)
- Clean build folder (⌘⇧K) and rebuild

### "Permission denied" errors
- Check Firestore rules are in Test Mode
- Verify Anonymous Auth is enabled
- Make sure user is authenticated (check console logs)

### "Module not found" errors
- Clean build folder (⌘⇧K)
- Delete Derived Data
- Restart Xcode
- Re-add Firebase packages if needed

---

## 📚 Full Documentation

See `FIREBASE_SETUP.md` for:
- Detailed setup instructions
- Security rules explained
- Data structure details
- Advanced configuration

---

**You're all set! 🎉**

Generate a roast and check Firebase Console to see it saved!
