---
phase: 5
plan: 02
name: Pipeline Integration
subsystem: revision-loop
tags: [orchestration, quality-gate, editorial, state-management]

requires:
  - 05-01 (novel-editor and novel-quality-gate agents)
  - Phase 4 checker agents

provides:
  - /novel:check with full revision pipeline (checkers -> editor -> gate -> state update)
  - story_state.json revision tracking
  - Scene status lifecycle (planned -> drafted -> needs_revision <-> approved)

affects:
  - 05-03 (verification plan will test this integration)
  - Phase 6 (publish command will use approved status)

tech-stack:
  added: []
  patterns:
    - Sequential agent pipeline (editor, gate after parallel checkers)
    - State-driven scene status lifecycle
    - Revision history tracking with cycle metadata

key-files:
  created: []
  modified:
    - claude_src/novel/commands/check.md
    - claude_src/novel/schemas/story_state.schema.json
    - claude_src/novel/utils/state-manager.md

decisions:
  - Sequential editor/gate execution: Editor runs after checkers, gate runs after editor
  - Editorial is advisory: Quality gate continues even if editor fails
  - Scene-level granularity: Each scene tracked independently for targeted revision
  - Revision history array: Full audit trail of check cycles per scene

metrics:
  duration: ~4 minutes
  completed: 2026-02-24
---

# Phase 5 Plan 02: Pipeline Integration Summary

**One-liner:** Extended /novel:check to spawn editor + quality gate agents after checkers, with revision tracking in story_state.json.

## What Was Done

### Task 1: Extended /novel:check with Editor + Quality Gate Pipeline

Extended the existing `/novel:check` command to add four new steps after checker consolidation:

**Step 6 - Spawn novel-editor agent:**
- Reads all 5 checker JSON outputs
- Synthesizes findings into prioritized editorial feedback
- Writes `editorial_letter.md` to check_reports directory
- Error handling: Continues without editorial if agent fails

**Step 7 - Spawn novel-quality-gate agent:**
- Reads checker outputs and optional quality_criteria.json
- Evaluates each scene against thresholds (0 CRITICAL, 2 MAJOR default)
- Writes `quality_decision.json` with scene-level decisions
- Outputs APPROVED or NEEDS_REVISION per scene

**Step 8 - Update story_state.json:**
- Loads current state and quality_decision.json
- Updates scene status: "approved" or "needs_revision"
- Increments revision_count for each scene
- Appends to revision_history array with cycle details

**Step 9 - Display extended summary:**
- Shows QUALITY GATE DECISION section with status and criteria
- Lists scenes needing revision with blocking issues
- References editorial letter location
- Updates next steps based on gate decision

### Task 2: Extended State Schema and Documentation

**Schema changes (story_state.schema.json):**
- Updated status enum: `["planned", "drafted", "needs_revision", "approved"]`
- Added `revision_count` field (integer, default 0)
- Added `revision_history` array with cycle objects
- Added `last_check` and `approved_at` timestamps
- Updated `schema_version` to "1.1"

**Documentation additions (state-manager.md):**
- Scene Status Lifecycle section with status definitions and transitions
- Revision Tracking section with examples
- Revision History Fields table
- Access patterns for revision data

## Key Design Decisions

1. **Sequential editor/gate execution:** Editor runs AFTER all checkers complete (needs their output), quality gate runs AFTER editor (editorial is optional context for decision)

2. **Editorial is advisory, not blocking:** If novel-editor fails, quality gate can still make decisions based on checker data alone

3. **Scene-level granularity:** Each scene is evaluated independently, enabling targeted revision workflow instead of all-or-nothing

4. **Revision history as audit trail:** Full history enables tracking improvement across cycles and detecting infinite loops

## Files Modified

| File | Lines Added | Description |
|------|-------------|-------------|
| `claude_src/novel/commands/check.md` | 881 | Steps 6-9, error handling, examples |
| `claude_src/novel/schemas/story_state.schema.json` | 80 | revision_count, revision_history, timestamps |
| `claude_src/novel/utils/state-manager.md` | 148 | Status lifecycle, revision tracking docs |

## Verification Results

- `/novel:check` now contains "novel-editor" references (4 occurrences)
- `/novel:check` now contains "quality_decision" references (15 occurrences)
- `story_state.schema.json` contains "revision_history" definition
- `state-manager.md` contains "Revision Tracking" section and "revision_count" (3 occurrences)
- Check.md is 2015 lines (above 850 minimum requirement)

## Commits

| Hash | Type | Message |
|------|------|---------|
| 504cf81 | feat | extend /novel:check with editor + quality gate pipeline |
| 77b5f71 | feat | extend state schema and documentation for revision tracking |

## Next Phase Readiness

**Ready for Plan 05-03 (Verification):**
- Full pipeline integration complete
- Can test end-to-end: /novel:write -> /novel:check -> status update -> revision
- Editorial letter and quality decision files generated in check_reports/

**Blockers:** None

**Concerns:** None - implementation matches research patterns exactly

---

*Summary generated: 2026-02-24T08:18:01Z*
*Plan 05-02 execution complete*
