if command -sq mise
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
end

if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
else if test -x /usr/local/bin/brew
    /usr/local/bin/brew shellenv | source
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

    alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

    # kubectl-shell_ctx hook fish | source
    # flux completion fish | source
    # flux-operator completion fish | source
end

export EDITOR="cursor -w"
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ajchristensen/google-cloud-sdk/path.fish.inc' ]
    . '/Users/ajchristensen/google-cloud-sdk/path.fish.inc'
end
export PATH="$HOME/.local/bin:$PATH"

if test -d "$HOME/.bun"
    set --export BUN_INSTALL "$HOME/.bun"
    if not contains -- "$BUN_INSTALL/bin" $PATH
        set --export PATH $BUN_INSTALL/bin $PATH
    end
end
