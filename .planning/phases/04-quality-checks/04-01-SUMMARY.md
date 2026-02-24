---
phase: 04-quality-checks
plan: 01
subsystem: quality-verification
tags: [canon-checking, timeline-validation, consistency-analysis, agent-pattern]

# Dependency graph
requires:
  - phase: 01-foundation
    provides: Canon templates, state schemas, state-manager skill
  - phase: 02-planning
    provides: Outline structure, beat sheets for knowledge timeline
  - phase: 03-drafting
    provides: Draft scenes with YAML frontmatter for verification
provides:
  - Canon checker agent detecting character/world fact contradictions
  - Timeline keeper agent validating chronological consistency
  - Character knowledge timeline for premature knowledge detection
  - JSON output format with severity levels and fix suggestions
  - Agent execution pattern for parallel quality checking
affects: [04-02, 04-03, quality-pipeline, novel:check-command]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Checker agent pattern: Load canon → Scan scenes → Cross-reference → Output JSON"
    - "Severity classification: CRITICAL (blocking), MAJOR (should fix), MINOR (nice to fix)"
    - "Evidence structure: expected vs found with source reference"
    - "Knowledge timeline for tracking when characters learn information"

key-files:
  created:
    - claude_src/novel/agents/canon-checker.md
    - claude_src/novel/agents/timeline-keeper.md
  modified: []

key-decisions:
  - "Three-tier severity system (CRITICAL/MAJOR/MINOR) for issue prioritization"
  - "Canon checker builds character knowledge timeline to detect premature knowledge"
  - "Timeline keeper validates day-of-week for diary format using date calculation"
  - "All issues include scene_id, evidence (expected/found/source), and actionable suggestion"
  - "Flashback scenes get different chronology rules (marked via metadata)"
  - "Seasonal consistency checks consider hemisphere from world.md"

patterns-established:
  - "Checker agents follow 4-step pattern: Load → Build → Scan → Generate"
  - "JSON output format standardized across all checkers for /novel:check consolidation"
  - "Evidence always includes specific source reference (canon file and section)"
  - "Suggestions are actionable, not vague (tell user exactly what to change)"

# Metrics
duration: 5min
completed: 2026-02-24
---

# Phase 04 Plan 01: Canon & Timeline Checkers Summary

**Canon checker detects character fact contradictions and knowledge timeline violations; Timeline keeper validates chronological ordering and date accuracy for diary format**

## Performance

- **Duration:** 5 min
- **Started:** 2026-02-24T06:43:30Z
- **Completed:** 2026-02-24T06:48:38Z
- **Tasks:** 2
- **Files created:** 2

## Accomplishments

- Canon checker cross-references 6 fact types (character physical, relationships, personality, world locations, world rules, story facts) against canon files
- Character knowledge timeline detects premature knowledge (character knows X before learning X)
- Timeline keeper validates 6 chronology aspects (ordering, cause-effect, date/day-of-week, seasonal, time spans, anchors)
- Both agents output structured JSON with severity levels, scene references, evidence, and fix suggestions
- Established checker agent pattern ready for voice-coach, pacing-analyzer, and tension-monitor

## Task Commits

Each task was committed atomically:

1. **Task 1: Create canon-checker agent definition** - `ae9128d` (feat)
2. **Task 2: Create timeline-keeper agent definition** - `fea2ab5` (feat)

## Files Created/Modified

- `claude_src/novel/agents/canon-checker.md` - Verifies character facts, world details, story consistency against canon files (641 lines)
- `claude_src/novel/agents/timeline-keeper.md` - Validates chronological ordering, date accuracy, and timeline constraints (822 lines)

## Decisions Made

**Severity classification strategy:**
- CRITICAL for blocking issues (timeline reversals, dead character alive, constraint violations)
- MAJOR for reader-noticeable errors (wrong hair color, unrealistic time spans)
- MINOR for small details (day-of-week mismatch, slight seasonal inconsistency)
- Rationale: Enables prioritization - critical blocks progress, major should fix, minor nice to have

**Character knowledge timeline:**
- Canon checker builds timeline of when each character learns information
- Cross-references scene dialogue/thoughts against learning events
- Detects "character knows X in ch02 but learns X in ch05" violations
- Rationale: One of most common continuity errors in manuscripts

**Day-of-week validation approach:**
- Timeline keeper calculates actual day-of-week from ISO date
- Compares against diary entry header (e.g., "March 15, 2024 - Friday")
- Only flags as MINOR (not blocking)
- Rationale: Readers notice calendar errors, but easy to fix and not story-breaking

**Flashback handling:**
- Check scene metadata for flashback/memory markers
- Exempt from timeline reversal rules
- Still validated for internal consistency
- Rationale: Prevents false positives on intentional non-linear narrative

**Seasonal consistency checks:**
- Default to northern hemisphere unless world.md specifies
- Check prose descriptions match calculated season from date
- Consider world-specific rules (fantasy worlds, sci-fi planets)
- Rationale: Immersion-breaking to have snow in July without justification

**Evidence format standardization:**
- All issues include: expected (from canon), found (from scene), source (file reference)
- Enables verification without hunting for original context
- Suggestions are actionable ("Change 'blonde' to 'brown'") not vague ("Fix hair color")
- Rationale: Actionable reports get fixed; vague reports get ignored

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. Agent definitions followed established scene-writer pattern with clear 4-step execution workflow (Load → Build → Scan → Generate).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Ready for:**
- Plan 04-02: Voice coach and pacing analyzer agents (parallel wave)
- Plan 04-03: Tension monitor and /novel:check orchestrator command

**Provides to 04-02:**
- Checker agent pattern (4-step execution, JSON output format)
- Severity classification system
- Evidence structure (expected/found/source)
- Suggestion formatting guidelines

**Provides to 04-03:**
- JSON output format for consolidation
- Severity levels for report sorting
- Scene reference format (chXX_sYY)
- All checkers ready for parallel execution

**Notes:**
- Canon checker validates factual consistency (what is true)
- Timeline keeper validates temporal consistency (when things happen)
- Together they form the "factual consistency layer"
- Voice coach and pacing analyzer (04-02) form the "style consistency layer"
- Tension monitor (04-03) forms the "narrative structure layer"
- All five checkers spawn in parallel via /novel:check for comprehensive quality verification

---
*Phase: 04-quality-checks*
*Completed: 2026-02-24*
