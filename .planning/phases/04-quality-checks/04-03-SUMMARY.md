---
phase: 04-quality-checks
plan: 03
subsystem: quality-verification
tags: [tension-analysis, check-command, parallel-orchestration, quality-reporting]

# Dependency graph
requires:
  - phase: 01-foundation
    provides: State schemas, canon templates, command pattern
  - phase: 02-planning
    provides: Beat structure with tension expectations
  - phase: 03-drafting
    provides: Draft scenes for analysis
  - phase: 04-01
    provides: Canon checker and timeline keeper agents, checker pattern
  - phase: 04-02
    provides: Voice coach and pacing analyzer agents, JSON output format
provides:
  - Tension monitor agent for conflict tracking and tension curve analysis
  - /novel:check command orchestrating all 5 quality checkers in parallel
  - Unified quality report generation with severity-sorted issues
  - Complete quality verification pipeline (5 checkers + orchestrator)
affects: [05-revision-loop, quality-pipeline, novel-workflow]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Parallel checker execution via Task tool spawning"
    - "Tension curve tracking with conflict marker detection"
    - "Report consolidation from multiple agent outputs"
    - "Timestamped report directory structure (check_reports/YYYY-MM-DD_HH-MM/)"

key-files:
  created:
    - claude_src/novel/agents/tension-monitor.md
    - claude_src/novel/commands/check.md
    - .claude/commands/novel/check.md
  modified: []

key-decisions:
  - "Tension monitor never produces CRITICAL severity - tension is subjective, not blocking"
  - "Parallel execution of all 5 checkers for efficiency (5x faster than sequential)"
  - "Flat section detection requires 3+ consecutive low-tension scenes"
  - "Conflict marker heuristics include opposition, stakes, obstacles, tension words"
  - "Reports saved to timestamped directories for historical tracking"
  - "Consolidated report sorts by severity: CRITICAL → MAJOR → MINOR"
  - "Individual checker JSONs saved alongside summary.md for detailed analysis"

patterns-established:
  - "Multi-agent orchestration: Command spawns agents in parallel, collects JSON, consolidates"
  - "Tension curve visualization data included in summary for narrative arc review"
  - "Report format: Summary table → Critical issues → Major issues → Minor issues → Recommendations"
  - "Each checker outputs standardized JSON for easy consolidation"

# Metrics
duration: <1min
completed: 2026-02-24
---

# Phase 04 Plan 03: Tension Monitor & /novel:check Command Summary

**Complete quality verification pipeline with tension monitor detecting conflict absence and /novel:check orchestrating 5 parallel checkers into unified severity-sorted report**

## Performance

- **Duration:** <1 min (continuation from checkpoint approval)
- **Started:** 2026-02-24T06:44:26Z
- **Completed:** 2026-02-24T07:01:29Z
- **Tasks:** 4 (3 auto + 1 checkpoint)
- **Files created:** 3

## Accomplishments

- Tension monitor agent analyzes conflict markers, tracks tension curve across scenes, detects flat sections
- Conflict detection heuristics identify opposition, stakes, obstacles, and tension language
- Flat section detection flags 3+ consecutive low-tension scenes as MAJOR issue
- Tension curve mapped against Save the Cat beat expectations (Catalyst rise, Midpoint high, Finale peak)
- /novel:check command spawns all 5 checkers in parallel for efficient quality verification
- Results consolidated from canon-checker, timeline-keeper, voice-coach, pacing-analyzer, tension-monitor
- Unified report generation with severity sorting and timestamped directory storage
- Command symlink enables /novel:check discoverability in Claude Code

## Task Commits

Each task was committed atomically:

