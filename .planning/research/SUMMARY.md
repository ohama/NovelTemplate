# Research Summary

**Project**: Multi-Agent Novel Writing Engine for Claude Code
**Date**: 2026-02-24
**Purpose**: Executive summary for roadmap creation

---

## Stack

**Core Philosophy**: Plain text files + JSON state + Claude Code tools = Complete novel writing system

**Technology Decisions**:
- **Runtime**: Claude Code skill system (no external dependencies)
- **State**: JSON files (git-native, human-readable, schema-validated)
- **Canon**: Markdown files with frontmatter (immutable truth sources)
- **Agents**: 10+ specialized agents in `.claude/agents/novel-*.md`
- **Commands**: User-facing workflows in `.claude/commands/novel/`
- **EPUB Export**: Pandoc (battle-tested, one command)
- **Version Control**: Git (atomic commits per scene/outline)

**Explicitly Avoided**:
- SQLite/databases (breaks file-based simplicity)
- Web frameworks (CLI-only tool)
- Python runtime (Node.js for consistency with existing hooks)
- Heavy AI frameworks (LangChain, LlamaIndex)

---

## Features

### Table Stakes
**Must-have for viability**:
- Scene/chapter hierarchical organization
- Canon system (characters, world, timeline, style guide, constraints)
- State persistence (JSON for progress, arcs, chronology)
- Character/timeline/canon consistency checking
- Multi-agent pipeline (plot → beats → write → check → revise)
- Markdown output with clear scene boundaries

### Differentiators
**Competitive advantages**:
- **AI-native multi-agent architecture**: 10+ specialized agents (plot_planner, beat_planner, scene_writer, canon_checker, timeline_keeper, voice_coach, pacing_analyzer, tension_monitor, editor, quality_gate)
- **Git-native version control**: Treat drafts as code (commit, branch, diff, merge entire story state)
- **Diary/journal format support**: First-class date-driven writing with seasonal tracking, emotional arcs, growth milestones
- **Claude Code native integration**: Skills-based commands, context-aware, no separate app
- **Programmatic canon enforcement**: Style as code, forbidden phrases detection, constraint satisfaction

### Anti-Features
**Deliberately avoid**:
- Complex GUI/visual tools (users chose CLI)
- Publishing/formatting features (use Pandoc/Reedsy)
- Kitchen sink bloat (images, research storage, word count goals)
- Forced writing methods (support both planners and pantsers)
- Proprietary file formats (Markdown + JSON only)
- AI overreach ("write entire book" button)

---

## Architecture

**Core Pattern**: Canon-driven state machine with wave-based multi-agent pipeline

### Four Layers

**1. Canon Layer (Immutable Truth)**
```
canon/
  ├── premise.md         # Core concept, theme
  ├── world.md           # Setting, rules
  ├── characters.md      # Character profiles
  ├── style_guide.md     # Voice, tone, POV, tense
  ├── timeline.md        # Chronology constraints
  └── constraints.md     # Story boundaries
```
**Principle**: Canon is law. If draft conflicts with canon, draft must change.

**2. State Layer (Mutable JSON)**
```
state/
  ├── story_state.json      # Progress, scene status, threads
  ├── character_state.json  # Arcs, voice notes
  ├── timeline_state.json   # Events, dates
  └── style_state.json      # POV, tense tracking
```
**Principle**: Agents update state after each operation. State serves as checkpoint.

**3. Structure Layer (Plot Architecture)**
```
beats/
  ├── outline.md         # High-level story arc
  ├── act_structure.md   # 3-act/5-act breakdown
  └── beat_plan.md       # Scene specifications
```
**Principle**: Plan before drafting. Each scene gets spec (goal, obstacle, outcome).

**4. Draft Layer (Output)**
```
draft/
  ├── scenes/           # ch01_s01.md, ch01_s02.md
  ├── chapters/         # Compiled chapters
  └── versions/         # Revision history (v1_draft/, v2_rewrite/)
```
**Principle**: One sentence per line for git-friendly diffs.

