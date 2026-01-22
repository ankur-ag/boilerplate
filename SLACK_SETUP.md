# Slack Feedback Integration

This app includes a built-in feedback system that sends user feedback directly to a Slack channel.

## Setup Instructions

### 1. Create a Slack Incoming Webhook

1. Go to [Slack API Apps](https://api.slack.com/apps)
2. Click **"Create New App"** → **"From scratch"**
3. Name your app (e.g., "Posterized Feedback") and select your workspace
4. In the app settings, go to **"Incoming Webhooks"**
5. Toggle **"Activate Incoming Webhooks"** to ON
6. Click **"Add New Webhook to Workspace"**
7. Select the channel where you want feedback to be posted (e.g., `#app-feedback`)
8. Click **"Allow"**
9. Copy the webhook URL (it will look like: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX`)

### 2. Configure the App

1. Open `boilerplate/Core/Config/Config.swift`
2. Replace `YOUR_SLACK_WEBHOOK_URL_HERE` with your actual webhook URL:

```swift
static let slackWebhookURL = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

### 3. Test the Integration

1. Build and run the app
2. Navigate to **Settings** → **Support & Feedback**
3. Select a category, write a message, and tap **"Submit Feedback"**
4. Check your Slack channel - you should see a formatted message with:
   - Feedback category (Bug, Feature, or General)
   - User's message
   - Device information
   - Timestamp

## Message Format

Feedback messages in Slack will be formatted with:

- 🐛 **Bug reports** - Red accent
- 💡 **Feature requests** - Yellow accent  
- 💬 **General feedback** - Orange accent

Each message includes:
- Category and timestamp
- User's message
- Device model and OS version
- Optional: User email (if authenticated)

## Security Notes

⚠️ **Important:** Never commit your actual Slack webhook URL to version control!

- Add `Config.swift` to `.gitignore` if it contains sensitive URLs
- Use environment variables or a separate config file for production
- Consider using different webhooks for development and production

## Fallback Option

If Slack integration fails or you prefer email, the app still includes a fallback email composer option. You can modify the submit button in `FeedbackView.swift` to offer both options.

## Troubleshooting

**Feedback not appearing in Slack?**
- Verify the webhook URL is correct
- Check that the webhook is enabled in your Slack app settings
- Ensure the app has internet connectivity
- Check Xcode console for error messages

**Want to customize the message format?**
- Edit `SlackService.swift` → `buildSlackPayload()` method
- Slack uses [Block Kit](https://api.slack.com/block-kit) for message formatting
