# PRIVACY POLICY – Posterized

⚠️ **DISCLAIMER:** This document is provided for informational purposes only and does not constitute legal advice. HYRE Talent Sourcing and Matching GmbH recommends consulting a qualified attorney in Germany or your jurisdiction to ensure full compliance with applicable laws before publishing. This Privacy Policy is not a substitute for professional legal counsel.

---

## 1. Introduction & Data Protection Principles

Posterized (“we,” “our,” “us,” or “Company”) is an AI roasting app operated by **HYRE Talent Sourcing and Matching GmbH**, based in Germany.

We are committed to protecting your privacy. This Privacy Policy explains:

- What personal data we collect.
- How we use and process your data.
- With whom we share your data.
- How long we keep your data.
- Your rights under GDPR, CCPA, and similar laws.

By using Posterized, you agree to the collection and use of information in accordance with this Privacy Policy. If you do not agree, please do not use the App.

---

## 2. Data We Collect

### 2.1 Account Information

When you sign up via Apple Sign-In, we may receive:

- A **pseudonymous Apple user identifier** (Apple ID for the app).
- Your **email address** (if you choose to share it).
- Your **name** (if you choose to share it).
- Basic profile settings you provide in the app, such as:
  - Favorite team.
  - Roast targets (for example, rival teams).
  - Default roast intensity (“mild,” “normal,” “brutal”).

### 2.2 Usage & Analytics Data

We use **Firebase** and similar tools to collect usage and analytics data, including:

- Device and app data:
  - Device model.
  - Operating system version.
  - App version.
  - Language and locale.
  - Approximate region/country (not precise GPS).

- In-app events (examples, not exhaustive):
  - `signup_screen_view`, `signup_completed`, `profile_completed`.
  - `roast_generated` (when AI roasts are created).
  - `roast_shared` (when you share a roast).
  - `paywall_shown`, `paywall_cta_tapped`, `subscription_started`.

- Event parameters:
  - `favorite_team`, `roast_targets`, `default_intensity`.
  - `roast_type` (for example, text vs image).
  - `roast_intensity` (mild/normal/brutal).
  - `input_type` (chat_only, screenshot, mixed).
  - `is_free_user`, `is_first_conversion`, `generation_number`.
  - `roast_batch_id` (internal identifier).
  - `share_channel` (WhatsApp, iMessage, Instagram DM, etc.).
  - `trigger_location` and `paywall_location` (where paywall was shown).
  - `plan_type` and `plan_price` (as metadata from StoreKit/Apple, not raw payment details).

- User properties (where available):
  - `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`.

We use this data to understand how the App is used, measure funnels, improve roasts, and optimize monetization.

### 2.3 Roast Content & Media

When you use Posterized, we collect and store:

- **Images/photos/screenshots** you upload to generate roasts.
- **Text inputs**, such as:
  - Descriptions of friends or situations.
  - Chat snippets you paste.
  - Context for roasts and prompts.
- **AI-generated roasts** and outputs produced by the App.
- Metadata tied to roasts:
  - Timestamp.
  - Roast batch IDs.
  - Model used (for example, Gemini vs GPT‑4o).
  - Selected intensity and input type.

This content is stored in **Firebase Firestore and Firebase Storage**.

### 2.4 Communications & Support

If you contact us directly:

- Via **support@hyretalents.com** or in-app support:
  - We collect your email, message content, and any additional info you provide.
- For **privacy requests** via privacy@hyretalents.com:
  - We collect your email, request details, and related identifiers.

### 2.5 Data We Do NOT Intentionally Collect

We do not intentionally collect:

- Payment card numbers (handled entirely by Apple).
- Government identifiers (for example, SSN).
- Biometric data.
- Health data or other special-category data unless you choose to enter such information in text (we discourage this).
- Personal data from users under 16 (see Section 9).

---

## 3. How We Use Your Data

We use your data for the following purposes:

### 3.1 To Provide and Operate the App

- Create and maintain your account.
- Authenticate you via Apple Sign-In.
- Generate roasts based on your inputs.
- Store and display roast history and images.
- Process subscriptions and entitlements based on data from Apple.

### 3.2 To Improve the App & User Experience

- Understand which features are used, how often, and by which segments.
- Analyze roast behavior by intensity, content type, and sharing channel.
- Diagnose bugs, crashes, and performance issues.
- Test and optimize app flows, paywalls, and onboarding.
- Improve AI prompts and system design to generate better, safer roasts.

### 3.3 To Ensure Safety & Moderation

- Detect potential policy violations (for example, illegal or hateful content).
- Review reported content and make moderation decisions.
- Prevent abuse, fraud, and misuse.
- Maintain a safe environment consistent with our Terms of Service.

### 3.4 To Communicate With You

- Respond to support requests and feedback.
- Notify you of important changes (T&C / Privacy updates, security alerts).
- If you opt in, send occasional product updates or marketing communications (you can opt out at any time).

### 3.5 To Comply With Legal Obligations

- Respond to lawful requests by public authorities.
- Comply with applicable laws and regulations.
- Enforce our Terms of Service and protect our legal rights.

---

## 4. Third-Party AI Processing (Gemini & OpenAI)

Posterized sends certain data to third-party AI providers to generate roasts.

### 4.1 Google Gemini API

**What we send:**

- Images/photos/screenshots you upload.
- Text prompts and context (for example, who is being roasted, jokes, descriptions).

**Why we send it:**

- To have Google’s Gemini models generate or assist in generating roast content, including understanding images.