1. **Task 1: Create tension-monitor agent definition** - `ead0adb` (feat)
   - 276 lines with complete role/execution/validation sections
   - Loads beats/outline.md for expected tension arc
   - Analyzes draft/scenes/*.md for conflict markers
   - Detects no-conflict scenes, flat sections, tension curve mismatches
   - Outputs JSON with tension curve visualization data

2. **Task 2: Create /novel:check command** - `f5f06a1` (feat)
   - 526 lines with complete execution/error-handling sections
   - Validates prerequisites (story_state.json, drafted scenes)
   - Spawns 5 checkers in parallel via Task tool
   - Consolidates results, sorts by severity
   - Saves reports to check_reports/[timestamp]/ directory
   - Displays summary table and prioritized issue list

3. **Task 3: Create command symlink** - `8e90d9d` (feat)
   - Symlink: .claude/commands/novel/check.md → claude_src/novel/commands/check.md
   - Enables /novel:check command discoverability

4. **Task 4: Human verification checkpoint** - APPROVED
   - Reviewed all 5 checker agents and orchestrator command
   - Verified JSON output consistency and severity classification
   - Confirmed parallel execution pattern and report format

## Files Created/Modified

- `claude_src/novel/agents/tension-monitor.md` - Conflict and tension curve monitoring agent
  - Detects scenes with no apparent conflict (MAJOR)
  - Flags 3+ consecutive flat tension scenes (MAJOR)
  - Compares actual tension curve to expected arc (MINOR if misaligned)
  - Includes tension curve visualization data in summary

- `claude_src/novel/commands/check.md` - Quality check orchestrator command
  - Validates prerequisites before running checkers
  - Spawns all 5 checkers in parallel for efficiency
  - Consolidates JSON outputs from all checkers
  - Sorts issues by severity (CRITICAL → MAJOR → MINOR)
  - Saves timestamped reports to check_reports/YYYY-MM-DD_HH-MM/
  - Displays actionable summary with recommendations

- `.claude/commands/novel/check.md` - Command symlink for discoverability
  - Enables Claude Code to find /novel:check command
  - Points to claude_src/novel/commands/check.md

## Decisions Made

**Tension subjectivity principle:**
- Tension issues never marked CRITICAL - tension is subjective and reader-dependent
- Absence of conflict is MAJOR (should fix) not CRITICAL (blocking)
- Rationale: Different genres have different tension requirements, don't over-constrain

**Flat section threshold:**
- 3+ consecutive low-tension scenes triggers MAJOR severity
- Allows for intentional pacing breathers (1-2 scenes)
- Rationale: Extended flat sections lose reader engagement, but brief pauses are narrative technique

**Conflict marker heuristics:**
- Identify opposition, stakes, obstacles, tension language, dialogue conflict
- Normalize by scene length to prevent length bias
- Classify into low/medium/high/peak/release levels
- Rationale: Automated detection is imperfect but flags obvious gaps for human review

**Parallel execution strategy:**
- All 5 checkers spawn simultaneously via Task tool
- No inter-checker dependencies
- 5x faster than sequential execution
- Rationale: Quality checking is bottleneck - parallel processing critical for usability

**Report consolidation approach:**
- Merge all issues into single array
- Sort by severity first (CRITICAL → MAJOR → MINOR), then by scene_id
- Save individual checker JSONs for detailed analysis
- Generate summary.md with prioritized issue list
- Rationale: Users need both high-level overview and drill-down capability

**Timestamped report directories:**
- Format: check_reports/YYYY-MM-DD_HH-MM/
- Preserves historical reports for tracking fixes over time
- Each run creates new directory
- Rationale: Writers may run checks multiple times during revision, history valuable

## Deviations from Plan

None - plan executed exactly as written. Human verification checkpoint approved as expected.

## Issues Encountered

None. Continuation from checkpoint approval was straightforward - only needed to create SUMMARY.md and commit metadata.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Phase 4 Complete:**
- All 5 quality checker agents operational:
  - canon-checker (Plan 04-01)
  - timeline-keeper (Plan 04-01)
  - voice-coach (Plan 04-02)
  - pacing-analyzer (Plan 04-02)
  - tension-monitor (Plan 04-03)
- /novel:check command orchestrates parallel execution
- Unified quality reporting system functional

**Ready for Phase 5: Revision Loop**
- Quality verification pipeline complete
- Ready to build revision workflow integrating quality checks
- Foundation for iterative drafting and improvement cycles

**Provides to Phase 5:**
- Complete quality verification system
- Severity-based issue prioritization
- Actionable fix suggestions
- Historical report tracking

**Quality pipeline workflow:**
1. Writer uses /novel:write to draft scenes
2. Writer runs /novel:check to verify quality
3. Writer reviews check_reports/[timestamp]/summary.md
4. Writer fixes CRITICAL and MAJOR issues
5. Writer re-runs /novel:check to confirm fixes
6. Repeat until all scenes pass quality gates

---
*Phase: 04-quality-checks*
*Completed: 2026-02-24*
