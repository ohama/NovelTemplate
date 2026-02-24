---
phase: 02-planning-pipeline
plan: 04
subsystem: commands
tags: [command, orchestration, agents, outline, planning-pipeline]

# Dependency graph
requires:
  - phase: 02-01
    provides: plot-planner agent for structure generation
  - phase: 02-02
    provides: beat-planner agent for scene beat sheets
  - phase: 02-03
    provides: diary-planner agent for diary format
  - phase: 01-03
    provides: git-integration skill for auto-commit
  - phase: 01-02
    provides: command pattern and state-manager skill
provides:
  - /novel:outline command orchestrating planning pipeline
  - Sequential agent spawning pattern (plot → beat → diary)
  - Canon validation before outline generation
  - Auto-commit canon changes before planning
  - Comprehensive error handling and rollback
affects: [03-drafting-engine, novel:write, scene-writer]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Multi-agent orchestration via sequential spawning"
    - "Pre-flight validation with detailed error messages"
    - "Graceful degradation for git operations"
    - "Backup and rollback on agent failure"

key-files:
  created:
    - claude_src/novel/commands/outline.md
    - .claude/commands/novel/outline.md
  modified: []

key-decisions:
  - "Sequential agent execution (plot → beat → diary) not parallel - ensures dependencies"
  - "Auto-commit canon changes before outline generation - preserves user edits"
  - "Backup existing beats/ before regeneration - prevents data loss"
  - "Conditional diary-planner based on format - only runs when needed"
  - "Comprehensive validation with actionable error messages - guides user through issues"

patterns-established:
  - "Command orchestration pattern: validate → prepare → spawn agents → commit → report"
  - "Agent spawning pattern: Read and execute agent .md files"
  - "Error handling pattern: Rollback partial changes on agent failure"
  - "Success reporting pattern: Show structure, files, next steps"

# Metrics
duration: 6min
completed: 2026-02-24
---

# Phase 02 Plan 04: /novel:outline Command Summary

**User-facing command orchestrating plot-planner, beat-planner, and diary-planner agents to generate complete story structure from canon with validation, auto-commit, and comprehensive error handling**

## Performance

- **Duration:** 6 min
- **Started:** 2026-02-24T05:34:55Z
- **Completed:** 2026-02-24T05:40:48Z
- **Tasks:** 1
- **Files modified:** 2

## Accomplishments
- Created /novel:outline command with full agent orchestration
- Sequential pipeline execution: plot-planner → beat-planner → diary-planner
- Pre-flight validation ensures canon files exist and are edited
- Auto-commits canon changes before outline generation
- Comprehensive error handling with rollback on failure
- Clear success reporting with file locations and next steps

## Task Commits

Each task was committed atomically:

1. **Task 1: Create /novel:outline command with agent orchestration** - `e013b3a` (feat)

## Files Created/Modified
- `claude_src/novel/commands/outline.md` - /novel:outline command skill with 9-step orchestration
- `.claude/commands/novel/outline.md` - Symlink for command discoverability

## Decisions Made

**1. Sequential agent execution (plot → beat → diary)**
- **Rationale:** Ensures dependencies are met. beat-planner needs outline.md from plot-planner. diary-planner needs scene files from beat-planner.
- **Alternative considered:** Parallel execution would be faster but risks race conditions

**2. Auto-commit canon changes before outline generation**
- **Rationale:** Preserves user edits in git history before agents read canon. Enables rollback if generated outline is poor.
- **Pattern:** Uses commit_canon_changes() from git-integration skill

**3. Backup existing beats/ before regeneration**
- **Rationale:** Prevents data loss if user accidentally regenerates. User can restore from beats.backup.[timestamp]
- **Pattern:** Move to timestamped backup, create fresh directory

**4. Conditional diary-planner invocation**
- **Rationale:** Only chapter and diary formats need full pipeline. Short stories and serials may skip diary-planner.
- **Check:** Read project.format from story_state.json, spawn diary-planner only if format == "diary"

**5. Comprehensive validation with actionable errors**
- **Rationale:** Guides user through issues rather than cryptic failures
- **Examples:**
  - Missing canon files: Shows exact copy command to fix
  - Unedited templates: Warns but allows continuation
  - Agent failures: Lists expected vs actual files, suggests troubleshooting

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None - command creation followed established pattern from Phase 1 (init.md, status.md).

## Next Phase Readiness

**Phase 2 Complete:** All planning agents (plot-planner, beat-planner, diary-planner) and orchestrator command (/novel:outline) are now implemented.

**Ready for Phase 3 (Drafting Engine):**
- /novel:outline provides complete story structure
- beats/outline.md contains chapter breakdown
- beats/scenes/*.md contain scene beat sheets (150-300 word planning notes)
- story_state.json tracks scene_index and current position
- character_state.json tracks scene_appearances

**Next phase will build:**
- /novel:write command
- scene-writer agent for prose generation
- Scene-by-scene drafting workflow

**No blockers or concerns.**

---
*Phase: 02-planning-pipeline*
*Completed: 2026-02-24*
