# Instructions for Codex agents

## Tools

* Prefer installing tools with `mise` over `brew`
* In repositories with `mise.toml`, inspect and prefer the checked-in `mise`
  tasks for setup, fixtures, tests, and builds before running raw toolchain
  commands. If a raw command such as `cargo test` fails because generated
  fixtures or repo setup are missing, run the relevant `mise` task, or the
  checked-in task script if mise trust blocks execution, and retry before
  reporting a blocker.
* Chezmoi is used to manage dotfiles with the repository located at ~/.local/config/chezmoi

## Git

* Always use conventional commit messages of type feat, fix, deps.
  Avoid using chore without explicit confirmation as these are not releasable units
* Prefer the GitHub connector for pull request creation, review/comment
  retrieval, and PR comments when available.
  Use `gh` only as a fallback for unsupported GitHub operations.
* Prefer the configured Git MCP server for supported Git operations:
  status, diff, log, show, branch, worktree, add, commit, stash, fetch, pull,
  push, merge, rebase, tag, and blame.
  Use shell git when the MCP lacks the exact operation, the output is
  insufficient, or a complex CLI workflow is safer.
* Do not add extra comments on pull requests when following up, addressing problems
* When multiple agents, tools, or review lanes inspect the same pull request,
  only the designated coordinator may write to GitHub. Review lanes must return
  findings privately to the coordinator and must not submit reviews, inline
  comments, approvals, or change requests. The coordinator deduplicates all
  findings, resolves conflicts and severity, refetches the PR review timeline
  immediately before publishing, and submits at most one consolidated GitHub
  review per PR per pass under the shared identity. If a duplicate review is
  accidentally posted, avoid public cleanup noise; edit existing comments only
  when needed to mark a finding superseded or retracted.
* Prefer squashing a feature branch with many commits.
  Use rebase autosquash and fixup commits.
  Rebase before force pushing with lease.

## Rust

* Prefer git worktrees under `.worktrees/` in the repo root, with `target/` symlinked back to the root `target/`, so trust and build artifacts stay inside the workspace.

## Workspace Hygiene

* Prefer temporary worktrees under the repo's `.worktrees/` directory. Avoid long-lived worktrees in `/private/tmp`; remove temporary worktrees before finishing unless the user asks to keep them.
* When creating a worktree for a repo with `mise.toml`, include the new worktree's `mise.toml` path in `MISE_TRUST_CONFIG_PATHS` for commands run in the worktree, such as `MISE_TRUST_CONFIG_PATHS=.worktrees/<name>/mise.toml mise install`, so the copied mise config is trusted.
* When creating a worktree for a repo that uses generated fixtures, make those fixtures available in the worktree before running tests. Prefer the repo's fixture/setup task; when fixtures are already generated in the primary checkout and the repo pattern supports it, symlink the generated fixture dirs/files into `.worktrees/<name>` just like shared `target/` build artifacts.
* Before creating large build artifacts, container images, VM disks, or long-running review worktrees, check available disk with `df -h` and call out expected storage use if it may be large.
* When using Docker, Colima, or other VM/container runtimes, do not create persistent VM/container data unless needed for the task. Report large reclaimable storage with `docker system df` before pruning.
* Treat `/private/tmp` as ephemeral: use task-specific directory names, preserve active PR/task dirs, and clean up completed temporary directories at the end of the task.

## Communication Support

When helping with communication, coordination, or executive-function-heavy work:

* When async triage risks sprawling, create a compact `Next 3` list for the current session and use it to keep the work bounded.
* For complex async updates, lead with `Ask`, `Decision`, and `Evidence` when those fields apply, then put deeper context below.
* For recurring status updates, prefer a running private scratch note plus a curated summary over repeated free-form drafting.
* For meeting preparation, offer a parking list for pending thoughts and, when timing matters, suggest a visible countdown timer if the environment supports it.
* Treat reminders, checklists, scratch notes, and external memory as normal work aids for delayed follow-ups or multi-step context.

<!-- BEGIN THYMOS MANAGED SIDEKICK GUIDANCE -->
## Thymos Sidekick

A Thymos sidekick may be available to support your work in this workspace.

* Reach for it when continuity, recall, grounding, synthesis, or a safer next step would help.
* Use focused questions and a short context summary.
* Let it support long debugging sessions, reviews, refactors, migrations, and research-heavy work.
* Keep ownership of the task, decisions, and final answer.
* When sidekick input shapes your next step, record the outcome when convenient.
<!-- END THYMOS MANAGED SIDEKICK GUIDANCE -->


## Agentic PLC

Do not assume every repository is PLC L1. Use Agentic PLC and the
`plc-security-scan` skill only when the current repository has repo-local PLC
instructions, a clear PLC marker, or the user explicitly asks for PLC work.

When a repository is PLC L1, follow its repo-local PLC instructions. If no
repo-local instructions exist, ask before treating the repository as PLC L1.
