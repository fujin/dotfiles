#!/usr/bin/env bash
set -u

export PATH="$HOME/.local/share/mise/shims:$PATH"

report="${TMPDIR:-/tmp}/codex-post-tool-quality.$$"
failures=0
: > "$report"
trap 'rm -f "$report"' EXIT

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  cd "$repo_root" || exit 0
fi

list_changed_files() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  {
    if git rev-parse --verify HEAD >/dev/null 2>&1; then
      git diff --name-only --diff-filter=ACMRTUXB HEAD --
    else
      git ls-files --cached --exclude-standard
    fi
    git ls-files --others --exclude-standard
  } | awk 'NF && !seen[$0]++'
}

contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

nearest_dir_with() {
  local file="$1"
  local marker="$2"
  local root="$PWD"
  local dir

  dir="$(dirname "$file")"
  dir="$(cd "$dir" 2>/dev/null && pwd -P)" || return 1

  while [[ "$dir" == "$root"* ]]; do
    if [[ -f "$dir/$marker" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    [[ "$dir" == "$root" ]] && break
    dir="$(dirname "$dir")"
  done

  return 1
}

run_check() {
  local label="$1"
  shift
  local output
  local status

  output="$("$@" </dev/null 2>&1)"
  status=$?
  if [[ $status -ne 0 ]]; then
    {
      printf '\n%s\n' "$label"
      if [[ -n "$output" ]]; then
        printf '%s\n' "$output" | sed -n '1,20p'
      else
        printf '%s\n' "command exited $status with no output"
      fi
    } >> "$report"
    failures=1
  fi
}

run_check_in_dir() {
  local label="$1"
  local dir="$2"
  shift 2
  local output
  local status

  output="$(cd "$dir" && "$@" </dev/null 2>&1)"
  status=$?
  if [[ $status -ne 0 ]]; then
    {
      printf '\n%s\n' "$label"
      if [[ -n "$output" ]]; then
        printf '%s\n' "$output" | sed -n '1,20p'
      else
        printf '%s\n' "command exited $status with no output"
      fi
    } >> "$report"
    failures=1
  fi
}

changed_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] && changed_files+=("$file")
done < <(list_changed_files)

[[ ${#changed_files[@]} -eq 0 ]] && exit 0

ts_files=()
py_files=()
rs_files=()
go_files=()

for file in "${changed_files[@]}"; do
  case "$file" in
    *.ts|*.tsx) ts_files+=("$file") ;;
    *.py) py_files+=("$file") ;;
    *.rs) rs_files+=("$file") ;;
    *.go) go_files+=("$file") ;;
  esac
done

if [[ ${#ts_files[@]} -gt 0 ]] && command -v npx >/dev/null 2>&1; then
  ts_configs=()
  for file in "${ts_files[@]}"; do
    if dir="$(nearest_dir_with "$file" tsconfig.json)"; then
      config="$dir/tsconfig.json"
      contains "$config" "${ts_configs[@]}" || ts_configs+=("$config")
    fi
  done

  if [[ ${#ts_configs[@]} -gt 0 ]]; then
    for config in "${ts_configs[@]}"; do
      run_check_in_dir \
        "TypeScript: npx --no-install tsc -p $config --noEmit --pretty false" \
        "$(dirname "$config")" \
        npx --no-install tsc -p "$config" --noEmit --pretty false
    done
  elif [[ -f package.json ]]; then
    run_check \
      "TypeScript: npx --no-install tsc --noEmit --pretty false" \
      npx --no-install tsc --noEmit --pretty false
  fi
fi

if [[ ${#py_files[@]} -gt 0 ]]; then
  if command -v ruff >/dev/null 2>&1; then
    run_check "Python: ruff check --quiet changed files" ruff check --quiet "${py_files[@]}"
  fi

  if command -v pyright >/dev/null 2>&1; then
    run_check "Python: pyright changed files" pyright "${py_files[@]}"
  fi
fi

if [[ ${#rs_files[@]} -gt 0 ]] && command -v cargo >/dev/null 2>&1; then
  cargo_dirs=()
  for file in "${rs_files[@]}"; do
    if dir="$(nearest_dir_with "$file" Cargo.toml)"; then
      contains "$dir" "${cargo_dirs[@]}" || cargo_dirs+=("$dir")
    fi
  done

  for dir in "${cargo_dirs[@]}"; do
    run_check_in_dir \
      "Rust: cargo check --message-format=short in $dir" \
      "$dir" \
      cargo check --message-format=short
  done
fi

if [[ ${#go_files[@]} -gt 0 ]] && command -v go >/dev/null 2>&1; then
  go_dirs=()
  for file in "${go_files[@]}"; do
    if dir="$(nearest_dir_with "$file" go.mod)"; then
      contains "$dir" "${go_dirs[@]}" || go_dirs+=("$dir")
    fi
  done

  if [[ ${#go_dirs[@]} -eq 0 ]]; then
    go_dirs=("$PWD")
  fi

  for dir in "${go_dirs[@]}"; do
    run_check_in_dir "Go: go test ./... in $dir" "$dir" go test ./...
  done
fi

if [[ $failures -ne 0 ]]; then
  {
    printf '%s\n' "PostToolUse quality checks failed for changed files:"
    sed -n '1,120p' "$report"
  } >&2
  exit 2
fi

exit 0
