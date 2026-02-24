---
phase: 03-drafting-engine
plan: 02
subsystem: orchestration
tags: [command, scene-writer, git-integration, state-manager, drafting, workflow]

# Dependency graph
requires:
  - phase: 03-01
    provides: scene-writer agent for prose generation
  - phase: 02-04
    provides: /novel:outline command that generates beat sheets
  - phase: 01-06
    provides: git-integration skill for scene commits
  - phase: 01-03
    provides: state-manager skill for state reads
provides:
  - /novel:write command orchestrator for scene drafting workflow
  - Sequential scene generation with progress tracking
  - Auto-commit of completed scenes
  - Validation and error handling for drafting pipeline
affects: [04-quality-checks, 05-revision-loop, scene-rendering]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Command orchestration pattern: validate -> load -> spawn -> verify -> commit -> report"
    - "Progressive scene generation with continuation prompts"
    - "Graceful git degradation for commit operations"

key-files:
  created:
    - claude_src/novel/commands/write.md
    - .claude/commands/novel/write.md
  modified: []

key-decisions:
  - "Sequential execution flow ensures data consistency across validation, context loading, agent spawn, verification, and commit"
  - "User sees continuation prompt after each scene to encourage iterative drafting"
  - "Git commit uses git-integration skill with graceful degradation if git unavailable"
  - "Agent does state writes, command only reads state for validation"
  - "Previous scene context passed to scene-writer for continuity"

patterns-established:
  - "Orchestrator pattern: Command validates and coordinates, agent does actual work"
  - "Progress reporting shows N of total scenes with continuation encouragement"
  - "Error handling provides actionable guidance for common failure modes"

# Metrics
duration: 8min
completed: 2026-02-24
---

# Phase 3 Plan 02: /novel:write Orchestrator Command Summary

**Scene drafting command with validation, context loading, agent coordination, git commits, and progress tracking**

## Performance

- **Duration:** 8 min
- **Started:** 2026-02-24T06:07:29Z
- **Completed:** 2026-02-24T06:15:29Z
- **Tasks:** 3 (2 auto + 1 checkpoint)
- **Files modified:** 2 (1 created + 1 symlink)

## Accomplishments
- Complete /novel:write command orchestrator with 6-step execution flow
- Validation checks ensure prerequisites met before drafting
- Context loading assembles beat sheet, canon, state, and previous scene
- Scene-writer agent spawned with full context for prose generation
- Git integration commits completed scenes automatically
- Progress reporting shows completion status and encourages continuation
- Human verification checkpoint confirmed prose quality meets standards

## Task Commits

Each task was committed atomically:

1. **Task 1: Create /novel:write command definition** - `4979ee6` (feat)
2. **Task 2: Create command symlink for discoverability** - `012beff` (feat)
3. **Task 3: Human verification checkpoint** - (approved - no commit)

**Plan metadata:** (pending - this commit)

## Files Created/Modified
- `claude_src/novel/commands/write.md` (1144 lines) - Complete command orchestrator with validation, context loading, agent spawn, verification, git commit, and reporting
- `.claude/commands/novel/write.md` (symlink) - Command discoverability symlink pointing to ../../../claude_src/novel/commands/write.md

## Decisions Made

**1. Sequential execution flow (validate -> load -> spawn -> verify -> commit -> report)**
- **Rationale:** Ensures data consistency. Each step depends on previous step success. Validation prevents wasted work, context loading ensures agent has everything needed, verification confirms success before committing.

**2. Agent does state writes, command only reads**
- **Rationale:** Clear separation of concerns. Command orchestrates workflow, agent owns state mutations. Prevents double-writes and state conflicts.

**3. Previous scene passed to scene-writer for continuity**
- **Rationale:** Context continuity critical for prose flow. Previous scene provides emotional state and narrative momentum needed for smooth transitions.

**4. Continuation prompt encourages iterative drafting**
- **Rationale:** User experience improvement. Showing "Continue to next scene? Type /novel:write" reduces friction for multi-scene drafting sessions.

**5. Git commit uses git-integration skill with graceful degradation**
- **Rationale:** Follows established pattern from /novel:outline. Git commits valuable for tracking progress but not blocking - skip silently if git unavailable.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None - all tasks completed as specified.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Ready for Phase 4 (Quality Checks):**
- Complete drafting pipeline from beat sheets to prose scenes
- Scenes tracked in state files with status progression
- Git history captures scene completion for version control
- Prose quality verified through human checkpoint

**Dependencies delivered for downstream phases:**
- 04-quality-checks can read drafted scenes from draft/scenes/
- 05-revision-loop can read scene status from scene_index
- Scene rendering pipeline can compile scenes into chapters

**No blockers or concerns.**

**User workflow complete:**
1. `/novel:init` - Initialize project and canon
2. `/novel:outline` - Generate beat sheets
3. `/novel:write` - Draft scenes iteratively
4. (Next: `/novel:check` - Run quality checks)

---
*Phase: 03-drafting-engine*
*Completed: 2026-02-24*
