# Shell profiles

Profiles are yuurei's Windows Terminal-style shell picker: one click (or one
keybind) to open a tab running a different shell — or a fully different
configuration. A profile is either **auto-detected** (yuurei found the shell
on your system) or **user-defined** (a config-overlay file you wrote).

## Opening a profile

- The **chevron** next to the **+** new-tab button drops the profile menu.
- **Ctrl+Shift+1..9** opens the 1st–9th profile in menu order (user profiles
  first, alphabetically, then detected ones). If you bound that chord to
  something else in your config, your binding wins.
- The **command palette** (Ctrl+Shift+P) lists every profile.
- A tab opened under a profile is labeled with the profile name, and splits
  created inside it inherit the profile. With `windows-restore-session`
  enabled, restored tabs reopen under their profile.

The plain **+** button (and Ctrl+Shift+T) always opens your base
configuration — profiles never change what the default new tab does.

## Auto-detected profiles

Scanned on first menu open, no setup needed:

- **cmd**, **PowerShell** (Windows PowerShell 5.1), **pwsh** (PowerShell 7+),
  **Nushell**, and **Git Bash** — whichever are installed;
- one profile per **WSL distro** (from `wsl -l`).

## User profiles

Drop a config fragment at:

```
%LOCALAPPDATA%\ghostty\profiles\<name>.conf
```

The file name (minus `.conf`) is the profile name. The contents are ordinary
Ghostty config keys, applied **on top of your base config** for surfaces
spawned under that profile — exactly as if those lines were appended to the
end of your config file. That means *any* option works per-profile: command,
theme, font, padding, colors, keybinds, working directory, ...

New files appear the next time the menu opens after a config reload; no
restart needed.

### Examples

`%LOCALAPPDATA%\ghostty\profiles\Ubuntu Dev.conf` — a WSL distro with its own
look:

```ini
command = wsl.exe -d Ubuntu
working-directory = inherit
theme = gruvbox-dark
font-size = 12
```

`%LOCALAPPDATA%\ghostty\profiles\prod-box.conf` — an SSH session that is
visibly not your local shell:

```ini
command = ssh admin@prod.example.com
background = #331111
windows-titlebar-thin = true
```

`%LOCALAPPDATA%\ghostty\profiles\python.conf` — a REPL scratchpad:

```ini
command = python
confirm-close-surface = false
```

## Shadowing

A user profile whose name matches an auto-detected one (case-insensitive)
**replaces** it in the menu. `cmd.conf` lets you own what "cmd" means — add a
`command = cmd /k clink inject`, a theme, whatever — while keeping the
familiar entry.
