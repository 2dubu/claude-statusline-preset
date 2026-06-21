# claude-statusline-preset

Personal Claude Code status bar ([ccstatusline](https://github.com/sirmalloc/ccstatusline)) preset. One `./setup.sh` replicates it on any Mac.

```
repository-name | ⎇ feat/… | Ctx: 255.8k | (+152,-8)
Opus 4.8 (1M) | Thinking: xhigh | Session: 15.0% | Reset: 21m
```

## Install

```bash
git clone https://github.com/2dubu/claude-statusline-preset.git ~/claude-statusline-preset
~/claude-statusline-preset/setup.sh
```

> Clone to a stable path — the repo is the symlink source, so moving it later breaks the links (just re-run `setup.sh` from the new location).

### Or just hand it to an AI agent

Paste this into Claude Code (or any coding agent) and let it do the setup:

```text
Set up my Claude Code status bar from this preset and verify it:

  git clone https://github.com/2dubu/claude-statusline-preset.git ~/claude-statusline-preset
  ~/claude-statusline-preset/setup.sh

setup.sh is idempotent and backs up anything it replaces. It installs ccstatusline,
symlinks the config into ~/.config and ~/.claude/tools, and merges only the `statusLine`
key into ~/.claude/settings.json (other settings are preserved). After it runs, confirm
the status bar shows the model with a `(1M)` tag and the thinking-effort widget, and tell
me if Claude Code needs a refresh to pick it up.
```

### What is setup.sh?

Idempotent (safe to re-run) and backs up anything it replaces:

1. **Install ccstatusline** — drops the bundled build into `~/.claude/tools/ccstatusline/` (`npm pack`, falls back to `npx`).
2. **Symlink the config** — links the two files below into your home dir, so editing on any machine flows straight back to this repo:
   - `home/.config/ccstatusline/settings.json` → `~/.config/ccstatusline/settings.json`
   - `home/.claude/tools/cc-model.js` → `~/.claude/tools/cc-model.js`
3. **Merge statusLine** — updates only the `statusLine` key in `~/.claude/settings.json` (other settings and secrets are preserved; `settings.json.bak` is written).

## Layout

| File | Role |
|---|---|
| `home/.config/ccstatusline/settings.json` | Widget layout — line 1: dir · branch · Ctx · changes / line 2: model · effort · session · reset |
| `home/.claude/tools/cc-model.js` | custom-command helper — model name, plus a ` (1M)` tag on 1M-context sessions. Reads the status JSON from stdin |
| `setup.sh` | One-shot installer |

- **effort** — built-in `thinking-effort` widget → `Thinking: xhigh` (ultracode is officially reported as `xhigh`). Reflects `/effort` changes live.
- **1M** — the built-in Model widget strips the trailing `(...)` from `display_name`, dropping `(1M context)`. `cc-model.js` replaces it to render `Opus 4.8 (1M)`. Non-1M sessions show just the model name.

## Customize

- Widgets (add / reorder / color): open the TUI with `npx ccstatusline@latest`, or edit `home/.config/ccstatusline/settings.json` directly → commit.
- Model display: edit `home/.claude/tools/cc-model.js` (e.g. add a label, or `(1M)` → `1M`).
- **All paths use `~`**, so it's portable across usernames. Don't hard-code absolute paths.

## Uninstall

```bash
rm ~/.config/ccstatusline/settings.json ~/.claude/tools/cc-model.js   # remove symlinks
# restore your previous Claude settings if needed:
mv ~/.claude/settings.json.bak ~/.claude/settings.json
```

## Notes

- These are **display-only** settings — safe even in a public repo (no secrets). Just don't put tokens in custom-command helpers like `cc-model.js`.
- The ccstatusline version is pinned via `CCSL_VER` in `setup.sh`. Bump it and re-run to upgrade.
- ccstatusline: <https://github.com/sirmalloc/ccstatusline>
