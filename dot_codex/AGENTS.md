# Instructions for Codex agents

## Tools

* Prefer installing tools with `mise` over `brew`
* Chezmoi is used to manage dotfiles with the repository located at ~/.local/config/chezmoi

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
