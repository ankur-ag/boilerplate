# Adding Basketball Crowd Cheer Sound

## Required Sound File

You need to add a basketball crowd cheer sound effect to the project.

### Where to Find Free Sound Effects:

1. **Freesound.org** (https://freesound.org)
   - Search for "basketball crowd cheer" or "arena crowd cheer"
   - Filter by Creative Commons licenses
   - Download as MP3

2. **Pixabay** (https://pixabay.com/sound-effects)
   - Search for "crowd cheer" or "basketball"
   - All sounds are free for commercial use

3. **Zapsplat** (https://www.zapsplat.com)
   - Search for "basketball crowd" or "sports cheer"
   - Free with attribution

### Recommended Search Terms:
- "basketball crowd cheer"
- "arena crowd roar"
- "sports crowd celebration"
- "basketball game cheer"

### How to Add the Sound:

1. Download a crowd cheer sound effect (MP3 format)
2. Rename it to `crowd_cheer.mp3`
3. Add it to the project:
   - In Xcode, right-click on the project navigator
   - Select "Add Files to boilerplate..."
   - Navigate to your downloaded sound file
   - Make sure "Copy items if needed" is checked
   - Select your target (boilerplate)
   - Click "Add"

4. Verify the file is in the project:
   - The file should appear in the project navigator
   - Check that it's included in the target's "Copy Bundle Resources" build phase

### Sound Specifications:
- **Format**: MP3 or M4A
- **Duration**: 2-5 seconds recommended
- **Volume**: Medium to loud (the app will handle volume)
- **Type**: Crowd cheer, celebration, or roar

### Alternative:
If you can't find a suitable sound, you can:
1. Use a different sound effect name in `AudioManager.swift`
2. Or disable the sound by commenting out the `AudioManager.shared.playCrowdCheer()` call

The sound will play automatically when an image roast is generated!
