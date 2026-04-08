[Title]: VS Code | How to Migrate from VS Code to Zed
[Meta Description]:

Search docs…
S

Download
• Welcome• Getting Started• Installation• • Update• Uninstall• Troubleshooting• AI• Overview• Agent Panel• • Tools• Tool Permissions• External Agents• Inline Assistant• Edit Prediction• Rules• Model Context Protocol• Configuration• • LLM Providers• Agent Settings• Subscription• • Models• Plans and Usage• Billing• Working with Code• Editing Code• • Code Completions• Snippets• Diagnostics & Quick Fixes• Multibuffers• Finding & Navigating• • Command Palette• Outline Panel• Tab Switcher• Running & Testing• • Terminal• Tasks• Debugger• REPL• Git• Modelines• Collaboration• Overview• • Channels• Contacts and Private Calls• Remote Development• Overview• Environment Variables• Dev Containers• Platform Support• macOS• Windows• Linux• Customization• Appearance• • Themes• Icon Themes• Fonts & Visual Tweaks• Keybindings• • Vim Mode• Helix Mode• Language Support• All Languages• Configuring Languages• • Toolchains• Semantic Tokens• Ansible• AsciiDoc• Astro• Bash• Biome• C• C++• C#• Clojure• CSS• Dart• Deno• Diff• Docker• Elixir• Elm• Emmet• Erlang• Fish• GDScript• Gleam• GLSL• Go• Groovy• Haskell• Helm• HTML• Java• JavaScript• Julia• JSON• Jsonnet• Kotlin• Lua• Luau• Makefile• Markdown• Nim• OCaml• OpenTofu• PHP• PowerShell• Prisma• Proto• PureScript• Python• R• Rego• ReStructuredText• Racket• Roc• Ruby• Rust• Scala• Scheme• Shell Script• SQL• Svelte• Swift• Tailwind CSS• Terraform• TOML• TypeScript• Uiua• Vue• XML• YAML• Yara• Yarn• Zig• Extensions• Overview• Installing Extensions• Developing Extensions• Extension Capabilities• Language Extensions• Debugger Extensions• Theme Extensions• Icon Theme Extensions• Snippets Extensions• Agent Server Extensions• MCP Server Extensions• Coming From…• VS Code• IntelliJ IDEA• PyCharm• WebStorm• RustRover• Reference• All Settings• All Actions• CLI Reference• Account & Privacy• Authenticate• Roles• Privacy and Security• • Worktree Trust• AI Improvement• Telemetry• Developing Zed• Developing Zed• • macOS• Linux• Windows• FreeBSD• Using Debuggers• Performance• Glossary• Release Notes• Debugging Crashes

How to Migrate from VS Code to Zed

This guide explains how to move from VS Code to Zed without rebuilding your workflow.
It covers which settings import automatically, which shortcuts map cleanly, and which behaviors differ so you can adjust quickly.

Install Zed

Zed is available on macOS, Windows, and Linux.
For macOS, you can download it from zed.dev/download, or install via Homebrew:
brew install zed-editor/zed/zed
For most Linux users, the easiest way to install Zed is through our installation script:
curl -f https://zed.dev/install.sh | sh
After installation, you can launch Zed from your Applications folder (macOS) or directly from the terminal (Linux) using:
zed .
This opens the current directory in Zed.

Import Settings from VS Code

During setup, you have the option to import key settings from VS Code. Zed imports the following settings:

Settings Imported from VS Code

