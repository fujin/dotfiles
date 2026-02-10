#!/usr/bin/env fish

# Install Fisher plugin manager if not present
if not functions -q fisher
    echo "Installing Fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end

# Install plugins from fish_plugins file
set plugins_file "$HOME/.config/fish/fish_plugins"
if test -f $plugins_file
    echo "Installing Fish plugins from $plugins_file..."
    set plugins (string split \n (cat $plugins_file) | string trim | string match -rv '^(#|$)')
    if test (count $plugins) -gt 0
        fisher install $plugins
    else
        echo "No plugins declared in $plugins_file"
    end
else
    echo "No fish_plugins file found at $plugins_file"
end

echo "Fisher setup complete"