### Agent Execution Model

**Wave-based parallelism**:
1. **Wave 1**: Planning agents (plot-planner, beat-planner)
2. **Wave 2**: Drafting agent (scene-writer)
3. **Wave 3**: Checking agents (parallel: canon-checker, timeline-keeper, voice-coach, pacing-analyzer, tension-monitor)
4. **Wave 4**: Quality gate → APPROVED or REVISE (spawns editor agent)

**10 Core Agents**:
- `novel-plot-planner`: Create story outline from canon
- `novel-beat-planner`: Generate scene specifications
- `novel-scene-writer`: Draft prose from specs
- `novel-canon-checker`: Detect canon contradictions
- `novel-timeline-keeper`: Validate chronology
- `novel-voice-coach`: Character voice consistency
- `novel-pacing-analyzer`: Rhythm and flow
- `novel-tension-monitor`: Conflict and stakes
- `novel-editor`: Rewrite based on issues
- `novel-quality-gate`: Approve/reject decisions

### Data Flow Example

```
/novel:draft
  → Load current scene pointer from state
  → Wave 1: Spawn beat-planner → Scene Spec
  → Wave 2: Spawn scene-writer → Draft scene
  → Wave 3: Spawn 5 checkers (parallel) → Issues lists
  → Wave 4: Spawn quality-gate → APPROVED/REVISE
      If REVISE: Spawn editor → Revised draft → Re-check
  → Update story_state.json, commit scene
```

---

## Critical Pitfalls

**Top 5 threats to project success**:

### 1. Multi-Agent Coordination Collapse
**Problem**: Inter-agent misalignment is #1 failure mode (36.94% of failures). "Bag of Agents" creates 17.2x error amplification.

**Prevention**:
- Design hierarchical agent topology (not flat)
- Standardize all communication on JSON
- Implement explicit state machines for phase transitions
- Add circuit breakers to prevent infinite loops
- **Address in**: Phase 1 (Architecture) — Must be baked into initial design

### 2. Narrative Continuity Fragmentation
**Problem**: LLMs systematically fail on memory, goal persistence, style stability, and persona continuity. Facts forgotten between sessions.

**Prevention**:
- Implement persistent cross-session priority registers
- Build explicit memory systems beyond context windows
- Create verification checkpoints validating continuity against canon
- "Canon is law" enforcement at every writing stage
- **Address in**: Phase 2 (Canon) & Phase 4 (Pipeline)

### 3. Context Window Memory Cliff
**Problem**: At 32K tokens, LLMs drop below 50% accuracy. Critical canon details get lost mid-generation.

**Prevention**:
- Keep CLAUDE.md under 2,500 tokens (~100 lines)
- Architect canon as modular focused files
- Use RAG-style retrieval (load only relevant canon per scene)
- Implement summarization layers for historical context
- **Address in**: Phase 2 (Canon) & Phase 3 (State)

### 4. State Mutation Without Verification
**Problem**: State corruption leads to compounding errors. Corrupted timeline = all subsequent scenes wrong.

**Prevention**:
- Treat state as append-only (versioned history)
- JSON schema validation on every write
- State transition validators (only legal moves allowed)
- Automated consistency checks
- Never mutate directly—always through validated transforms
- **Address in**: Phase 3 (State Management)

### 5. Jumping to Code Without Architecture
**Problem**: Plan mode reduces architecture errors by 45%, yet most skip planning. Results in incompatible components mid-development.

**Prevention**:
- Mandatory planning phase before any code
- Document agent communication protocols first
- Design state schema before agent logic
- Create dependency maps for all components
- **Address in**: Phase 0 (Planning/Research)

---

## Implementation Order

**Suggested build sequence** (6 phases):

### Phase 1: Foundation (Weeks 1-2)
1. Directory structure creator (canon/, state/, beats/, draft/)
2. JSON state schemas with validation
3. Git integration (atomic commits)
4. `/novel:init` command
5. `/novel:status` command