The following VS Code settings are automatically imported when you use Import Settings from VS Code:
Editor
VS Code SettingZed Setting
editor.fontFamilybuffer_font_family
editor.fontSizebuffer_font_size
editor.fontWeightbuffer_font_weight
editor.tabSizetab_size
editor.insertSpaceshard_tabs (inverted)
editor.wordWrapsoft_wrap
editor.wordWrapColumnpreferred_line_length
editor.cursorStylecursor_shape
editor.cursorBlinkingcursor_blink
editor.renderLineHighlightcurrent_line_highlight
editor.lineNumbersgutter.line_numbers, relative_line_numbers
editor.showFoldingControlsgutter.folds
editor.minimap.enabledminimap.show
editor.minimap.autohideminimap.show
editor.minimap.showSliderminimap.thumb
editor.minimap.maxColumnminimap.max_width_columns
editor.stickyScroll.enabledsticky_scroll.enabled
editor.scrollbar.horizontalscrollbar.axes.horizontal
editor.scrollbar.verticalscrollbar.axes.vertical
editor.mouseWheelScrollSensitivityscroll_sensitivity
editor.fastScrollSensitivityfast_scroll_sensitivity
editor.cursorSurroundingLinesvertical_scroll_margin
editor.hover.enabledhover_popover_enabled
editor.hover.delayhover_popover_delay
editor.parameterHints.enabledauto_signature_help
editor.multiCursorModifiermulti_cursor_modifier
editor.selectionHighlightselection_highlight
editor.roundedSelectionrounded_selection
editor.find.seedSearchStringFromSelectionseed_search_query_from_cursor
editor.rulerswrap_guides
editor.renderWhitespaceshow_whitespaces
editor.guides.indentationindent_guides.enabled
editor.linkedEditinglinked_edits
editor.autoSurrounduse_auto_surround
editor.formatOnSaveformat_on_save
editor.formatOnPasteauto_indent_on_paste
editor.formatOnTypeuse_on_type_format
editor.trimAutoWhitespaceremove_trailing_whitespace_on_save
editor.suggestOnTriggerCharactersshow_completions_on_input
editor.suggest.showWordscompletions.words
editor.inlineSuggest.enabledshow_edit_predictions

Files & Workspace
VS Code SettingZed Setting
files.autoSaveautosave
files.autoSaveDelayautosave.milliseconds
files.insertFinalNewlineensure_final_newline_on_save
files.associationsfile_types
files.watcherExcludefile_scan_exclusions
files.watcherIncludefile_scan_inclusions
files.simpleDialog.enableuse_system_path_prompts
search.smartCaseuse_smartcase_search
search.useIgnoreFilessearch.include_ignored

Terminal
VS Code SettingZed Setting
terminal.integrated.fontFamilyterminal.font_family
terminal.integrated.fontSizeterminal.font_size
terminal.integrated.lineHeightterminal.line_height
terminal.integrated.cursorStyleterminal.cursor_shape
terminal.integrated.cursorBlinkingterminal.blinking
terminal.integrated.copyOnSelectionterminal.copy_on_select
terminal.integrated.scrollbackterminal.max_scroll_history_lines
terminal.integrated.macOptionIsMetaterminal.option_as_meta
terminal.integrated.{platform}Execterminal.shell
terminal.integrated.env.{platform}terminal.env

Tabs & Panels
VS Code SettingZed Setting
workbench.editor.showTabstab_bar.show
workbench.editor.showIconstabs.file_icons
workbench.editor.tabActionLocationtabs.close_position
workbench.editor.tabActionCloseVisibilitytabs.show_close_button
workbench.editor.focusRecentEditorAfterClosetabs.activate_on_close
workbench.editor.enablePreviewpreview_tabs.enabled
workbench.editor.enablePreviewFromQuickOpenpreview_tabs.enable_preview_from_file_finder
workbench.editor.enablePreviewFromCodeNavigationpreview_tabs.enable_preview_from_code_navigation
workbench.editor.editorActionsLocationtab_bar.show_tab_bar_buttons
workbench.editor.limit.enabled / valuemax_tabs
workbench.editor.restoreViewStaterestore_on_file_reopen
workbench.statusBar.visiblestatus_bar.show

Project Panel (File Explorer)
VS Code SettingZed Setting
explorer.compactFoldersproject_panel.auto_fold_dirs
explorer.autoRevealproject_panel.auto_reveal_entries
explorer.excludeGitIgnoreproject_panel.hide_gitignore
problems.decorations.enabledproject_panel.show_diagnostics
explorer.decorations.badgesproject_panel.git_status

Git
VS Code SettingZed Setting
git.enabledgit_panel.button
git.defaultBranchNamegit_panel.fallback_branch_name
git.decorations.enabledgit.inline_blame, project_panel.git_status
git.blame.editorDecoration.enabledgit.inline_blame.enabled

Window & Behavior
VS Code SettingZed Setting
window.confirmBeforeCloseconfirm_quit
window.nativeTabsuse_system_window_tabs
window.closeWhenEmptywhen_closing_with_no_tabs
accessibility.dimUnfocused.enabled / opacityactive_pane_modifiers.inactive_opacity

