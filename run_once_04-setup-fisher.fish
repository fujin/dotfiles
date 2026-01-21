#!/usr/bin/env fish

# Install Fisher plugin manager if not present
if not functions -q fisher
    echo "Installing Fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end

# Install plugins from fish_plugins file
if test -f ~/.config/fish/fish_plugins
    echo "Installing Fish plugins..."
    fisher update
end

echo "Fisher setup complete"
