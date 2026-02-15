# Instructions for Codex agents

## Git

* Always use conventional commit messages of type feat, fix, deps. Avoid using chore type without explicit confirmation as these aren't releasable units
* Use the gh cli to retrieve pull request reviews and comments
* Do not add extra comments on pull requests when following up, addressing problems
* Prefer squashing a feature branch with many commits using rebase autosquash and fixup commits. Rebase before force pushing with lease.
* When using `gh pr create` or `gh pr edit`, do not pass markdown-rich text via inline shell-quoted `--body` strings
* For PR bodies, use a heredoc with `--body-file -` (or a file passed to `--body-file`) to avoid shell escaping and command-substitution mangling
