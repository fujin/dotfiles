#!/bin/sh
set -eu
umask 077

if [ ! -t 0 ] || [ ! -t 1 ]; then
    printf 'error: run this setup interactively in Terminal; never put the passphrase in chat\n' >&2
    exit 1
fi

agent_dir="$HOME/.ssh/devvm-agent"
agent_socket="$agent_dir/agent.sock"
agent_key="$agent_dir/id_ed25519"
if [ -L "$agent_dir" ] || [ -L "$agent_key" ] || [ -L "$agent_key.pub" ]; then
    printf 'error: refusing a symlinked key or agent directory\n' >&2
    exit 1
fi
/bin/mkdir -p "$agent_dir"
/bin/chmod 700 "$agent_dir"

if [ ! -e "$agent_key" ] && [ ! -e "$agent_key.pub" ]; then
    printf 'Create a dedicated devvm key. Enter a NONEMPTY passphrase below.\n'
    /usr/bin/ssh-keygen -t ed25519 -a 100 -f "$agent_key" -C "devvm-achristensen-codex"
elif [ ! -f "$agent_key" ] || [ ! -f "$agent_key.pub" ]; then
    printf 'error: incomplete existing key pair; preserved without replacement\n' >&2
    exit 1
else
    printf 'Existing dedicated key preserved.\n'
fi
/bin/chmod 600 "$agent_key" "$agent_key.pub"
if /usr/bin/ssh-keygen -y -P '' -f "$agent_key" >/dev/null 2>&1; then
    printf 'error: this key has no passphrase. Add one with ssh-keygen -p -f "%s", then rerun setup.\n' "$agent_key" >&2
    exit 1
fi

agent_domain="gui/$(/usr/bin/id -u)"
if ! /bin/launchctl print "$agent_domain/com.aj.devvm-ssh-agent" >/dev/null 2>&1; then
    /bin/launchctl bootstrap "$agent_domain" "$HOME/Library/LaunchAgents/com.aj.devvm-ssh-agent.plist"
fi
agent_ready=false
for attempt in 1 2 3 4 5; do
    agent_status=0
    SSH_AUTH_SOCK="$agent_socket" /usr/bin/ssh-add -l >/dev/null 2>&1 || agent_status=$?
    case "$agent_status" in 0|1) agent_ready=true; break ;; esac
    /bin/sleep 1
done
if [ "$agent_ready" != true ]; then
    printf 'error: launchd agent did not become available\n' >&2
    exit 1
fi

printf '\nEnter the key passphrase once more to save it in macOS Keychain.\n'
SSH_AUTH_SOCK="$agent_socket" /usr/bin/ssh-add --apple-use-keychain "$agent_key"
SSH_AUTH_SOCK="$agent_socket" /usr/bin/ssh-add -T "$agent_key.pub"
printf '\nDedicated key loaded and local signing verified. Tell Codex setup is ready.\n'
/usr/bin/ssh-keygen -lf "$agent_key.pub"
