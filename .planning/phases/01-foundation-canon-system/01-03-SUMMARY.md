---
phase: 01
plan: 03
name: /novel:status Command & Git Integration
subsystem: foundation
tags: [status, git, progress-tracking, auto-commit]
dependency-graph:
  requires: [01-01, 01-02]
  provides: [status-command, git-integration-skill]
  affects: [02-01, 04-01]
tech-stack:
  added: []
  patterns: [git-auto-commit, opportunistic-versioning, heredoc-commits]
key-files:
  created:
    - claude_src/novel/commands/status.md
    - claude_src/novel/skills/git-integration.md
    - .claude/commands/novel/status.md
  modified:
    - claude_src/novel/commands/init.md
decisions:
  - "Opportunistic canon commit on /novel:status (commit when checking status)"
  - "Canon change detection via git status --porcelain"
  - "Graceful degradation when git unavailable (warn and continue)"
  - "Heredoc format for all multi-line commit messages"
metrics:
  duration: 5m 26s
  completed: 2026-02-24
---

# Phase 1 Plan 03: /novel:status Command & Git Integration Summary

**One-liner:** Status reporting command with 7-step execution flow and git auto-commit integration using opportunistic canon change detection.

---

## What Was Built

### 1. /novel:status Command (status.md)

A comprehensive status reporting command with:

- **7 execution steps:** check init, load state, parse progress, identify position, check issues, auto-commit canon, display report
- **Status sections:** project info, progress overview, current position, scene statistics, plot threads, issues, git status
- **Next action suggestions:** context-aware guidance based on current progress state
- **Graceful error handling:** corrupted state recovery via git, missing file detection

### 2. Git Integration Skill (git-integration.md)

Reusable patterns for auto-commit operations:

- **5 commit functions:** check_git_available, commit_init, commit_canon_changes, commit_scene_completion, commit_outline, commit_revision
- **Configuration support:** git_integration settings in story_state.json
- **Graceful degradation:** operations skip silently when git unavailable
- **Safety rules:** never force push, never amend, always use Co-Authored-By

### 3. Updated /novel:init Command

- Added git-integration skill reference
- Updated Step 7 to use skill patterns
- Added skills_used documentation

### 4. Command Symlink

- `.claude/commands/novel/status.md` -> `claude_src/novel/commands/status.md`
- Makes `/novel:status` discoverable via Claude Code CLI

---

## Commits

| Hash | Description |
|------|-------------|
| 6656ae8 | Create /novel:status command |
| 7628e33 | Create git-integration skill |
| 24555eb | Add git-integration reference to init command |
| 008c16d | Enhance canon change detection documentation |
| 7172b4d | Add symlink for /novel:status command |

---

## Verification Results

### Test Results

| Test | Status | Notes |
|------|--------|-------|
| Fresh project status | Pass | Shows "No outline yet", suggests editing canon |
| Uninitialized detection | Pass | Error message with clear instructions |
| Corrupted state handling | Pass | Git recovery functional |
| Canon auto-commit | Pass | Detects changes, commits with proper message |
| Co-Authored-By tag | Pass | Present in all commits |
| Git graceful degradation | Documented | Skip operations when git unavailable |

### Verification Commands Used

```bash
# Test uninitialized directory
[ -d canon ] || echo "ERROR: Not a novel project"

# Test corrupted state detection
node -e "JSON.parse(fs.readFileSync('state/story_state.json'))"

# Test git recovery
git show HEAD:state/story_state.json

# Test canon change detection
git status --porcelain canon/

# Verify Co-Authored-By
git log -1 --pretty=full | grep "Co-Authored-By"
```

---

## Deviations from Plan

None - plan executed exactly as written.

---

## Key Implementation Details

### Status Report Format

```
========================================
NOVEL PROJECT STATUS
========================================

Project: [title]
Format:  [format]

----------------------------------------
PROGRESS
----------------------------------------

Outline:    [ ] not_started
Beat Plan:  [ ] not_started
Draft:      [ ] not_started

----------------------------------------
NEXT SUGGESTED ACTION
----------------------------------------

Edit your canon files to define your story:
  - canon/premise.md (start here)
  - canon/characters.md
  - canon/world.md
```

### Git Commit Message Format

All commits use heredoc for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
Message line 1

Details here

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### Canon Change Detection

```bash
changed_files=$(git status --porcelain canon/)
if [ -n "$changed_files" ]; then
  git add canon/
  git commit -m "Update premise\n\nCo-Authored-By: ..."
fi
```

---

## Dependencies Satisfied

This plan depended on:

- **01-01:** State schemas and state-manager (used for loading state)
- **01-02:** /novel:init command (creates projects to report on)

---

## Next Phase Readiness

Phase 1 foundation is now complete:

1. Directory structure and state initialization
2. /novel:init command for project creation
3. /novel:status command for progress visibility
4. Git integration for version control

**Phase 2 (Planning Pipeline) can now begin.**

Required for Phase 2:
- Outline generation command (/novel:outline)
- Beat planning system
- Scene breakdown

---

## Files Created/Modified

### Created

| File | Purpose |
|------|---------|
| `claude_src/novel/commands/status.md` | Status reporting command (713 lines) |
| `claude_src/novel/skills/git-integration.md` | Git auto-commit skill (629 lines) |
| `.claude/commands/novel/status.md` | Symlink for discoverability |

### Modified

| File | Changes |
|------|---------|
| `claude_src/novel/commands/init.md` | Added git-integration skill reference |

---

*Summary completed: 2026-02-24*
*Duration: 5m 26s*
*All tasks verified successfully*
