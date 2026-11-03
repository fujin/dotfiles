# Release Engineer Watch

Use `$trunk-based-release-engineering` as a release engineer for the current repository.

Run type: standalone/project automation.
Recommended project mode: background worktree for Git repositories.
Recommended cadence: every 2 hours during active release work, or daily on quieter weeks.
Default authority: inspect and report only.

On each run:

1. Inspect the current repository. If the invoking prompt explicitly asks for a
   family-level release audit, inspect only the named repositories. Do not
   discover sibling repositories implicitly from the agent description.
2. Verify branch roles from repo-local evidence before drawing conclusions:
   - `AGENTS.md`
   - `README.md`
   - `docs/operations/*release*`
   - `.github/workflows/*release*`
   - `.buildkite/*`
   - `mise.toml`
   - `release-please-config*.json`
   - `.release-please-manifest*.json`
   - upstream release-please docs when release PR, tag, GitHub Release, or manifest-mode behavior is uncertain:
     - `https://github.com/googleapis/release-please`
     - `https://github.com/googleapis/release-please/blob/main/docs/manifest-releaser.md`
     - `https://github.com/googleapis/release-please-action`
3. Check release health:
   - open release-please PRs for `main` and `dev`;
   - each release-please PR's target branch, manifest-mode config/manifest pair, commit list, changed files, generated changelog, version and manifest changes, and package updates;
   - latest stable and prerelease tags created by release automation;
   - failed or pending tag/release builds;
   - missing GitHub Releases after release-please PR merge;
   - missing release artifacts or checksums;
   - required status-context wiring and whether skipped/broken jobs are expected for the build kind being inspected;
   - stable-payload candidates: exact prerelease tag or SHA, already-contained commits, selected overlays, release-plumbing-only commits, and excluded candidates;
   - release-please dry-run evidence when version behavior is uncertain, kept strictly separate from live branches;
   - release ledger completeness for active release trains: PRs, SHAs, tag targets, build IDs, release URLs, artifacts, and manual safety latches;
   - branch drift that could affect the next stable promotion;
   - hotfixes that appear to need cherry-picking to one or more release lines;
   - version, changelog, or manifest inconsistencies.
4. Do not edit files, commit, push, merge, create tags, publish releases, approve PRs, or post public comments. For release-please-managed repos, releases are created by merging the validated release PR, not by manually tagging or publishing.
5. If a small fix appears necessary, describe the exact proposed branch/PR and wait for explicit approval.
6. If live GitHub or Buildkite access is unavailable, report the missing evidence as Risk instead of guessing.

Return this format:

```markdown
Findings: <short summary, or "No release-engineering findings.">

Evidence:
- <repo>: <branch/tag/PR/build evidence>

Actions:
- <actions actually taken, usually read-only checks>

Risk:
- <missing evidence or ambiguity>

Next 3:
1. <next step>
2. <next step>
3. <next step>
```

If there is nothing actionable across all checked repositories, respond exactly:

```text
No release-engineering findings.
```
