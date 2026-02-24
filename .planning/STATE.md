# State: Novel Engine

**Project Start:** 2026-02-24
**Last Updated:** 2026-02-24
**Current Phase:** 4 (Quality Checks) - COMPLETE
**Current Plan:** 04-03 Complete

---

## Project Status

**Phase:** Phase 4 - Quality Checks (COMPLETE)
**Mode:** yolo
**Parallelization:** enabled

**Progress:**
- Phases completed: 4/6
- Plans completed: 12/18
- Requirements completed: 33/35 (Phase 1: 12, Phase 2: 4, Phase 3: 7, Phase 4: 6, Phase 5: 0, Phase 6: 0)

**Progress Bar:** [====================] 67%

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
| 3 | Drafting Engine | COMPLETE | 7 | 2 | 100% |
| 4 | Quality Checks | COMPLETE | 6 | 3 | 100% |
| 5 | Revision Loop | Pending | 2 | 3 | 0% |
| 6 | Advanced Features | Pending | 5 | 3 | 0% |

---

## Active Work

**Current Phase:** 4 - Quality Checks (COMPLETE)
**Current Plan:** 04-03 Complete
**Active Tasks:** None

**Ready for:** Plan Phase 5 (Revision Loop)

---

## Recent Activity

| Date | Activity |
|------|----------|
| 2026-02-24 | Completed Plan 04-03: Tension Monitor & /novel:check Command |
| 2026-02-24 | Phase 4 Complete: Quality Checks (all 3 plans done) |
| 2026-02-24 | Completed Plan 04-02: Voice & Pacing Analyzers |
| 2026-02-24 | Completed Plan 04-01: Canon & Timeline Checkers |

---

## Next Steps

1. Plan Phase 5: Revision Loop (2 requirements, 3 plans estimated)
2. Execute Phase 5 plans (scene revision workflow, quality integration)
3. Plan Phase 6: Advanced Features (5 requirements, 3 plans estimated)
4. Execute Phase 6 plans (version management, context tracking)

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
| 2026-02-24 | Single agent for both diary and standard formats | Conditional logic within scene-writer simpler than separate agents - diary is variation not different system |
| 2026-02-24 | Always read previous scene for continuity | Context continuity critical for prose flow - previous scene provides emotional state and narrative momentum |
| 2026-02-24 | Word count as guidance not limit | Target word counts guide pacing but quality over constraints - 300-3000 word range allows flexibility |
| 2026-02-24 | State update after file write | Writing file first prevents desync - if state update fails, file still exists (atomic operation) |
| 2026-02-24 | Beat structure as invisible scaffolding | Beat sheet specifies WHAT happens not HOW - avoid mechanical prose following beat sections literally |
| 2026-02-24 | Diary format uses retrospective voice | First-person past tense with narrator awareness creates authentic diary tone - present tense feels artificial |
| 2026-02-24 | Sequential execution flow in /novel:write | validate -> load -> spawn -> verify -> commit -> report ensures data consistency across drafting workflow |
| 2026-02-24 | Agent owns state writes, command only reads | Clear separation of concerns - command orchestrates, agent mutates - prevents double-writes and conflicts |
| 2026-02-24 | Continuation prompt encourages iterative drafting | User sees "Continue to next scene? Type /novel:write" after each scene - reduces friction for multi-scene sessions |
| 2026-02-24 | Three-tier severity system for quality issues | CRITICAL (blocking), MAJOR (should fix), MINOR (nice to fix) enables prioritization without overwhelm |
| 2026-02-24 | Character knowledge timeline for canon checking | Tracks when characters learn information to detect premature knowledge violations |
| 2026-02-24 | Day-of-week validation for diary format | Timeline keeper validates date matches day-of-week using calendar calculation (flags as MINOR) |
| 2026-02-24 | Flashback exemption from timeline reversals | Scenes marked as flashback/memory get different chronology rules to prevent false positives |
| 2026-02-24 | Evidence structure for quality issues | All issues include expected (from canon), found (from scene), source (file reference) for verification |
| 2026-02-24 | Actionable fix suggestions in quality reports | Suggestions specify exact changes ("Change 'blonde' to 'brown'") not vague instructions |
| 2026-02-24 | Tension monitor never produces CRITICAL | Tension is subjective and reader-dependent, so absence of conflict is MAJOR (should fix) not CRITICAL (blocking) |
| 2026-02-24 | Flat section threshold at 3+ consecutive scenes | Allows for intentional pacing breathers (1-2 scenes) but flags extended flat sections (3+) as MAJOR |
| 2026-02-24 | Conflict marker heuristics approach | Identify opposition, stakes, obstacles, tension language; normalize by scene length; automated detection flags gaps for human review |
| 2026-02-24 | Parallel execution for all 5 checkers | All checkers spawn simultaneously via Task tool - 5x faster than sequential, no inter-checker dependencies |
| 2026-02-24 | Timestamped report directories | Format: check_reports/YYYY-MM-DD_HH-MM/ preserves historical reports for tracking fixes over time |
| 2026-02-24 | Report consolidation sorts by severity | Merge all issues, sort CRITICAL → MAJOR → MINOR, then by scene_id for prioritized action list |

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

**Last session:** 2026-02-24
**Stopped at:** Phase 4 complete (all 3 plans executed)
**Resume file:** None - ready for Phase 5 planning

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

## Phase 3 Artifacts Summary

| Artifact | Location |
|----------|----------|
| scene-writer Agent | claude_src/novel/agents/scene-writer.md |
| /novel:write Command | claude_src/novel/commands/write.md |

## Phase 4 Artifacts Summary (Complete)

| Artifact | Location |
|----------|----------|
| canon-checker Agent | claude_src/novel/agents/canon-checker.md |
| timeline-keeper Agent | claude_src/novel/agents/timeline-keeper.md |
| voice-coach Agent | claude_src/novel/agents/voice-coach.md |
| pacing-analyzer Agent | claude_src/novel/agents/pacing-analyzer.md |
| tension-monitor Agent | claude_src/novel/agents/tension-monitor.md |
| /novel:check Command | claude_src/novel/commands/check.md |

---

*State updated: 2026-02-24*
*Phase 4 complete - All quality checking agents and orchestrator built*
