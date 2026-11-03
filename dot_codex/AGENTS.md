# Instructions for coding agents

## Honesty rules (read every turn)

Before claiming a function, class, or import exists, verify it by reading
the file or running a grep. Never fabricate symbols.

If you cannot verify something, say "I haven't verified this" explicitly.
Do not write code that depends on the unverified claim.

If a task asks you to use a library you've never seen referenced in this
project, ask before adding it.

If a task involved tests or builds, do not claim success unless you
actually ran the test or build command in this session.

Never invent error messages, API responses, or stack traces. If you
didn't see them, say so.

When you genuinely don't know, the correct answer is "I don't know" or
"I need to check first." Both are better than a confident guess.

## Failure analysis (contributing factors, not root cause)

When investigating incidents, outages, regressions, or intermittent failures,
never frame the goal — in your own analysis or in any prompt you write for a
subagent or workflow — as finding the single root cause. Complex failures
require several contributing conditions to hold at once
(https://how.complexsystems.fail/#3). Model the combination, separate defenses
that held from those absent, and use the `failure-trajectory` skill when
available for the full method. Naming a dominant contributor is fine; label it
as such, never as "the cause".

## Verification

Before writing code that uses a symbol, verify it exists: read the defining
file, grep for it, or check the dependency manifest. Prefer plan-then-execute
for any task touching more than one file.

## Tools

* Prefer installing tools with `mise` over `brew`.
* In repos with `mise.toml`, prefer the checked-in mise tasks for setup,
  fixtures, tests, and builds. If a raw command fails for missing fixtures or
  setup, run the relevant mise task and retry before reporting a blocker.
* Dotfiles are managed with chezmoi; the repository is ~/.local/share/chezmoi.
* For local macOS Bake builds/tests and mirror-wrapper troubleshooting, use
  `bake-mirror`.
* For worktrees, temp checkouts, mise trust, disk budgets, and Rust
  build-cache isolation, use the `workspace-hygiene` skill.

## Python

Default to `uv` for Python everywhere (`uv run`, `uv sync`, `uv add`, ...)
instead of raw python/pip/venv/pipx/poetry/pyenv workflows. Use non-uv tooling
only when the repo explicitly requires it, and state why. Details in the
`uv-python` skill.

## Review gates

Explicit Claude/Opus gates run only on user request; consent scope and the
exact escalation justification live in the `turbo-review` skill. All gate
output is advisory — verify findings before acting on them.

## Pausing work

Whenever I or another session asks you to pause or stop work, run
`/checkpoint` (the `checkpoint` skill) before stopping, even mid-task. It
records build status, commits and pushes a WIP branch, and writes HANDOFF.md;
it does not fix anything. A stop that also says "don't commit" or "don't
push" overrides those steps only.

## Git

* Conventional commit messages of type feat, fix, deps. Avoid chore without
  explicit confirmation; those are not releasable units.
* Prefer the GitHub connector for PR creation, review/comment retrieval, and
  PR comments; use `gh` as fallback. No `[codex]` prefix on PR titles.
* Prefer the configured Git MCP server for supported operations; use shell
  git when it lacks the operation or a complex workflow is safer.
* `rerere` may be enabled globally: inspect `git status` and `git diff` after
  merge/rebase/cherry-pick operations because prior conflict resolutions may
  have been reused before staging or continuing.
* Do not add extra comments on pull requests when following up.
* If multiple agents or lanes inspect one PR, only the designated coordinator
  writes to GitHub; lanes report privately and the coordinator submits at
  most one consolidated review per pass.
* Prefer squashing feature branches with many commits: fixup commits plus
  rebase autosquash, then force-push with lease.

### Collaborator-owned pull requests

A PR authored by another human, or whose head branch they own, is theirs.
Broad authority to implement, land, or finish a goal is not authorization to
rewrite or dispose of it: do not change its title, body, labels, state,
base/head, reviewers, or merge state, and do not push its branch, without
explicit authorization in the current task. If new evidence changes the
strategy for such a PR, stop and ask before touching it. Read-only
inspection, local checkout and testing, and requested review actions remain
allowed. For immediate irreversible harm, make only the minimum reversible
safety change and report it.

## Rust

Use the `good-rust` skill for Rust implementation, refactors, and review.
For review-significant builds and tests, isolate caches per the
`workspace-hygiene` skill.

## Communication style

When drafting or rewriting messages in my voice, never use em dashes.
Use commas, periods, colons, or parentheses instead. Do not substitute
en dashes or double hyphens.

Avoid rhetorical negative triads such as "No X. No Y. No Z."
State the point directly instead.

Draft Slack messages in the user's observed style: concise, direct, lightly
conversational, not over-capitalized; lowercase sentence starts are fine in
casual threads. Avoid corporate phrasing like "Quick update from my pass";
prefer "update from this pass", "got this working", "current blocker".
Preserve exact technical facts, links, commands, PR numbers, owners, and
caveats. Use bullets only when they make evidence easier to scan.

