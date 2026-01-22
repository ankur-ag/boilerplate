# Slack Feedback Integration - Quick Start

## What's New

✅ User feedback now goes directly to Slack instead of email
✅ Rich formatted messages with category badges
✅ Automatic device info collection
✅ Loading states and error handling
✅ Clean, modern UI

## Files Added/Modified

### New Files:
- `Core/Services/SlackService.swift` - Slack webhook integration
- `Core/Config/Config.swift` - Centralized app configuration
- `SLACK_SETUP.md` - Detailed setup instructions

### Modified Files:
- `Features/Settings/FeedbackView.swift` - Updated UI and submission logic

## Next Steps

1. **Set up your Slack webhook** (see SLACK_SETUP.md)
2. **Update Config.swift** with your webhook URL
3. **Test the integration** in the app

## Quick Setup (2 minutes)

```bash
# 1. Get your Slack webhook URL from:
https://api.slack.com/apps → Your App → Incoming Webhooks

# 2. Update the config:
open boilerplate/Core/Config/Config.swift

# 3. Replace this line:
static let slackWebhookURL = "YOUR_SLACK_WEBHOOK_URL_HERE"

# 4. Build and test!
```

## Example Slack Message

When a user submits feedback, your Slack channel will receive:

```
🐛 New Feedback: Report a Bug

Category: Bug
Time: Jan 22, 2026 at 11:08 PM

Message:
The app crashes when I try to regenerate a roast

Device: iPhone
System: iOS 17.2
```

---

**Need help?** Check `SLACK_SETUP.md` for detailed instructions.
