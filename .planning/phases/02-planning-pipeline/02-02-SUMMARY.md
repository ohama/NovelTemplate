---
phase: 02-planning-pipeline
plan: 02
subsystem: planning
tags: [agent-definition, scene-beats, beat-sheets, planning-pipeline, state-tracking]

# Dependency graph
requires:
  - phase: 01-foundation
    provides: state schemas, state-manager skill, directory structure
  - phase: 02-planning-pipeline
    plan: 01
    provides: plot-planner agent pattern
provides:
  - beat-planner agent definition for scene beat generation
  - Scene beat sheet format (chXX_sYY.md structure)
  - Scene ID pattern (chXX_sYY format)
  - POV assignment logic
  - Character scene tracking integration
affects: [02-03-plot-planner, 03-drafting-engine, scene-writer]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Agent definition pattern: role + 5-step execution + validation"
    - "Scene beat format with Purpose/Structure/Character/Emotional/Continuity/Drafting"
    - "Progressive disclosure principle for agent specifications"

key-files:
  created:
    - claude_src/novel/agents/beat-planner.md
  modified: []

key-decisions:
  - "Scene ID format chXX_sYY with zero-padding for correct sorting"
  - "Beat sheets are 150-300 word planning notes, NOT prose"
  - "Agent updates both story_state and character_state for consistency"
  - "2-5 scenes per chapter based on complexity and pacing"
  - "POV rotation logic for multi-POV stories"

patterns-established:
  - "Agent role section defines persona and principles"
  - "5-step execution flow: Validate Input → Process Chapters → Generate Beats → Update State → Output Summary"
  - "Validation section provides verification checklist"
  - "Progressive disclosure: specify structure but leave creative decisions open"

# Metrics
duration: 3min
completed: 2026-02-24
---

# Phase 2 Plan 2: Beat Planner Agent Summary

**Scene beat generation agent with 5-step execution flow, chXX_sYY ID pattern, POV assignment, and dual state tracking**

## Performance

- **Duration:** 3min 36sec
- **Started:** 2026-02-24T05:28:09Z
- **Completed:** 2026-02-24T05:31:45Z
- **Tasks:** 1
- **Files modified:** 1 (created)

## Accomplishments

- Created comprehensive beat-planner agent definition (711 lines)
- Established scene beat format matching research specifications
- Defined scene ID pattern (chXX_sYY) with zero-padding for consistency
- Integrated state tracking for both story_state and character_state
- Provided POV rotation logic for multi-POV narratives

## Task Commits

Each task was committed atomically:

1. **Task 1: Create beat-planner agent with scene beat generation** - `4b09010` (feat)

**Plan metadata:** (pending)

## Files Created/Modified

- `claude_src/novel/agents/beat-planner.md` - Agent definition that converts chapter outlines into scene-level beat sheets with POV, goals, conflict, emotional beats, and continuity tracking

## Decisions Made

**Scene ID Format:**
- Pattern: `chXX_sYY` (zero-padded to 2 digits)
- Rationale: Ensures alphabetical sorting matches chronological order, consistent parsing with regex, easy visual scanning

**Beat Sheet Content:**
- Length: 150-300 words per scene
- Style: Planning notes, NOT prose
- Rationale: Provides structure for scene-writer without over-constraining creative decisions (progressive disclosure)

**Scene Count Per Chapter:**
- Range: 2-5 scenes based on complexity
- Factors: Location changes, plot threads, pacing notes from outline
- Rationale: Balances narrative granularity with practical drafting workload

**State Updates:**
- Updates both story_state.json (scene_index, progress.beat_plan) and character_state.json (scene_appearances, development_notes)
- Rationale: Ensures consistency tracking across all state files, enables downstream agents to verify continuity

**POV Assignment:**
- Single POV: Consistent protagonist throughout
- Multiple POV: Rotation based on character impact in scene, balanced page time
- Checks style_state.json for POV constraints
- Rationale: Respects narrative voice decisions while ensuring fair character representation

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None - straightforward agent definition creation following established patterns from Phase 1 (state-manager, git-integration skills).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Ready for:**
- Plan 02-03: Plot-planner agent creation (can follow same pattern)
- Phase 3: Drafting engine (scene-writer will read beat sheets)

**What's available:**
- beat-planner agent fully documented with 5-step execution flow
- Scene beat format specification for downstream consumption
- State update procedures for scene tracking
- Scene ID pattern established for file naming

**Dependencies satisfied:**
- Builds on Phase 1 state schemas (story_state, character_state)
- Uses state-manager skill patterns for load/update operations
- Follows agent definition pattern (role + execution + validation)

**No blockers:** Plan 02-03 can proceed immediately to create plot-planner agent (which feeds beats/outline.md to beat-planner).

---

*Phase: 02-planning-pipeline*
*Completed: 2026-02-24*