Other
VS Code SettingZed Setting
http.proxyproxy
npm.packageManagernode.npm_path
telemetry.telemetryLeveltelemetry.metrics, telemetry.diagnostics
outline.iconsoutline_panel.file_icons, outline_panel.folder_icons
chat.agent.enabledagent.enabled
mcpcontext_servers

Zed doesn’t import extensions or keybindings, but this import gets core editor behavior close to your VS Code setup. If you skip that step during setup, you can still import settings manually later via the command palette:
Cmd+Shift+P → Zed: Import VS Code Settings

Set Up Editor Preferences

You can configure most settings in the Settings Editor (cmd-,). For advanced settings, run zed: open settings file from the Command Palette to edit your settings file directly.
Here’s how common VS Code settings translate:
VS CodeZedNotes
editor.fontFamilybuffer_font_familyZed uses Zed Mono by default
editor.fontSizebuffer_font_sizeSet in pixels
editor.tabSizetab_sizeCan override per language
editor.insertSpacesinsert_spacesBoolean
editor.formatOnSaveformat_on_saveWorks with formatter enabled
editor.wordWrapsoft_wrapSupports optional wrap column

Zed also supports per-project settings. You can find these in the Settings Editor as well.

Open or Create a Project

After setup, press Cmd+O (Ctrl+O on Linux) to open a folder. This becomes your workspace in Zed. There's no support for multi-root workspaces or .code-workspace files like in VS Code. Zed keeps it simple: one folder, one workspace.
To start a new project, create a directory using your terminal or file manager, then open it in Zed. The editor will treat that folder as the root of your project.
You can also launch Zed from the terminal inside any folder with:
zed .
Once inside a project, use Cmd+P to jump between files quickly. Cmd+Shift+P (Ctrl+Shift+P on Linux) opens the command palette for running actions / tasks, toggling settings, or starting a collaboration session.
Open buffers appear as tabs across the top. The Project Panel shows your file tree and Git status. Collapse it with Cmd+B for a distraction-free view.

Differences in Keybindings

If you chose the VS Code keymap during onboarding, most shortcuts should already feel familiar.
Here’s a quick reference for where keybindings match and where they differ.

Common Shared Keybindings (Zed <> VS Code)

ActionShortcut
Find filesCmd + P
Run a commandCmd + Shift + P
Search text (project-wide)Cmd + Shift + F
Find symbols (project-wide)Cmd + T
Find symbols (file-wide)Cmd + Shift + O
Toggle left dockCmd + B
Toggle bottom dockCmd + J
Open terminalCtrl + ~
Open file tree explorerCmd + Shift + E
Close current bufferCmd + W
Close whole projectCmd + Shift + W
Refactor: rename symbolF2
Change themeCmd + K, Cmd + T
Wrap textOpt + Z
Navigate open tabsCmd + Opt + Arrow
Syntactic fold / unfoldCmd + Opt + { or }

Different Keybindings (Zed <> VS Code)

ActionVS CodeZed
Open recent projectCtrl + RCmd + Opt + O
Move lines up/downOpt + Up/DownCmd + Ctrl + Up/Down
Split panesCmd + \Cmd + K, Arrow Keys
Expand SelectionShift + Alt + RightOpt + Up

Unique to Zed

ActionShortcutNotes
Toggle right dockCmd + R or Cmd + Alt + B
Syntactic selectionOpt + Up/DownSelects code by structure (e.g., inside braces).

How to Customize Keybindings

To edit your keybindings:
• Open the command palette (Cmd+Shift+P)
• Run Zed: Open Keymap Editor

This opens a list of all available bindings. You can override individual shortcuts, remove conflicts, or build a layout that works better for your setup.
Zed also supports chords (multi-key sequences) like Cmd+K Cmd+C, like VS Code does.

Differences in User Interfaces

No Workspace

VS Code uses a dedicated Workspace concept, with multi-root folders, .code-workspace files, and a clear distinction between “a window” and “a workspace.”
Zed simplifies this model.
In Zed:
• There is no workspace file format. Opening a folder is your project context.
• Zed does not support multi-root workspaces. You can only open one folder at a time in a window.
• Most project-level behavior is scoped to the folder you open. Search, Git integration, tasks, and environment detection all treat the opened directory as the project root.
• Per-project settings are optional. You can add a .zed/settings.json file inside a project to override global settings, but Zed does not use .code-workspace files and won’t import them.
• You can start from a single file or an empty window. Zed doesn’t require you to open a folder to begin editing.

