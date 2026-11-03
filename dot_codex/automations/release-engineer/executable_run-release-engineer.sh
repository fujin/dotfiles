#!/usr/bin/env bash
set -euo pipefail

prompt_file="${CODEX_RELEASE_ENGINEER_PROMPT:-$HOME/.codex/automations/release-engineer/prompt.md}"
run_root="${CODEX_RELEASE_ENGINEER_OUT_DIR:-$HOME/.codex/automations/release-engineer/runs}"
sandbox="${CODEX_RELEASE_ENGINEER_SANDBOX:-workspace-write}"
approval="${CODEX_RELEASE_ENGINEER_APPROVAL:-never}"

default_repos=(
  "/Users/aj/dev/github/nvidia-lpu/watchpost"
  "/Users/aj/dev/github/nvidia-lpu/clutch"
)

if [[ -n "${CODEX_RELEASE_ENGINEER_REPOS:-}" ]]; then
  IFS=: read -r -a repos <<<"$CODEX_RELEASE_ENGINEER_REPOS"
else
  repos=("${default_repos[@]}")
fi

if [[ ! -f "$prompt_file" ]]; then
  echo "missing prompt file: $prompt_file" >&2
  exit 2
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI not found on PATH" >&2
  exit 2
fi

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
out_dir="$run_root/$stamp"
mkdir -p "$out_dir"

for repo in "${repos[@]}"; do
  if [[ ! -d "$repo/.git" ]] && ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
    echo "skip non-git repository: $repo" >&2
    continue
  fi

  repo_name="$(basename "$repo")"
  out_file="$out_dir/$repo_name.md"
  echo "checking $repo" >&2

  codex exec \
    --sandbox "$sandbox" \
    --ask-for-approval "$approval" \
    --cd "$repo" \
    --output-last-message "$out_file" \
    - <"$prompt_file"
done

echo "$out_dir"
