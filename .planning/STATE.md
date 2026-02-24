# State: Novel Engine

**Project Start:** 2026-02-24
**Last Updated:** 2026-02-24
**Current Phase:** 2 (Planning Pipeline) - COMPLETE
**Current Plan:** 02-04 Complete

---

## Project Status

**Phase:** Phase 2 - Planning Pipeline (COMPLETE)
**Mode:** yolo
**Parallelization:** enabled

**Progress:**
- Phases completed: 2/6
- Plans completed: 6/18
- Requirements completed: ~16/35 (schemas, defaults, state-manager, templates, init command, canon templates, status command, git integration, plot-planner agent, beat-planner agent, diary-planner agent, outline command)

**Progress Bar:** [=============-------] 33%

---

## Current Milestone

**Milestone:** v1.0 - Core Novel Engine
**Target:** All 35 v1 requirements delivered
**Status:** In Progress

---

## Phase Status

| Phase | Name | Status | Requirements | Plans | Completion |
|-------|------|--------|--------------|-------|------------|
| 1 | Foundation & Canon System | COMPLETE | 12 | 3 | 100% |
| 2 | Planning Pipeline | COMPLETE | 4 | 3 | 100% |
| 3 | Drafting Engine | Pending | 8 | 3 | 0% |
| 4 | Quality Checks | Pending | 6 | 3 | 0% |
| 5 | Revision Loop | Pending | 2 | 3 | 0% |
| 6 | Advanced Features | Pending | 5 | 3 | 0% |

---

## Active Work

**Current Phase:** 2 - Planning Pipeline (COMPLETE)
**Current Plan:** 02-04 Complete
**Active Tasks:** None

**Ready for:** Phase 3 - Drafting Engine

---

## Recent Activity

| Date | Activity |
|------|----------|
| 2026-02-24 | Completed Plan 02-04: /novel:outline Orchestrator Command |
| 2026-02-24 | Completed Plan 02-03: Diary Planner Agent |
| 2026-02-24 | Completed Plan 02-02: Beat Planner Agent |
| 2026-02-24 | Completed Plan 02-01: Plot Planner Agent |

---

## Next Steps

1. Begin Phase 3: Drafting Engine
2. Build /novel:write command
3. Create scene-writer agent
4. Implement scene-by-scene drafting workflow

---

## Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-02-24 | 6-phase standard roadmap | Follows research-suggested build order: Foundation -> Planning -> Drafting -> Quality -> Revision -> Advanced |
| 2026-02-24 | Diary features in Phase 3 | Natural fit with drafting engine, date/time tracking needed for scene writing |
| 2026-02-24 | All checkers in Phase 4 | Parallel execution of 5 checking agents more efficient than spreading across phases |
| 2026-02-24 | Version management in Phase 6 | Requires stable revision loop from Phase 5 before implementing snapshots |
| 2026-02-24 | JSON Schema Draft 2020-12 | Most current standard with good tooling support |
| 2026-02-24 | schema_version field in state files | Enables future migrations without breaking existing projects |
| 2026-02-24 | State-manager as skill (Markdown) | Claude Code pattern using Markdown, not code libraries |
| 2026-02-24 | Four-layer directory architecture | Clear separation: canon (immutable), state (mutable), beats (structure), draft (output) |
| 2026-02-24 | Self-documenting canon templates | Templates include inline help, examples, and enforcement notes - no external docs needed |
| 2026-02-24 | Default quiet mode for /novel:init | Interactive questionnaire via --interactive flag, not default |
| 2026-02-24 | Symlink for command discoverability | .claude/commands/novel/init.md -> claude_src for single source of truth |
| 2026-02-24 | Opportunistic canon commit on status | Commit canon changes when checking status, not just before outline/write |
| 2026-02-24 | Graceful git degradation | Git operations skip silently when unavailable, don't block workflow |
| 2026-02-24 | 3-act vs 5-act structure detection | <80k words = 3-act, >80k or complex = 5-act, based on length + complexity scoring |
| 2026-02-24 | Save the Cat as primary framework | 15-beat structure with percentage-based markers, Hero's Journey as optional overlay |
| 2026-02-24 | Beat percentage system | Each beat maps to specific story percentage and word count for precise targeting |
| 2026-02-24 | Character arc mapping to plot | Track emotional state, lie→truth progression across all beats for coherence |
| 2026-02-24 | Scene ID format chXX_sYY with zero-padding | Ensures alphabetical sorting matches chronological order, consistent parsing with regex |
| 2026-02-24 | Beat sheets are 150-300 word planning notes | Provides structure for scene-writer without over-constraining creative decisions (progressive disclosure) |
| 2026-02-24 | 2-5 scenes per chapter based on complexity | Balances narrative granularity with practical drafting workload |
| 2026-02-24 | POV rotation logic for multi-POV stories | Respects narrative voice decisions while ensuring fair character representation |
| 2026-02-24 | Sequential agent execution (plot → beat → diary) | Ensures dependencies are met - beat-planner needs outline from plot-planner, diary-planner needs scenes from beat-planner |
| 2026-02-24 | Auto-commit canon before outline generation | Preserves user edits in git history before agents read canon, enables rollback if generated outline is poor |
| 2026-02-24 | Backup beats/ before regeneration | Prevents data loss if user accidentally regenerates - restore from beats.backup.[timestamp] |
| 2026-02-24 | Conditional diary-planner invocation | Only runs when format == "diary" - chapter format doesn't need diary-specific planning |
| 2026-02-24 | Comprehensive validation in /novel:outline | Guides user through issues with actionable error messages rather than cryptic failures |

---

## Blockers

*None*

---

## Technical Debt

*None yet*

---

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Multi-agent coordination complexity | High | Use wave-based pipeline pattern, clear agent contracts |
| Context window limits with large stories | High | Implement scene-by-scene processing, state compression |
| Continuity drift over many scenes | Medium | Checker agents run after every scene, quality gate enforcement |
| State mutation conflicts | Medium | Single source of truth in JSON state files, atomic writes |

---

## Session Continuity

**Last session:** 2026-02-24 05:40 UTC
**Stopped at:** Completed Plan 02-04 (/novel:outline Command) - Phase 2 Complete
**Resume file:** .planning/phases/03-drafting-engine/03-01-PLAN.md

---

## Phase 1 Artifacts Summary

| Artifact | Location |
|----------|----------|
| State Schemas | claude_src/novel/schemas/*.schema.json |
| Default State | claude_src/novel/schemas/*.default.json |
| State Manager | claude_src/novel/utils/state-manager.md |
| Canon Templates | claude_src/novel/templates/*.md |
| /novel:init | claude_src/novel/commands/init.md |
| /novel:status | claude_src/novel/commands/status.md |
| Git Integration | claude_src/novel/skills/git-integration.md |
| Command Symlinks | .claude/commands/novel/*.md |

## Phase 2 Artifacts Summary

| Artifact | Location |
|----------|----------|
| plot-planner Agent | claude_src/novel/agents/plot-planner.md |
| beat-planner Agent | claude_src/novel/agents/beat-planner.md |
| diary-planner Agent | claude_src/novel/agents/diary-planner.md |
| /novel:outline Command | claude_src/novel/commands/outline.md |

---

*State updated: 2026-02-24*
*Phase 2 complete, ready for Phase 3*