The result is a simpler model:
Open a folder → work inside that folder → no additional workspace layer.

Navigating in a Project

In VS Code, the standard entry point is opening a folder. From there, the left-hand panel is central to navigation.
Zed takes a different approach:
• You can still open folders, but you don’t need to. Opening a single file or even starting with an empty workspace is valid.
• The Command Palette (Cmd+Shift+P) and File Finder (Cmd+P) are primary navigation tools. The File Finder searches files, symbols, and commands across the workspace.
• Instead of a persistent panel, Zed encourages you to:
• Fuzzy-find files by name (Cmd+P)
• Jump directly to symbols (Cmd+Shift+O)
• Use split panes and tabs for context, rather than keeping a large file tree open (though you can do this with the Project Panel if you prefer).

The UI keeps auxiliary panels out of the way so navigation stays centered on code.

Extensions vs. Marketplace

Zed does not offer as many extensions as VS Code. The available extensions are focused on language support, themes, syntax highlighting, and other core editing enhancements.
Several features that typically require extensions in VS Code are built into Zed:
• Real-time collaboration with voice and cursor sharing (no Live Share required)
• AI coding assistance (no Copilot extension needed)
• Built-in terminal panel
• Project-wide fuzzy search
• Task runner with JSON config
• Inline diagnostics and code actions via LSP

You won’t find one-to-one replacements for every VS Code extension, especially if you rely on tools for DevOps, containers, or test runners. Zed's extension catalog is still growing and remains smaller.

Collaboration in Zed vs. VS Code

Unlike VS Code, Zed doesn’t require an extension to collaborate. It’s built into the core experience.
• Open the Collab Panel in the left dock.
• Create a channel and invite your collaborators to join.
• Share your screen or your codebase directly.

Once connected, you’ll see each other's cursors, selections, and edits in real time. Voice chat is included, so you can talk as you work. There’s no need for separate tools or third-party logins.
Learn how Zed uses Zed to plan work and collaborate.

Using AI in Zed

If you’re used to GitHub Copilot in VS Code, you can do the same in Zed. You can also explore other agents through Zed Pro, or bring your own keys and connect without authentication. You can disable AI features entirely if you prefer.

Configuring GitHub Copilot
• Open Settings with Cmd+, (macOS) or Ctrl+, (Linux/Windows)
• Navigate to AI → Edit Predictions
• Click Configure next to "Configure Providers"
• Under GitHub Copilot, click Sign in to GitHub

Once signed in, just start typing. Zed will offer suggestions inline for you to accept.

Additional AI Options

To use other AI models in Zed, you have several options:
• Use Zed’s hosted models, with higher rate limits. Requires authentication and subscription to Zed Pro.
• Bring your own API keys, no authentication needed
• Use external agents like Claude Agent.

Advanced Config and Productivity Tweaks

Zed exposes advanced settings for power users who want to fine-tune their environment.
Here are a few useful tweaks:
Format on Save:
"format_on_save": "on"

Enable direnv support:
"load_direnv": "shell_hook"

Custom Tasks: Define build or run commands in your tasks.json (accessed via command palette: zed: open tasks):
[
{
"label": "build",
"command": "cargo build"
}
]

Bring over custom snippets
Copy your VS Code snippet JSON directly into Zed's snippets folder (zed: configure snippets).

MCP Server Extensions

IntelliJ IDEA
•
Back to Site•
Releases•
Roadmap•
GitHub•
Blog•

Manage Site Cookies

On This PageInstall ZedImport Settings from VS CodeSettings Imported from VS CodeSet Up Editor PreferencesOpen or Create a ProjectDifferences in KeybindingsCommon Shared Keybindings (Zed <> VS Code)Different Keybindings (Zed <> VS Code)Unique to ZedHow to Customize KeybindingsDifferences in User InterfacesNo WorkspaceNavigating in a ProjectExtensions vs. MarketplaceCollaboration in Zed vs. VS CodeUsing AI in ZedConfiguring GitHub CopilotAdditional AI OptionsAdvanced Config and Productivity Tweaks
