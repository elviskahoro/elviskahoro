---
name: download-linkedin-video
description: Download a video from a LinkedIn post URL using yt-dlp at the highest quality possible, rename it concisely, and save to ~/Downloads/videos/ with a timestamped prefix.
---

# Download LinkedIn Video

Download a video from a LinkedIn post and save it with a clean, timestamped filename.

## Input

The user provides a LinkedIn post URL as `$ARGUMENTS`.

## Steps

### 1. Validate the URL

Confirm `$ARGUMENTS` looks like a valid LinkedIn URL (contains `linkedin.com`). If not, ask the user for the correct URL.

### 2. Ensure output directory exists

```bash
mkdir -p ~/Downloads/videos
```

### 3. Download at highest quality

Use yt-dlp to download the best video+audio and merge into mp4:

```bash
yt-dlp \
  -f "bestvideo+bestaudio/best" \
  --merge-output-format mp4 \
  --no-playlist \
  -o "%(title)s.%(ext)s" \
  "$ARGUMENTS"
```

If the download fails, try these fallbacks in order:
- Add `--extractor-args "linkedin:format=dash"` in case the default extractor misses DASH streams
- Try with `--no-check-certificates` if there is a TLS error
- Show the full error output to the user and suggest they check that yt-dlp is up to date (`yt-dlp -U`)

### 4. Rename the file

After download, rename the output file following this convention:

**Format:** `linkedin-YYYYMMDDHHMMSS-concise_summary.mp4`

- `YYYYMMDDHHMMSS` is the current timestamp at time of download
- `concise_summary` is a short, descriptive summary of the video content derived from the video title or LinkedIn post context
- Use lowercase only, underscores between words, no spaces, no special characters
- Keep the summary to 3-5 words maximum

Generate the timestamp:
```bash
TIMESTAMP=$(date +%Y%m%d%H%M%S)
```

Example renames:
- `John Smith on building teams in 2024.mp4` becomes `linkedin-20260411143022-building_teams_advice.mp4`
- `Why AI agents matter - Sarah Chen.mp4` becomes `linkedin-20260411143022-why_ai_agents_matter.mp4`

Move the renamed file to the output directory:
```bash
mv "<downloaded_file>" ~/Downloads/videos/linkedin-${TIMESTAMP}-<concise_summary>.mp4
```

### 5. Confirm

Print the final file path and size:
```bash
ls -lh ~/Downloads/videos/linkedin-${TIMESTAMP}-*.mp4
```

## Requirements

- `yt-dlp` must be installed (`brew install yt-dlp`)
- `ffmpeg` must be installed for merging video+audio streams (`brew install ffmpeg`)

## Important notes

- Always select the highest quality format available, never settle for lower quality
- LinkedIn videos are often served as separate DASH video and audio streams that need merging, which is why ffmpeg is required
- If yt-dlp cannot extract the video (LinkedIn changes their page structure occasionally), suggest the user update yt-dlp first
- Never prompt for cookies or authentication unless yt-dlp explicitly says the video requires login
