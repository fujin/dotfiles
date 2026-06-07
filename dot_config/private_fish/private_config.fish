set -l open_files_limit 65536
set -l current_open_files_limit (ulimit -n)
if test "$current_open_files_limit" != "unlimited"; and test "$current_open_files_limit" -lt "$open_files_limit"
    ulimit -n $open_files_limit 2>/dev/null
end

if test -d "$HOME/.local/bin"
    fish_add_path --prepend --move "$HOME/.local/bin"
end

set --export MISE_GITHUB_USE_GIT_CREDENTIALS 1
set -l mise_bin
if test -x "$HOME/.local/bin/mise"
    set mise_bin "$HOME/.local/bin/mise"
else if command -sq mise
    set mise_bin (command -s mise)
end

if test -n "$mise_bin"
    $mise_bin activate fish | source
end

if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
else if test -x /usr/local/bin/brew
    /usr/local/bin/brew shellenv | source
end

if test -d "$HOME/.local/bin"
    fish_add_path --prepend --move "$HOME/.local/bin"
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    if command -sq atuin
        atuin init fish | source
    end

    if command -sq starship
        starship init fish | source
    end

    if command -sq jump
        jump shell fish | source
    end

    if command -sq direnv
        direnv hook fish | source
    end

    set -Ux EZA_STANDARD_OPTIONS --long --all

    if test -x /Applications/Tailscale.app/Contents/MacOS/Tailscale; and not command -sq tailscale
        alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
    end

    # kubectl-shell_ctx hook fish | source
    # flux completion fish | source
    # flux-operator completion fish | source
end

export EDITOR="nvim"
function codex --wraps codex
    set -lx CODEX_GITHUB_MCP_BEARER_TOKEN (gh auth token)
    command codex $argv
end

# The next line updates PATH for the Google Cloud SDK.
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    . "$HOME/google-cloud-sdk/path.fish.inc"
end

if test -d "$HOME/.bun"
    set --export BUN_INSTALL "$HOME/.bun"
    if not contains -- "$BUN_INSTALL/bin" $PATH
        set --export PATH $BUN_INSTALL/bin $PATH
    end
end
