# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io/).

## What's included

- **Shell**: Fish, Starship prompt, Atuin history
- **Editor**: Neovim (LazyVim), tmux
- **Terminal**: Ghostty
- **Tools**: mise, git, gh
- **AI**: Claude Code, Codex CLI

## Quick start

```bash
# Install chezmoi (via mise)
mise use -g chezmoi

# Initialize from this repo
chezmoi init fujin/dotfiles

# Preview changes
chezmoi diff

# Apply
chezmoi apply
```

## Bootstrap on new machine

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply fujin
```

## Usage

```bash
# Add a new file
chezmoi add ~/.config/something/config.toml

# Edit a managed file
chezmoi edit ~/.config/something/config.toml

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Update from remote
chezmoi update
```
