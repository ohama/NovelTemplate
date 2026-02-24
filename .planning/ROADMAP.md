# Roadmap: Novel Engine

**Created:** 2026-02-24
**Mode:** yolo
**Depth:** standard (6 phases, 3-5 plans each)
**Parallelization:** enabled

## Overview

Building a multi-agent novel writing engine for Claude Code that maintains consistency in characters, world-building, and timeline while enabling natural story progression. Supports diary format, chapter-based novels, short stories, and serialized web novels.

**Architecture:** Canon → State → Structure → Draft (wave-based multi-agent pipeline)
**Output:** Markdown + EPUB
**Development:** claude_src/

---

## Phase 1: Foundation & Canon System

**Goal:** Establish project structure, state management, canon templates, and basic commands

**Requirements:** FOUND-01, FOUND-02, FOUND-03, FOUND-04, CANON-01, CANON-02, CANON-03, CANON-04, CANON-05, CANON-06, CMD-01, CMD-04

**Success Criteria:**
- User can run `/novel:init` and see canon/, state/, beats/, draft/ directories created
- User can view story_state.json, character_state.json, timeline_state.json, style_state.json files
- User can edit premise.md, characters.md, world.md, style_guide.md, timeline.md, constraints.md with guided templates
- User can run `/novel:status` and see "No scenes written yet" message
- Git automatically commits canon file changes with descriptive messages

**Plans:** 3 plans

Plans:
- [x] 01-01-PLAN.md — Directory Structure & State Initialization
- [x] 01-02-PLAN.md — /novel:init Command
- [x] 01-03-PLAN.md — /novel:status Command & Git Integration

---

## Phase 2: Planning Pipeline

**Goal:** Generate story structure from canon through plot and beat planning

**Requirements:** AGENT-01, AGENT-02, AGENT-03, CMD-05

**Success Criteria:**
- User can run `/novel:outline` and see chapter/arc structure generated from premise.md
- User can view beats/outline.md with plot points and story beats
- User can see diary-specific planning (date ranges, seasonal arcs) in beats/diary_plan.md
- Outline respects constraints.md and timeline.md boundaries
- Beat plans include scene specs ready for drafting

**Plans:** 4 plans

Plans:
- [x] 02-01-PLAN.md — Plot Planner Agent (Save the Cat, 3-act/5-act structure)
- [x] 02-02-PLAN.md — Beat Planner Agent (scene-level beat generation)
- [x] 02-03-PLAN.md — Diary Planner Agent (temporal structure, seasonal arcs)
- [x] 02-04-PLAN.md — /novel:outline Command (orchestrate all agents, git commit)

---

## Phase 3: Drafting Engine

**Goal:** Write prose from beat specs with diary format support and Markdown output

**Requirements:** AGENT-04, CMD-02, DIARY-01, DIARY-02, DIARY-03, DIARY-04, OUT-01

**Success Criteria:**
- User can run `/novel:write` and see next scene drafted in draft/scene_001.md
- Diary entries include ISO 8601 timestamps, season/weather descriptions
- User can see emotional state and growth milestones tracked in state files
- Scenes maintain character voice from style_guide.md
- Markdown files are well-formatted with proper headers and scene breaks

**Plans:** 2 plans

Plans:
- [x] 03-01-PLAN.md — Scene Writer Agent (prose generation, diary format, Markdown output)
- [x] 03-02-PLAN.md — /novel:write Command (orchestrate scene-writer, git commit, verification)

---

## Phase 4: Quality Checks

**Goal:** Automated consistency verification across canon, timeline, voice, pacing, and tension

**Requirements:** AGENT-07, AGENT-08, AGENT-09, AGENT-10, AGENT-11, CMD-03

**Success Criteria:**
- User can run `/novel:check` and see report of canon contradictions
- Timeline violations are flagged with specific scene references
- Character voice inconsistencies are detected with examples
- Pacing issues (rushed/dragging scenes) are identified
- Tension levels are analyzed with recommendations
- Check reports include actionable fix suggestions

**Plans:** 3 plans

Plans:
- [x] 04-01-PLAN.md — Canon & Timeline Checkers (canon-checker, timeline-keeper agents)
- [x] 04-02-PLAN.md — Voice & Pacing Analyzers (voice-coach, pacing-analyzer agents)
- [x] 04-03-PLAN.md — Tension Monitor & /novel:check Command (tension-monitor, orchestration, parallel execution)

---

## Phase 5: Revision Loop

**Goal:** Editorial feedback and quality gating for iterative improvement

**Requirements:** AGENT-05, AGENT-06

**Success Criteria:**
- User receives editor feedback listing 3-5 improvement areas per scene
- Quality gate approves/rejects scenes based on checker results
- User can see revision history tracking which issues were addressed
- Rejected scenes display actionable editorial feedback; user reruns /novel:write to revise
- Approved scenes are marked as "final" in state files

**Plans:** 3 plans

Plans:
- [x] 05-01-PLAN.md — Editorial & Quality Gate Agents (novel-editor, novel-quality-gate)
- [x] 05-02-PLAN.md — Pipeline Integration & State Tracking (extend /novel:check, revision_history schema)
- [x] 05-03-PLAN.md — Verification & Testing (end-to-end revision loop validation)

---

## Phase 6: Advanced Features

**Goal:** Version management, EPUB export, and publishing workflow

**Requirements:** VER-01, VER-02, VER-03, OUT-02, CMD-06

**Success Criteria:**
- User can see automatic snapshots saved in draft/versions/ after each revision cycle
- User can run version diff commands to compare drafts
- User can restore previous versions by snapshot ID
- User can run `/novel:publish` and receive compiled EPUB file
- EPUB includes proper metadata, chapters, and table of contents

**Plans:**
1. **Version Management**
   - Implement snapshot system (draft/versions/YYYYMMDD_HHMMSS/)
   - Build diff tool for version comparison
   - Add rollback functionality
   - Update state files with version references

2. **EPUB Export**
   - Integrate Pandoc for EPUB generation
   - Compile Markdown scenes into chapters
   - Add metadata from premise.md (title, author, genre)
   - Generate table of contents

3. **/novel:publish Command**
   - Build publishing skill
   - Validate all scenes are approved
   - Compile Markdown into single manuscript
   - Generate EPUB with Pandoc
   - Output to published/ directory

---

## Requirements Coverage

**v1 Requirements:** 35 total
**Mapped to phases:** 35
**Unmapped:** 0

**Phase Distribution:**
- Phase 1: 12 requirements (Foundation + Canon)
- Phase 2: 4 requirements (Planning)
- Phase 3: 8 requirements (Drafting + Diary + Output)
- Phase 4: 6 requirements (Quality Checks)
- Phase 5: 2 requirements (Revision)
- Phase 6: 5 requirements (Advanced Features)

**Validation:** All v1 requirements mapped to exactly one phase

---

## Build Order Rationale

**Phase 1 before 2:** Must establish canon system before generating structure from it
**Phase 2 before 3:** Need beat specs before drafting prose
**Phase 3 before 4:** Need draft scenes to check
**Phase 4 before 5:** Need checker reports to drive editorial feedback
**Phase 5 before 6:** Need stable revision workflow before version management

**Critical Path:** Canon → Planning → Drafting → Checking → Revision → Publishing

---

*Roadmap created: 2026-02-24*
*Phase 1 completed: 2026-02-24*
*Phase 2 completed: 2026-02-24*
*Phase 3 completed: 2026-02-24*
*Phase 4 completed: 2026-02-24*
*Phase 5 completed: 2026-02-24*
*Next step: Plan Phase 6*
