---
name: kilo-cli-colors
description: Guides customization of Kilo Code CLI themes and individual colors via JSON config files, environment variables, and in-app commands. Use when the user wants to change CLI colors, switch themes, create custom themes, or override backgrounds, text, prompts, or UI elements.
---

# Kilo CLI Color Customization

Use this skill when users ask about changing colors in Kilo Code CLI, switching themes, creating custom themes, or overriding default color schemes.

## Quick Theme Switching

**Interactive:** Run `kilo`, type `/themes`, press Enter. Select from available themes (light/dark variants).

**Environment variable:** `KILO_THEME=dark kilo` — applies theme on startup.

**Config file:** Edit `~/.config/kilo/opencode.json` or project `./opencode.json`. Add `"theme": "dark"`. Project config overrides global. Restart CLI.

## Custom Individual Colors

Create a JSON theme file to manually override individual colors (prompts, backgrounds, text, UI elements).

**Paths:**
- Global: `~/.config/opencode/themes/mytheme.json`
- Project: `./.opencode/themes/mytheme.json` (overrides global)

**Theme structure:**

```json
{
  "name": "mytheme",
  "defs": {
    "primary": "#ff6b6b",
    "secondary": "#4ecdc4"
  },
  "colors": {
    "background": "#0a0a0a",
    "text": "#ffffff",
    "prompt": "#4ecdc4",
    "warning": "#ff6b6b",
    "ui-border": "none"
  }
}
```

- **Color values:** Hex (`#rrggbb`), ANSI numbers (0–255), or references to `defs`
- **`"none"`:** Uses terminal default
- **Priority:** Project themes > global themes

## Apply Custom Theme

- **CLI:** Run `kilo`, type `/theme`, select your custom theme
- **Config:** Add `"theme": "mytheme"` to `~/.config/opencode/opencode.json` or project `opencode.json`
- Restart CLI to load changes

## Example: Dark Custom Theme

```json
{
  "name": "dark-custom",
  "colors": {
    "background": "#1a1a1a",
    "text": "#e0e0e0",
    "prompt": "#00ff88",
    "error": "#ff4444",
    "ui-highlight": "#4444ff"
  }
}
```

## Terminal Requirements

Ensure truecolor support: `echo $COLORTERM` should show `truecolor`. If not, set `export COLORTERM=truecolor`. iTerm2 and Alacritty support truecolor by default.

## Troubleshooting

- **Colors not applying:** Check JSON syntax, restart CLI, verify theme file path
- **Washed colors:** Enable truecolor in terminal (iTerm2/Alacritty: use truecolor profile)