**Deliverable**: Project initialization working, state JSON validated

### Phase 2: Planning Pipeline (Weeks 3-4)
6. `novel-plot-planner` agent (outline + act structure)
7. `novel-beat-planner` agent (scene specifications)
8. `/novel:outline` and `/novel:beats` commands

**Deliverable**: Story structure before drafting

**Dependency**: Requires Phase 1 state management

### Phase 3: Drafting Engine (Weeks 5-6)
9. `novel-scene-writer` agent (prose from specs)
10. Scene format templates with headers
11. `/novel:draft` command

**Deliverable**: Generate scenes/entries from beat plans

**Dependency**: Requires Phase 2 planning agents

### Phase 4: Quality Checks (Weeks 7-8)
12. `novel-canon-checker` agent (parallel)
13. `novel-timeline-keeper` agent (parallel)
14. `novel-voice-coach` agent (parallel)
15. `/novel:check` command

**Deliverable**: Automated consistency validation

**Dependency**: Requires Phase 3 scene writer

### Phase 5: Revision Loop (Weeks 9-10)
16. `novel-pacing-analyzer` and `novel-tension-monitor` agents
17. `novel-editor` agent (rewrite based on issues)
18. `novel-quality-gate` agent (approve/reject)
19. Automated revision loop (max 2 retries)

**Deliverable**: Self-improving draft quality

**Dependency**: Requires Phase 4 checkers

### Phase 6: Advanced Features (Weeks 11+)
20. Version control integration (version snapshots)
21. Diary format support (date/weather/mood tracking)
22. Multi-format output (Pandoc EPUB export)
23. Progress visualization

**Deliverable**: Complete novel writing system

**Dependency**: Requires Phase 5 revision loop

---

## Success Criteria

**Phase milestones**:
- **Phase 1**: Can initialize project with canon scaffolding
- **Phase 2**: Can generate outline and beat plan from canon
- **Phase 3**: Can draft scenes following beat specifications
- **Phase 4**: Catches 90%+ canon violations automatically
- **Phase 5**: Produces approved scenes without manual intervention
- **Phase 6**: Exports complete EPUB from draft scenes

**Quality metrics**:
- Canon consistency: 95%+ automatic detection
- Timeline validation: No date contradictions
- Style enforcement: POV/tense errors caught
- Revision success rate: 80%+ scenes approved within 2 retries
- User trust: Writers rely on system, not fear it

---

## Key Architectural Decisions

**Rationale for core choices**:

1. **Canon as Single Source of Truth**: Prevents drift. All agents read from canon, draft must conform.
   - *Alternative rejected*: Draft overrides canon (would compound inconsistencies)

2. **JSON State for Mutable Tracking**: Structured data enables queries, git-trackable, human-readable.
   - *Alternative rejected*: Markdown state (brittle parsing)

3. **Wave-Based Agent Execution**: Maximize parallelism. Checkers run concurrently after scene writer.
   - *Alternative rejected*: Sequential pipeline (too slow)

4. **Quality Gate as Decision Agent**: Single approval point. Editor doesn't self-approve.
   - *Alternative rejected*: Editor self-validation (no external check)

5. **File-Based State (Not SQLite)**: Git-native versioning, human-readable diffs, no database dependencies.
   - *Alternative rejected*: SQLite (binary, bad git diffs, requires runtime)

---

## Next Steps

**Immediate actions**:
1. Review this summary with stakeholders
2. Create ROADMAP.md with phase breakdown
3. Begin Phase 0 (detailed planning and architecture documentation)
4. Design agent communication protocols and state schemas
5. Set up project structure in `claude_src/`

**Dependencies resolved**:
- This summary provides foundation for roadmap creation
- Stack decisions inform technology choices
- Feature priorities guide MVP scope
- Architecture pattern defines component relationships
- Pitfalls inform risk mitigation strategy

---

*Research complete. Ready for roadmap creation.*