**Retention & Training (Google side):**

- Under our commercial configuration, data sent to Gemini is **not used to train Google’s general-purpose AI models**.
- Google may retain request and response data for a **limited period (typically up to around 30–60 days)** for:
  - Abuse detection.
  - Security and fraud prevention.
  - Service reliability and debugging.
- After that, data is deleted according to Google’s policies.

### 4.2 OpenAI GPT‑4o

**What we send:**

- Text prompts and contextual information.
- Short textual descriptions of images (if needed), but **not raw images**.

**Why we send it:**

- To have GPT‑4o generate or refine roast text when Gemini is unavailable, unsuitable, or as a fallback.

**Retention & Training (OpenAI side):**

- Under our commercial settings, API inputs and outputs are **not used to train OpenAI’s general models**.
- OpenAI may retain API data for up to **30 days** for:
  - Abuse monitoring.
  - Security and fraud detection.
  - Service reliability.
- After that, data is deleted according to OpenAI’s policies.

### 4.3 Our Own Analytics vs Provider Retention

We do **not** rely on Gemini or OpenAI logs for analytics. Instead:

- We store roast content, metadata, and analytics in our own **Firebase** infrastructure.
- We apply our own retention schedule (see Section 7) to your account data, roast history, and images.

---

## 5. Other Processors & Data Sharing

### 5.1 Processors

We use the following main processors:

- **Apple (App Store / StoreKit):**  
  Handles all payments and subscriptions. We receive limited subscription status data (for example, active/expired, product ID).

- **Google Firebase (Firestore, Storage, Analytics, Crashlytics):**  
  Stores account data, roast history, images, and analytics events. Provides analytics and crash reporting.

- **Google Gemini API:**  
  Processes your images and context to generate roasts.

- **OpenAI GPT‑4o API:**  
  Processes your text prompts and context for roasts.

Each of these providers processes your data on our behalf in accordance with their own terms and privacy policies.

### 5.2 No Sale of Data

We do **not**:

- Sell your personal data to third parties.
- Rent, trade, or otherwise monetize your personal data outside normal app operations.

We may share **aggregated, anonymized statistics** (for example, number of roasts per day, share rate by channel) with partners or in public materials, but this data cannot be linked back to you.

### 5.3 Legal & Safety Disclosures

We may disclose your data if required by law or if we believe in good faith that such disclosure is reasonably necessary to:

- Comply with legal obligations or court orders.
- Respond to lawful requests by public authorities.
- Protect the rights, property, or safety of our users, the public, or Posterized.

---

## 6. International Data Transfers

Posterized is operated from Germany but uses global services such as Google and OpenAI.

Your data may be transferred to and processed in countries outside your own, including the **United States** and other countries where our processors operate.

Where required by GDPR, we rely on mechanisms such as:

- Standard Contractual Clauses (SCCs).
- Data processing agreements with our vendors.
- Other appropriate safeguards.

By using the App, you acknowledge and agree to these international transfers, subject to the safeguards described.

---

## 7. Data Retention & Deletion

### 7.1 Our Retention (Firebase & Internal Systems)

**Account data & roast history (including images):**

- We keep your account data, roast text, associated metadata, and images **for as long as your account is active**.
- If you delete your account, we delete your account data and associated roasts/images from active systems **within 30 days**.
- Regardless of account status, we do not keep identifiable account/roast/image data for **more than 12 months after your last activity**, whichever comes first.
- After that period, data is either:
  - Deleted, or
  - Anonymized/aggregated so it can no longer be linked to you.

**Personal analytics/log data (tied to your user ID):**

- Kept for up to **12 months** for:
  - Product analytics.
  - Fraud/abuse detection.
  - Debugging and performance analysis.
- After 12 months, we aggregate or anonymize this data.

**Aggregated and anonymized data:**

- Non-identifiable statistics (for example, total roasts per week, overall intensity distribution) may be kept **longer than 12 months**.
- This data cannot be traced back to you as an individual.

**Support & moderation records:**

- Support emails and moderation-related records (including reported content) may be kept for up to **2 years** for:
  - Compliance.
  - Safety and audit purposes.
- After 2 years, they are deleted or anonymized, unless a longer period is required by law.

### 7.2 Provider Retention (Gemini & OpenAI)

As described in Section 4:

- **Google Gemini:** May retain request/response data for up to around **30–60 days** for security and abuse monitoring.
- **OpenAI GPT‑4o:** May retain API data for up to **30 days** for security and abuse monitoring.

We do not control these periods beyond choosing privacy-friendly configurations available to us.

---

## 8. Your Rights (GDPR, CCPA, etc.)

Depending on where you live, you may have some or all of the following rights:

### 8.1 Right of Access

You can request:

- Confirmation whether we process your personal data.
- A copy of the personal data we hold about you.

### 8.2 Right to Rectification

You can request correction of inaccurate or incomplete data. Many profile fields can be edited directly in the App (for example, favorite team, preferences).

### 8.3 Right to Deletion (“Right to be Forgotten”)

You can request that we delete your personal data, subject to certain exceptions (for example, where we must keep data for legal obligations).

### 8.4 Right to Restrict Processing

You can request we limit how we process your data (for example, pause analytics on your account), though this may affect the functionality of the App.

### 8.5 Right to Data Portability

You can request your data in a machine-readable format (such as JSON or CSV) so you can transfer it to another service where feasible.

### 8.6 Right to Object

You can object to certain types of processing, such as:

- Direct marketing (if we send
