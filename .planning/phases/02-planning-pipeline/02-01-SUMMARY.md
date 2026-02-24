---
phase: 02-planning-pipeline
plan: 01
subsystem: planning
tags: [plot-structure, save-the-cat, beat-sheet, outline-generation, story-framework]

# Dependency graph
requires:
  - phase: 01-foundation
    provides: State schemas, canon templates, state-manager skill
provides:
  - Plot-planner agent with 3-act/5-act auto-detection
  - Save the Cat beat sheet framework integration
  - Hero's Journey overlay for epic stories
  - Character arc mapping to plot structure
  - Outline generation from canon files
affects: [02-02-chapter-breakdown, 03-drafting-engine, scene-planner]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Agent definition pattern: YAML frontmatter + role + execution + validation"
    - "Framework integration: Save the Cat 15-beat structure"
    - "Structure auto-detection based on word count and complexity"

key-files:
  created:
    - claude_src/novel/agents/plot-planner.md
  modified: []

key-decisions:
  - "3-act structure for <80k words, 5-act for >80k or complex stories"
  - "Save the Cat as primary framework with Hero's Journey overlay option"
  - "Auto-detect structure based on target length, POV count, and subplot complexity"
  - "Outline written to beats/outline.md with chapter and scene breakdown"
  - "State manager pattern for updating progress.outline = complete"

patterns-established:
  - "Agent docs structure: role, commands, execution (5 steps), validation, frameworks, examples, edge cases"
  - "Beat percentage mapping: precise word count targets for each story beat"
  - "Character arc mapping across plot structure with emotional state tracking"

# Metrics
duration: 4min
completed: 2026-02-24
---

# Phase 2 Plan 1: Plot Planner Agent Summary

**Plot-planner agent with Save the Cat 15-beat framework, automatic 3-act/5-act detection, and character arc mapping to story structure**

## Performance

- **Duration:** 4 min
- **Started:** 2026-02-24T05:28:09Z
- **Completed:** 2026-02-24T05:32:32Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Complete plot-planner agent definition with 1,028 lines
- Integrated Save the Cat 15-beat framework with percentage-based structure
- Automatic structure selection: 3-act for straightforward stories, 5-act for complex/epic narratives
- Hero's Journey overlay pattern for fantasy and epic genres
- Character arc progression mapping across all story beats
- State manager integration for tracking outline completion status

## Task Commits

Each task was committed atomically:

1. **Task 1: Create plot-planner agent with Save the Cat integration** - `ed40795` (feat)

## Files Created/Modified
- `claude_src/novel/agents/plot-planner.md` - Agent for generating story outlines from canon files with beat sheet structure

## Decisions Made

**Structure Selection Logic:**
- 3-act structure: Default for single POV, <80k words, straightforward arcs
- 5-act structure: Used for multiple POVs, >80k words, complex subplots, epic scope
- Complexity scoring: Multiple POVs, subplot count, antagonist type, world-building needs
- User override: `--3act` or `--5act` flags can force specific structure

**Framework Integration:**
- Save the Cat as primary framework (15 beats with clear percentage markers)
- Hero's Journey as optional overlay for fantasy/epic/mythic stories
- Beat percentages map to word count targets based on project length
- Character arc stages aligned with plot beats for coherent progression

**State Management:**
- Updates `progress.outline = "complete"` when outline generated
- Initializes `scene_index` array with planned scenes
- Tracks `act_structure`, `estimated_chapters`, `estimated_scenes`
- Uses state-manager skill load/update/save pattern

**Output Structure:**
- Primary output: `beats/outline.md` with full beat breakdown
- Includes: Story summary, act structure, chapter breakdown, character arcs, timeline
- Editable by user - agents read current version, not locked
- Next steps guide: review → refine → run /novel:write

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Ready for:**
- Plan 02-02: Chapter breakdown and scene planning
- Plan 03-01: Scene drafting engine (will read beats/outline.md)

**Foundation complete:**
- Plot structure framework established
- Beat percentage system working
- Character arc mapping pattern defined
- State tracking for outline progress

**No blockers or concerns.**

---
*Phase: 02-planning-pipeline*
*Completed: 2026-02-24*
