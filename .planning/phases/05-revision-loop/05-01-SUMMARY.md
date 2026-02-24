---
phase: 05-revision-loop
plan: 01
subsystem: quality
tags: [editorial, quality-gate, checker-synthesis, revision-loop, must-should-could]

# Dependency graph
requires:
  - phase: 04-quality-checks
    provides: 5 checker agents outputting structured JSON reports
provides:
  - novel-editor agent for synthesizing checker reports into editorial letters
  - novel-quality-gate agent for objective scene approval decisions
  - Must/Should/Could prioritization framework
  - Configurable quality thresholds (critical_threshold, major_threshold)
affects: [05-02 pipeline integration, 05-03 verification, revision workflow]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Editorial synthesis: Transform 5 checker JSONs into 3-5 prioritized improvements"
    - "Quality gate: Objective thresholds (0 CRITICAL, 2 MAJOR max) for scene approval"
    - "Scene-level granularity: Approve/reject per scene, not whole manuscript"
    - "Blocking vs advisory issues: CRITICAL/MAJOR block, MINOR advises"

key-files:
  created:
    - claude_src/novel/agents/novel-editor.md
    - claude_src/novel/agents/novel-quality-gate.md
  modified: []

key-decisions:
  - "Must/Should/Could framework for editorial prioritization (from research)"
  - "Default thresholds: 0 CRITICAL, 2 MAJOR per scene, unlimited MINOR"
  - "Scene-level evaluation enables targeted revision (not all-or-nothing)"
  - "Editorial letter always includes What Works Well section (positive feedback)"
  - "Quality gate outputs structured JSON for state updates by /novel:check"

patterns-established:
  - "Editorial synthesis pattern: Load all JSONs -> Analyze patterns -> Prioritize 3-5 -> Generate letter"
  - "Quality gate pattern: Load criteria -> Evaluate per scene -> Determine overall status -> Output JSON"
  - "Blocking issues tracking: Each scene decision includes blocking_issues array for targeted fixes"

# Metrics
duration: 5min
completed: 2026-02-24
---

# Phase 5 Plan 01: Editorial & Quality Gate Agents Summary

**Novel editor synthesizes 5 checker reports into Must/Should/Could prioritized editorial letters; quality gate applies configurable thresholds (0 CRITICAL, 2 MAJOR) for scene-level approval decisions**

## Performance

- **Duration:** 5 min
- **Started:** 2026-02-24T08:05:51Z
- **Completed:** 2026-02-24T08:11:11Z
- **Tasks:** 2
- **Files modified:** 2 (both created)

## Accomplishments

- Built novel-editor agent (976 lines) that reads all 5 checker JSONs and generates editorial_letter.md
- Built novel-quality-gate agent (1145 lines) that applies objective thresholds for APPROVED/NEEDS_REVISION decisions
- Established Must/Should/Could framework for prioritizing 3-5 revision improvements
- Implemented scene-level granularity for targeted revision workflows
- Added What Works Well section to editorial letters for balanced feedback

## Task Commits

Each task was committed atomically:

1. **Task 1: Build novel-editor agent** - `01d9871` (feat)
   - Editorial synthesis agent with Must/Should/Could framework
   - Pattern analysis: scene grouping, type grouping, cross-cutting issues
   - Generates editorial_letter.md with actionable fix strategies

2. **Task 2: Build novel-quality-gate agent** - `20a4cb7` (feat)
   - Quality gate with configurable thresholds
   - Scene-level APPROVED/NEEDS_REVISION decisions
   - Outputs quality_decision.json with blocking_issues

## Files Created/Modified

- `claude_src/novel/agents/novel-editor.md` - Editorial synthesis agent (976 lines)
  - Reads check_reports/[timestamp]/*.json
  - Synthesizes findings into 3-5 prioritized improvements
  - Generates editorial_letter.md with What Works Well, Must Fix, Should Fix, Could Fix, Revision Plan, Next Steps

- `claude_src/novel/agents/novel-quality-gate.md` - Quality gate agent (1145 lines)
  - Reads quality_criteria.json or uses defaults (critical_threshold: 0, major_threshold: 2)
  - Evaluates each scene against thresholds
  - Generates quality_decision.json with scene_decisions array

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Must/Should/Could framework | Industry-standard editorial prioritization prevents overwhelm, from research |
| Default 0 CRITICAL, 2 MAJOR | Reasonable defaults allowing minor issues while blocking critical errors |
| Scene-level evaluation | Enables targeted revision instead of rejecting entire manuscript |
| What Works Well mandatory | Balanced feedback maintains writer motivation |
| Quality gate outputs JSON | Structured data enables state updates by /novel:check command |

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Ready for Plan 05-02 (Pipeline Integration):**
- Both agents exist and follow established template pattern
- Editor reads from check_reports/[timestamp]/*.json
- Quality gate outputs to check_reports/[timestamp]/quality_decision.json
- /novel:check command needs to be updated to spawn these agents after checkers complete

**No blockers or concerns.**

---
*Phase: 05-revision-loop*
*Plan: 01*
*Completed: 2026-02-24*
