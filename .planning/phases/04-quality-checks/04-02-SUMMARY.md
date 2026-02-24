---
phase: 04-quality-checks
plan: 02
subsystem: quality-checking
tags: [voice-analysis, pacing-analysis, style-validation, consistency-checking]

# Dependency graph
requires:
  - phase: 01-foundation
    provides: State schemas (character_state, story_state), canon templates (style_guide)
  - phase: 02-planning
    provides: Beat sheets with target word counts
  - phase: 03-drafting
    provides: Scene writer agent pattern, draft scenes
provides:
  - Voice coach agent for POV, tense, forbidden phrase, and character voice validation
  - Pacing analyzer agent for word count deviation and rhythm analysis
  - Structured JSON output format with severity levels and fix suggestions
affects: [04-03-tension-monitor, 04-check-command]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Checker agent pattern (load data → analyze → output JSON)
    - Three-tier severity system (CRITICAL/MAJOR/MINOR)
    - Deviation threshold pattern (30%/50%/100%)
    - Evidence-based issue reporting with actionable suggestions

key-files:
  created:
    - claude_src/novel/agents/voice-coach.md
    - claude_src/novel/agents/pacing-analyzer.md
  modified: []

key-decisions:
  - "Voice coach detects POV violations as CRITICAL severity - head-hopping blocks quality approval"
  - "Pacing analyzer never produces CRITICAL issues - pacing alone shouldn't block publication"
  - "Character voice drift considers arc_stage - early vs late voice evolution is expected"
  - "Deviation thresholds: >30% MINOR, >50% MAJOR, >100% investigate with emphasis"
  - "Tense shifts flagged as MAJOR - fundamental style consistency requirement"
  - "Forbidden phrases are exact match (case-insensitive) - simple string search not regex"

patterns-established:
  - "Checker agent structure: YAML frontmatter → role → execution (4 steps) → validation → examples"
  - "JSON output schema: checker, timestamp, scenes_checked, issues array, summary object"
  - "Issue schema: severity, scene_id, type, description, evidence object, suggestion"
  - "Evidence object: expected (canon/state reference), found (scene quote), source (file path)"

# Metrics
duration: 6min
completed: 2026-02-24
---

# Phase 04 Plan 02: Voice & Pacing Analyzers Summary

**Voice coach detects POV violations, tense shifts, and forbidden phrases; pacing analyzer evaluates word count deviations with 30%/50%/100% severity thresholds**

## Performance

- **Duration:** 6 min
- **Started:** 2026-02-24T06:43:33Z
- **Completed:** 2026-02-24T06:49:53Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Voice coach agent validates POV consistency (head-hopping detection), tense adherence, forbidden phrase usage, and character voice patterns
- Pacing analyzer agent compares actual vs target word counts, calculates deviation percentages, analyzes sentence rhythm, and identifies rushed/dragging scenes
- Both agents output structured JSON with severity levels, scene references, evidence, and actionable fix suggestions

## Task Commits

Each task was committed atomically:

1. **Task 1: Create voice-coach agent definition** - `f2d97ec` (feat)
   - 757 lines with complete role/execution/validation sections
   - Loads style_guide.md, character_state.json for voice patterns
   - Detects POV violations (CRITICAL), tense shifts (MAJOR), forbidden phrases (MAJOR), voice drift (MINOR)
   - Considers character arc_stage when evaluating voice evolution

2. **Task 2: Create pacing-analyzer agent definition** - `e72105f` (feat)
   - 841 lines with complete role/execution/validation sections
   - Loads beat sheets for target word counts, story_state.json for actuals
   - Calculates deviation percentages with intensity-aware thresholds
   - Analyzes sentence rhythm and content balance for flagged scenes

## Files Created/Modified

- `claude_src/novel/agents/voice-coach.md` - Voice and style consistency verification agent
  - POV violation detection (head-hopping in third_limited)
  - Tense consistency checking (past vs present slippage)
  - Forbidden phrase exact matching
  - Character voice pattern validation against voice_notes
  - Outputs JSON with CRITICAL/MAJOR/MINOR severity levels

- `claude_src/novel/agents/pacing-analyzer.md` - Pacing and rhythm analysis agent
  - Word count deviation calculation (actual vs target)
  - Intensity-aware severity (climax underwritten = MAJOR, transition overwritten = MINOR)
  - Sentence length variation analysis (monotony detection)
  - Chapter-level pacing uniformity checks
  - Outputs JSON with deviation statistics and fix suggestions

## Decisions Made

1. **POV violations are CRITICAL** - Head-hopping in third_limited breaks fundamental narrative contract, must be fixed before approval
2. **Pacing analyzer never produces CRITICAL** - Word count deviations are important but shouldn't single-handedly block publication
3. **Arc-stage-aware voice drift** - Character voice should evolve through arc (setup → resolution), so drift is expected and acceptable when aligned with arc_stage
4. **Deviation threshold system** - Clear escalation: >30% MINOR, >50% MAJOR, >100% extreme with investigative emphasis
5. **Tense shifts are MAJOR severity** - Style guide tense is fundamental constraint, violations are significant
6. **Forbidden phrases use exact match** - Simple case-insensitive string search, no regex complexity needed
7. **Evidence-based reporting** - Every issue includes expected state (from canon/state), found state (from scene), and source reference
8. **Actionable suggestions required** - Tell writer HOW to fix, not just WHAT is wrong

## Deviations from Plan

None - plan executed exactly as written. Both agents follow the established pattern from scene-writer and research specifications.

## Issues Encountered

None - agent definitions straightforward following established pattern from Phase 3.

## User Setup Required

None - no external service configuration required. Agents are internal analysis tools.

## Next Phase Readiness

**Ready for:**
- Plan 04-03: Tension monitor agent and /novel:check orchestrator command
- Voice coach and pacing analyzer provide 2 of 5 parallel checkers for /novel:check

**Foundation established:**
- Checker agent pattern proven (voice-coach and pacing-analyzer both follow structure)
- JSON output schema established for consistent reporting
- Severity classification system defined (CRITICAL/MAJOR/MINOR)
- Evidence-based issue format with actionable suggestions

**Next steps:**
- Build tension-monitor agent (final checker)
- Build /novel:check orchestrator command to spawn all 5 checkers in parallel
- Consolidate parallel checker outputs into unified quality report

---
*Phase: 04-quality-checks*
*Completed: 2026-02-24*
