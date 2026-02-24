---
phase: 03-drafting-engine
plan: 01
subsystem: drafting
tags: [prose-generation, scene-writer, agent-pattern, markdown, yaml, state-management]

# Dependency graph
requires:
  - phase: 01-foundation
    provides: State schemas, state-manager skill, agent patterns
  - phase: 02-planning-pipeline
    provides: Beat sheet format, diary planning, scene specifications
provides:
  - Scene-writer agent definition with full prose generation workflow
  - Diary format support with date headers and seasonal context
  - Standard format support with chapter headers and beat tracking
  - State update patterns for scene completion and character changes
  - Markdown output with YAML frontmatter specification
affects: [03-02-write-command, 04-revision-pipeline, 06-compilation-export]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "5-step prose generation workflow: Validate → Load Context → Generate Prose → Format Markdown → Update State"
    - "Conditional diary format handling within single agent (not separate systems)"
    - "State-first updates: file write first, then state update (prevents desync)"
    - "Beat sheet as invisible scaffolding (structure not prose template)"

key-files:
  created:
    - claude_src/novel/agents/scene-writer.md
  modified: []

key-decisions:
  - "Single agent handles both diary and standard formats (conditional logic, not separate agents)"
  - "Always read previous scene for continuity before generating prose"
  - "Word count is guidance not limit (300-3000 word acceptable range)"
  - "State update after file write (atomic operation, prevents desync)"
  - "Beat structure is invisible scaffolding (avoid mechanical prose)"

patterns-established:
  - "Diary format: first-person retrospective with date headers, seasonal context, growth milestones"
  - "Standard format: follows style_guide POV/tense with chapter headers, beat comments"
  - "YAML frontmatter with scene metadata (scene_id, chapter, scene, pov, word_count, status, date/season for diary)"
  - "HTML comments for tracking (beat summary, emotional shifts, growth milestones, seasonal themes)"
  - "State manager skill usage for all state file updates (load/update/save pattern)"

# Metrics
duration: 3min
completed: 2026-02-24
---

# Phase 3 Plan 1: Scene Writer Agent Summary

**Scene-writer agent with 5-step prose generation workflow, diary format support, Markdown output with YAML frontmatter, and state-manager integration**

## Performance

- **Duration:** 3 minutes
- **Started:** 2026-02-24T06:03:36Z
- **Completed:** 2026-02-24T06:06:58Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Complete scene-writer agent definition (913 lines) following established agent pattern
- 5-step execution workflow covering full prose generation lifecycle
- Integrated diary format support (date headers, seasons, emotional tracking, growth milestones)
- Standard format support (chapter headers, beat comments, style guide compliance)
- State update patterns using state-manager skill (story_state, character_state, timeline_state)
- Comprehensive examples demonstrating both diary and standard formats with full YAML frontmatter
- Validation section with 5 checks (file existence, frontmatter, word count, state update, beat accomplishment)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create scene-writer agent definition** - `36e95b1` (feat)

## Files Created/Modified

- `claude_src/novel/agents/scene-writer.md` - Scene prose generation agent with diary and standard format support, full execution workflow, validation, and examples

## Decisions Made

**1. Single agent for both formats**
- Rationale: Diary format is a variation on standard workflow, not fundamentally different system. Conditional logic within agent is simpler than separate agents.

**2. Always read previous scene**
- Rationale: Context continuity is critical for prose flow. Previous scene provides emotional state, open threads, and narrative momentum.

**3. Word count as guidance**
- Rationale: Target word counts from beat sheets guide pacing but shouldn't constrain quality. Acceptable range 300-3000 words allows flexibility.

**4. State update after file write**
- Rationale: Writing file first, then updating state prevents desync. If state update fails, file still exists. Reverse order risks claiming completion without file.

**5. Beat structure as invisible scaffolding**
- Rationale: Beat sheet specifies WHAT happens, not HOW to write it. Agent must avoid mechanical prose that follows beat sections literally.

**6. Diary format uses retrospective voice**
- Rationale: First-person past tense with narrator awareness creates authentic diary tone. Present-tense diary entries feel artificial.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None - agent definition created following established patterns from plot-planner, beat-planner, and diary-planner agents.

## Next Phase Readiness

**Ready for:**
- Phase 3 Plan 2: /novel:write command implementation
- Scene-writer agent can be spawned by command orchestrator
- All input dependencies defined (beat sheets, canon files, state files, diary plan)
- All output products specified (Markdown scenes with YAML frontmatter, state updates)

**No blockers:**
- Agent definition is complete and follows established patterns
- State-manager skill provides all necessary state update patterns
- Examples demonstrate both diary and standard format outputs
- Validation checks ensure scene quality and completeness

---
*Phase: 03-drafting-engine*
*Completed: 2026-02-24*
