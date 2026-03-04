# Instructions for Codex agents

## Languages

* Generally, prefer Go and Rust.
* Try to avoid python.

## Go

* Prefer `alecthomas/kong` for CLI and `knadh/koanf` for configuration sources.
* For rich TUI, use charmbracelet libraries such as `bubbletea`, `lipgloss` and`huh`
* For kubernetes controllers, start with `kubebuilder`

## Kustomize

* Prefer using `patches:` over older style `patchesStrategicMerge:`

## Tools

* Prefer installing tools with `mise` over `brew`
* Chezmoi is used to manage dotfiles with the repository located at ~/.local/config/chezmoi

## Linear

* When working with Linear issues, to track work, use the suggested
  branch names from the Linear issue.
  Pull requests will be automatically linked to the issue.

## Git

* Always use conventional commit messages of type feat, fix, deps.
  Avoid using chore without explicit confirmation as these are not releasable units
* Use the gh cli to retrieve pull request reviews and comments
* Do not add extra comments on pull requests when following up, addressing problems
* Prefer squashing a feature branch with many commits.
  Use rebase autosquash and fixup commits.
  Rebase before force pushing with lease.
* When using `gh pr create` or `gh pr edit`,
  do not pass markdown-rich text via inline shell-quoted `--body` strings
* For PR bodies, use a heredoc with `--body-file -`
  (or a file passed to `--body-file`)
  to avoid shell escaping and command-substitution mangling
