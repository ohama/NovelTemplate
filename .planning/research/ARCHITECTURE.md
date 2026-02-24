# Architecture Research

## Executive Summary

A multi-agent novel writing engine should use a **canon-driven state machine** with specialized agents operating on **immutable truth sources** (canon) and **mutable JSON state**. The architecture separates concerns into discrete layers (truth, state, structure, output) with agents acting as specialized workers coordinated by command workflows.

**Key insight from GSD framework**: Skills system enables reusable methodology patterns that agents invoke, while commands orchestrate agent workflows with dependency graphs and wave-based parallel execution.

---

## Core Components

### 1. Canon Layer (Immutable Truth)

**Purpose**: Single source of truth for story elements that don't change mid-draft

**Structure**:
```
canon/
  ├── premise.md        # Core concept, theme, logline
  ├── world.md          # Setting, rules, geography, culture
  ├── characters.md     # Character profiles, relationships, secrets
  ├── style_guide.md    # Voice, tone, POV, tense, forbidden phrases
  ├── timeline.md       # Chronology constraints, event ordering
  └── constraints.md    # Story boundaries, out-of-scope elements
```

**Key principle**: Canon is law. If draft conflicts with canon, draft must change.

**Access pattern**: Read-only for most agents. Canon updates require explicit user approval and create new canon versions.

---

### 2. State Layer (Mutable JSON)

**Purpose**: Track dynamic progress, relationships, and evolving story elements

**Structure**:
```
state/
  ├── story_state.json      # Progress, chapter/scene status, open threads
  ├── character_state.json  # Character arcs, voice notes, current states
  ├── timeline_state.json   # Dated events, seasonal progression
  └── style_state.json      # POV, tense, diction tracking
```

**For diary format enhancement**:
```json
// story_state.json additions
{
  "format": "diary",
  "diary_metadata": {
    "current_date": "2024-03-15",
    "season": "spring",
    "entries_per_week": 2,
    "total_duration_weeks": 52,
    "emotional_arc": {
      "phase": "rising_action",
      "current_sentiment": "hopeful_determination"
    },
    "growth_milestones": [
      {"date": "2024-01-10", "milestone": "first_5k_run", "status": "completed"},
      {"date": "2024-06-15", "milestone": "first_half_marathon", "status": "pending"}
    ]
  }
}
```

**Update protocol**: Agents update state after each successful operation. State serves as authoritative checkpoint for resuming work.

---

### 3. Structure Layer (Plot Architecture)

**Purpose**: Define narrative structure before drafting

**Structure**:
```
beats/
  ├── outline.md         # High-level story arc
  ├── act_structure.md   # 3-act or 5-act breakdown
  └── beat_plan.md       # Scene-by-scene specifications
```

**For diary format**:
```
beats/
  ├── outline.md              # Overall growth arc
  ├── seasonal_structure.md   # Season-by-season progression
  └── entry_plan.md          # Per-entry specifications (date, weather, event, emotion)
```

**Beat planning pattern**: Each scene/entry gets a spec (POV, time, location, goal, obstacle, turning point, outcome, subtext).

---

### 4. Draft Layer (Output Manuscripts)

**Purpose**: Generated content, versioned for revision history

**Structure**:
```
draft/
  ├── scenes/           # Individual scene files
  │   ├── ch01_s01.md
  │   └── ch01_s02.md
  ├── chapters/         # Compiled chapters
  │   └── ch01.md
  └── versions/         # Revision history
      ├── v1_draft/
      └── v2_rewrite/
```

**For diary format**:
```
draft/
  ├── entries/          # Individual diary entries
  │   ├── 2024-01-10.md
  │   └── 2024-01-17.md
  ├── seasons/          # Seasonal compilations
  │   └── spring.md
  └── versions/
      ├── v1_draft/
      └── v2_revised/
```

**Entry format requirements**:
```markdown
---
date: 2024-01-10
season: winter
weather: cold, clear
mood: nervous_excitement
milestone: first_day_walking
---

# 2024년 1월 10일 화요일

[Diary entry content...]

<!-- END ENTRY -->
```

---

### 5. Agent Layer (Specialized Workers)

**Purpose**: Discrete AI roles with specific responsibilities

**GSD-inspired agent pattern**:
- Each agent defined in `.claude/agents/novel-*.md`
- YAML frontmatter declares tools, color, spawned_by, skills_integration
- Agents spawn via Task tool for parallel execution
- Agents produce artifacts and update state

**Novel engine agent roster (10 agents)**:

| Agent | Role | Input | Output |
|-------|------|-------|--------|
| `novel-plot-planner` | Create story outline | canon/*, constraints | beats/outline.md, act_structure.md |
| `novel-beat-planner` | Scene specifications | outline, canon | beats/beat_plan.md, scene specs |
| `novel-scene-writer` | Draft scenes | scene spec, canon, state | draft/scenes/*.md |
| `novel-canon-checker` | Detect contradictions | draft scene, canon | issues list, severity ratings |
| `novel-timeline-keeper` | Chronology validation | draft scene, timeline state | timeline issues, date conflicts |
| `novel-voice-coach` | Character voice consistency | draft scene, character state | voice issues, suggestions |
| `novel-pacing-analyzer` | Rhythm and flow | draft scene | pacing notes, tempo adjustments |
| `novel-tension-monitor` | Conflict and stakes | draft scene | tension curve, engagement check |
| `novel-editor` | Rewrite scenes | draft scene, all issues | revised scene draft |
| `novel-quality-gate` | Approve/reject | scene + all checks | APPROVED/REVISE decision |

**For diary format, add**:
| Agent | Role | Input | Output |
|-------|------|-------|--------|
| `novel-diary-planner` | Entry specifications | seasonal structure, timeline state | entry specs (date, weather, milestone) |
| `novel-season-tracker` | Seasonal progression | current date, diary metadata | season updates, weather patterns |
| `novel-growth-monitor` | Character development | entries, milestones | growth arc validation, pacing |

**Agent execution model**: Wave-based parallelism
- Wave 1: Independent agents (plot-planner, canon-checker)
- Wave 2: Agents dependent on Wave 1 (beat-planner needs outline)
- Wave 3: Agents dependent on Wave 2 (scene-writer needs beats)

---

### 6. Command Layer (Workflow Orchestration)

**Purpose**: User-facing commands that orchestrate multi-agent workflows

**Structure**:
```
.claude/commands/novel/
  ├── init.md          # Initialize project structure
  ├── outline.md       # Create story outline
  ├── beats.md         # Generate beat plan
  ├── draft.md         # Draft next scene/entry
  ├── check.md         # Run all quality checks
  ├── rewrite.md       # Revise based on feedback
  ├── publish.md       # Compile final manuscript
  └── status.md        # Show progress
```

**Command pattern** (following GSD):
1. Load project state (canon + state JSON)
2. Spawn appropriate agents with Task tool
3. Agents produce artifacts and update state
4. Command commits changes to git (optional, configurable)
5. Return structured status to user

**Example workflow**:
```
/novel:init
  → Create canon/, state/, beats/, draft/
  → Initialize JSON state files
  → Commit structure

/novel:outline
  → Spawn novel-plot-planner agent
  → Agent reads canon, produces beats/outline.md
  → Update story_state.json: progress.outline = "done"
  → Commit outline

/novel:draft
  → Spawn novel-beat-planner for next scene spec
  → Spawn novel-scene-writer with spec
  → Spawn novel-canon-checker, novel-timeline-keeper (parallel Wave 2)
  → Spawn novel-voice-coach, novel-pacing-analyzer, novel-tension-monitor (parallel Wave 2)
  → Spawn novel-quality-gate
  → If APPROVED: commit scene, update state, return success
  → If REVISE: spawn novel-editor, re-run quality gate
```

---

### 7. Skill Layer (Reusable Methodology)

**Purpose**: Codify repeatable patterns agents invoke

**GSD pattern**: Skills are methodology, not tools. Agents reference skills in frontmatter.

**Novel engine skills**:

```
.claude/skills/novel/
  ├── canon-consistency.md       # How to check canon violations
  ├── scene-structure.md         # Scene beat template (goal/conflict/outcome)
  ├── show-dont-tell.md          # Detection patterns for exposition dumps
  ├── character-voice.md         # Voice consistency methodology
  ├── diary-progression.md       # Date/season/emotion tracking for diary format
  └── version-control.md         # Draft versioning protocol
```

**Skill invocation**: Agent frontmatter declares `skills_integration`, agent markdown references skill for detailed methodology.

---

## Data Flow

### Initialization Flow

```
User: /novel:init
  ↓
Command reads project description
  ↓
Create directory structure (canon/, state/, beats/, draft/)
  ↓
Initialize empty canon files with templates
  ↓
Create initial JSON state (story_state, character_state, timeline_state, style_state)
  ↓
Commit to git (optional)
  ↓
Return: "Project initialized. Next: /novel:outline"
```

---

### Outline Creation Flow

```
User: /novel:outline
  ↓
Command loads canon/* and state/story_state.json
  ↓
Spawn novel-plot-planner agent
  ↓
Agent reads:
  - canon/premise.md (theme, concept)
  - canon/constraints.md (boundaries)
  - canon/world.md (setting)
  - canon/characters.md (cast)
  ↓
Agent produces 3 outline options
  ↓
Agent selects best-fit option
  ↓
Agent writes:
  - beats/outline.md
  - beats/act_structure.md
  ↓
Agent updates state/story_state.json:
  progress.outline = "done"
  ↓
Command commits outline
  ↓
Return: "Outline complete. Next: /novel:beats"
```

---

### Scene Drafting Flow (Multi-Agent Pipeline)

```
User: /novel:draft
  ↓
Command loads state to find current scene pointer
  ↓
Wave 1: Spawn novel-beat-planner
  ↓
Agent reads beats/outline.md and canon
  ↓
Agent produces Scene Spec:
  - POV, time, location
  - Goal, obstacle, turning point, outcome
  - Subtext, needed facts
  ↓
Wave 2: Spawn novel-scene-writer
  ↓
Writer reads Scene Spec + canon/style_guide.md
  ↓
Writer drafts scene following "show > tell" principle
  ↓
Writer writes draft/scenes/chXX_sYY.md
  ↓
Wave 3: Spawn checkers (parallel)
  - novel-canon-checker
  - novel-timeline-keeper
  - novel-voice-coach
  - novel-pacing-analyzer
  - novel-tension-monitor
  ↓
Each checker produces issues list
  ↓
Wave 4: Spawn novel-quality-gate
  ↓
Quality gate evaluates:
  - Canon: no blocker issues?
  - Timeline: consistent?
  - Style: POV/tense correct?
  - Voice: distinct?
  - Prose: minimal clichés?
  - Scene: has turn and outcome?
  ↓
If APPROVED:
  - Update story_state.json scene status
  - Commit scene
  - Return success
  ↓
If REVISE:
  - Spawn novel-editor with all issues
  - Editor rewrites scene
  - Re-run quality gate (loop max 2 times)
```

---

### Diary Entry Flow (Format-Specific)

```
User: /novel:draft (diary format)
  ↓
Command detects format: "diary" from story_state.json
  ↓
Wave 1: Spawn novel-diary-planner
  ↓
Planner reads:
  - state/story_state.json (current_date, season, emotional_arc)
  - state/timeline_state.json (upcoming milestones)
  - beats/seasonal_structure.md
  ↓
Planner produces Entry Spec:
  - date: 2024-01-17
  - season: winter
  - weather: light snow
  - milestone: completed first week walking
  - emotional_note: cautious optimism, physical fatigue
  - story_beat: reflection on why this matters
  ↓
Wave 2: Spawn novel-scene-writer (now diary-aware)
  ↓
Writer drafts entry in first-person diary voice
  ↓
Writer writes draft/entries/2024-01-17.md
  ↓
Wave 3: Checkers (parallel)
  - novel-canon-checker (character consistency)
  - novel-timeline-keeper (date/season progression)
  - novel-voice-coach (diary voice authenticity)
  - novel-season-tracker (weather/seasonal coherence)
  - novel-growth-monitor (milestone pacing)
  ↓
Wave 4: Quality gate approval
  ↓
Update state:
  - current_date → 2024-01-20
  - entries_completed + 1
  - emotional_arc.current_sentiment
  ↓
Commit entry
```

---

## Agent Roles (Detailed)

### Planning Agents

**novel-plot-planner**
- **When**: User runs `/novel:outline`
- **Reads**: canon/premise.md, canon/constraints.md, canon/world.md, canon/characters.md
- **Produces**: beats/outline.md, beats/act_structure.md
- **Method**: Propose 3 options, select best-fit, ensure theme embedded in choices not speeches
- **Updates**: story_state.json progress.outline = "done"

**novel-beat-planner**
- **When**: User runs `/novel:beats` or `/novel:draft` (per-scene)
- **Reads**: beats/outline.md, beats/act_structure.md, canon/*
- **Produces**: beats/beat_plan.md (table), Scene Spec for next scene
- **Scene Spec includes**: POV, time, location, goal, obstacle, turning point, outcome, subtext, needed facts
- **Updates**: story_state.json current scene pointer

**novel-diary-planner** (format-specific)
- **When**: User runs `/novel:draft` in diary format
- **Reads**: beats/seasonal_structure.md, state/story_state.json (diary_metadata)
- **Produces**: Entry Spec (date, weather, milestone, emotion, story beat)
- **Method**: Calculate next entry date (2x per week), select season-appropriate weather, align milestone with emotional arc
- **Updates**: story_state.json current_date

---

### Drafting Agents

**novel-scene-writer**
- **When**: Spawned by `/novel:draft` after beat planner completes
- **Reads**: Scene Spec (or Entry Spec), canon/style_guide.md, state/*
- **Produces**: draft/scenes/chXX_sYY.md or draft/entries/YYYY-MM-DD.md
- **Rules**:
  - Follow canon/style_guide.md strictly
  - No retroactive changes (write new scene only)
  - Show > tell (avoid exposition dumps)
  - End with `<!-- END SCENE -->` or `<!-- END ENTRY -->`
- **Output format**: Markdown with scene header (chapter, scene, POV, time, location, goal/conflict/outcome)

---

### Quality Agents (Checkers)

**novel-canon-checker**
- **When**: After scene draft completes
- **Reads**: Draft scene, canon/*
- **Produces**: Issues list (type: world/character/constraint/style, severity: blocker/warn, location: quote, fix suggestion)
- **Updates**: state with issues summary for scene
- **Method**: Compare draft against canon for contradictions, flag severity

**novel-timeline-keeper**
- **When**: After scene draft completes
- **Reads**: Draft scene, state/timeline_state.json, canon/timeline.md
- **Produces**: Timeline issues (date conflicts, event ordering, seasonal inconsistencies)
- **Method**: Extract temporal references, validate against timeline state, check chronology
- **For diary format**: Validate date progression (2x per week), season transitions, weather patterns

**novel-voice-coach**
- **When**: After scene draft completes
- **Reads**: Draft scene, state/character_state.json, canon/characters.md
- **Produces**: Voice issues (POV character voice drift, dialogue inconsistencies)
- **Method**: Compare character speech/thought patterns against established voice notes

**novel-pacing-analyzer**
- **When**: After scene draft completes
- **Reads**: Draft scene
- **Produces**: Pacing notes (scene tempo, paragraph rhythm, sentence variety)
- **Method**: Analyze sentence length distribution, paragraph breaks, scene duration vs action

**novel-tension-monitor**
- **When**: After scene draft completes
- **Reads**: Draft scene
- **Produces**: Tension curve (conflict presence, stakes clarity, engagement check)
- **Method**: Identify goal/obstacle/outcome, assess stakes, flag sagging tension

**novel-season-tracker** (format-specific)
- **When**: After diary entry draft
- **Reads**: Draft entry, state/story_state.json (diary_metadata)
- **Produces**: Seasonal coherence issues (weather mismatch, flora/fauna inconsistencies)
- **Method**: Validate weather against season, check environmental details

**novel-growth-monitor** (format-specific)
- **When**: After diary entry draft
- **Reads**: Draft entry, state/story_state.json (growth_milestones)
- **Produces**: Growth arc validation (milestone pacing, emotional progression)
- **Method**: Check physical progression (5k → 10k → half marathon), emotional arc (doubt → determination → triumph)

---

### Revision Agents

**novel-editor**
- **When**: Spawned by quality gate if REVISE decision
- **Reads**: Draft scene, all checker issues
- **Produces**: Revised scene draft
- **Method**: Address blocker issues first, then warnings, preserve good parts, rewrite problem sections
- **Output**: Overwrites draft/scenes/chXX_sYY.md

**novel-quality-gate**
- **When**: After all checkers complete (or after editor rewrite)
- **Reads**: Draft scene, all checker outputs
- **Produces**: Decision (APPROVED or REVISE with top 3 reasons)
- **Checklist**:
  - Canon: no blocker issues
  - Timeline: consistent
  - Style: POV/tense consistent, forbidden phrases avoided
  - Voice: distinct
  - Prose: minimal clichés, no filler
  - Scene: has a turn and outcome
- **Updates**: story_state.json scene_index status (approved/revising)
- **Max retries**: 2 rewrite loops, then escalate to user

---

## Build Order (Suggested Implementation Sequence)

### Phase 1: Foundation (Core Infrastructure)

**Goal**: Basic project structure and state management

**Build order**:
1. **Directory structure creator**
   - Create canon/, state/, beats/, draft/ on init
   - Template canon files (premise, world, characters, style_guide, timeline, constraints)

2. **JSON state management**
   - Define schemas for story_state.json, character_state.json, timeline_state.json, style_state.json
   - Create read/write utilities for state updates
   - Add diary_metadata schema for diary format

3. **Git integration (optional)**
   - Commit protocol for artifacts
   - Configurable via `.planning/config.json` (commit_docs: true/false)

**Deliverables**: `/novel:init` command working, state JSON initialized

---

### Phase 2: Planning Pipeline (Outline → Beats)

**Goal**: Story structure before drafting

**Build order**:
1. **novel-plot-planner agent**
   - Read canon files
   - Generate outline.md and act_structure.md
   - Update story_state.json

2. **novel-beat-planner agent** (chapter/scene structure)
   - Read outline + canon
   - Generate beat_plan.md (table format)
   - Produce Scene Spec for next scene

3. **novel-diary-planner agent** (diary structure)
   - Read seasonal_structure.md
   - Calculate entry dates (2x per week)
   - Produce Entry Spec (date, weather, milestone, emotion)

**Deliverables**: `/novel:outline` and `/novel:beats` commands working

**Dependency**: Requires Phase 1 state management

---

### Phase 3: Drafting Engine (Scene Writer)

**Goal**: Generate prose from specs

**Build order**:
1. **novel-scene-writer agent**
   - Read Scene Spec or Entry Spec
   - Apply style_guide.md rules
   - Write draft/scenes/*.md or draft/entries/*.md
   - Format validation (scene header, END marker)

2. **Scene format templates**
   - Chapter/scene header structure
   - Diary entry header structure (date, season, weather, mood)

**Deliverables**: `/novel:draft` command produces scenes/entries

**Dependency**: Requires Phase 2 planning agents

---

### Phase 4: Quality Pipeline (Checkers)

**Goal**: Automated consistency validation

**Build order** (parallel agents, no dependencies between):
1. **novel-canon-checker agent**
   - Compare draft against canon
   - Flag contradictions with severity

2. **novel-timeline-keeper agent**
   - Validate chronology
   - Check date progression (especially for diary)

3. **novel-voice-coach agent**
   - Check character voice consistency
   - Validate POV adherence

**Deliverables**: `/novel:check` command runs all checkers

**Dependency**: Requires Phase 3 scene writer

---

### Phase 5: Pacing & Tension (Advanced Checkers)

**Goal**: Prose quality beyond consistency

**Build order** (parallel, no dependencies):
1. **novel-pacing-analyzer agent**
   - Sentence/paragraph rhythm analysis
   - Scene tempo evaluation

2. **novel-tension-monitor agent**
   - Goal/obstacle/outcome extraction
   - Stakes clarity check

3. **novel-season-tracker agent** (diary-specific)
   - Weather/season validation

4. **novel-growth-monitor agent** (diary-specific)
   - Milestone pacing check
   - Emotional arc progression

**Deliverables**: Enhanced quality feedback

**Dependency**: Requires Phase 4 basic checkers

---

### Phase 6: Revision Loop (Editor + Gate)

**Goal**: Automated rewrite based on feedback

**Build order**:
1. **novel-editor agent**
   - Read all checker issues
   - Rewrite scene addressing issues
   - Preserve working parts

2. **novel-quality-gate agent**
   - Evaluate all checker outputs
   - Decision: APPROVED or REVISE
   - Max 2 retries, then escalate

**Deliverables**: `/novel:draft` automatically revises until approved

**Dependency**: Requires Phase 4 & 5 checkers

---

### Phase 7: Publication (Compilation)

**Goal**: Export finished manuscript

**Build order**:
1. **Markdown compiler**
   - Assemble scenes → chapters
   - Assemble entries → seasons → complete manuscript
   - Generate table of contents

2. **EPUB exporter**
   - Convert Markdown → EPUB format
   - Metadata (title, author, description)
   - Cover image support (optional)

**Deliverables**: `/novel:publish` generates manuscript.md and manuscript.epub

**Dependency**: Requires Phase 3 (drafts exist)

---

### Phase 8: Version Control (Revision History)

**Goal**: Track draft vs rewrite versions

**Build order**:
1. **Version tagging**
   - draft/versions/v1_draft/ snapshot
   - draft/versions/v2_rewrite/ snapshot

2. **Diff viewer** (optional)
   - Show changes between versions
   - Highlight rewrite deltas

**Deliverables**: Version snapshots preserved

**Dependency**: Requires Phase 6 revision loop

---

### Phase 9: Status & Progress (User Interface)

**Goal**: Visibility into project state

**Build order**:
1. **novel:status command**
   - Read story_state.json
   - Display progress (outline done, beats done, X/Y scenes drafted)
   - Show current scene/entry pointer
   - For diary: show date progression, season, upcoming milestones

2. **Progress visualization**
   - Scenes: ░░░███░░░ (3/9 drafted)
   - For diary: Timeline with entry markers

**Deliverables**: `/novel:status` shows current state

**Dependency**: Requires Phase 1 state management

---

### Phase 10: Canon Evolution (Advanced)

**Goal**: Update canon mid-project

**Build order**:
1. **Canon diff detector**
   - Detect when draft needs canon update
   - Propose canon patches

2. **Canon versioning**
   - canon/versions/v1/, canon/versions/v2/
   - Track which scenes use which canon version

**Deliverables**: Canon updates don't break consistency

**Dependency**: Requires Phase 6 (revision loop mature)

---

## Component Boundaries

### Clear Separation of Concerns

**Canon (Immutable) vs State (Mutable)**:
- Canon changes require explicit user approval
- State updates happen automatically after each agent operation
- Canon defines "what should be true", State tracks "what is currently true"

**Planning vs Drafting**:
- Planning agents (plot-planner, beat-planner, diary-planner) produce specs, not prose
- Drafting agents (scene-writer) consume specs and produce prose
- No agent does both planning and drafting

**Checking vs Editing**:
- Checkers (canon-checker, timeline-keeper, voice-coach, etc.) flag issues, never fix
- Editor agent (novel-editor) fixes issues based on checker output
- Quality gate evaluates checker output, decides approve/revise

**Commands vs Agents**:
- Commands orchestrate workflows (spawn agents, commit artifacts, update state)
- Agents perform specialized work (read inputs, produce outputs)
- Commands handle user interaction, agents are silent workers

---

## Integration Points

### GSD Framework Integration

**State management pattern**:
- GSD uses `.planning/STATE.md` for project state
- Novel engine uses `state/*.json` for story state
- **Integration**: Commands update both STATE.md (project position) and state/*.json (story details)

**Skill system**:
- GSD defines skills in `.claude/skills/gsd/`
- Novel engine defines skills in `.claude/skills/novel/`
- Agents reference skills via `skills_integration` in frontmatter

**Command pattern**:
- GSD commands in `.claude/commands/gsd/`
- Novel engine commands in `.claude/commands/novel/`
- Both use Task tool to spawn agents

**Git workflow**:
- GSD commits planning docs (configurable via commit_docs)
- Novel engine commits canon/state/beats/draft (configurable)
- Atomic commits per artifact (per scene, per outline, etc.)

---

## Key Architectural Decisions

### 1. Canon as Single Source of Truth

**Rationale**: Prevents drift. All agents read from canon, draft must conform.

**Alternative considered**: Let draft override canon. Rejected because draft inconsistencies would compound.

---

### 2. JSON State for Mutable Tracking

**Rationale**: Structured data enables programmatic queries (find next scene, check progress). Git-trackable. Human-readable.

**Alternative considered**: Markdown state files. Rejected because parsing freeform text is brittle.

---

### 3. Wave-Based Agent Execution

**Rationale**: Maximize parallelism. Checkers can run concurrently after scene writer completes.

**Alternative considered**: Sequential pipeline. Rejected because slow (checkers wait for each other).

---

### 4. Quality Gate as Decision Agent

**Rationale**: Single approval point. Editor doesn't decide if scene is good enough, quality gate does.

**Alternative considered**: Editor self-approves. Rejected because no external validation.

---

### 5. Diary Format as State Extension, Not Separate System

**Rationale**: Reuse agents (scene-writer becomes entry-writer). Add diary-specific checkers (season-tracker, growth-monitor) without duplicating core pipeline.

**Alternative considered**: Separate diary engine. Rejected because duplication of canon/state/quality logic.

---

## Testing Strategy

**Unit testing agents**:
- Mock canon files (premise.md, world.md, etc.)
- Mock state JSON
- Run agent, verify output artifact structure
- Example: novel-plot-planner produces outline.md with 3-act structure

**Integration testing workflows**:
- Run full `/novel:draft` command
- Verify multi-agent pipeline (beat-planner → scene-writer → checkers → quality gate)
- Check state updates (story_state.json scene pointer increments)

**End-to-end scenario**:
- `/novel:init` → `/novel:outline` → `/novel:beats` → `/novel:draft` (loop 10 scenes) → `/novel:publish`
- Verify final manuscript.md contains 10 scenes
- Verify EPUB export works

---

## Performance Considerations

**Parallel agent execution**:
- Checkers run concurrently (5 agents in Wave 3)
- Use Task tool for spawning
- Each agent has independent context window

**Context budget**:
- Each agent targets ~50% context usage (GSD pattern)
- Scene-writer reads spec + style_guide (minimal context)
- Checkers read scene + relevant canon section (focused)

**State size**:
- JSON files grow with project (character_state.json adds entries per character)
- Periodically archive old state versions (>100 scenes)

---

## Security & Safety

**No real-person defamation**:
- Canon checker validates against constraints.md (user-defined boundaries)
- Reject canon that references real people without permission

**No illegal content**:
- Style guide checker flags forbidden topics (user-configurable)
- Quality gate blocks scenes with violations

**Canon integrity**:
- Canon changes require user approval (not automated)
- Version canon to prevent accidental overwrites

---

## Future Extensions

**Multi-POV support**:
- Track POV per scene in story_state.json
- Voice coach validates each POV character separately

**Collaborative editing**:
- Currently single-user
- Could add conflict resolution for concurrent scene editing

**AI-assisted replotting**:
- Suggest plot pivots based on current draft
- "What if character X died in scene Y?" scenario exploration

**Localization**:
- Currently assumes single language
- Could support bilingual canon (Korean premise, English draft)

---

## Conclusion

The multi-agent novel writing engine architecture separates immutable truth (canon) from mutable progress (state), uses specialized agents for discrete tasks (planning, drafting, checking, editing), and orchestrates workflows via commands with wave-based parallelism. The diary format enhancement demonstrates extensibility: add format-specific state, planners, and checkers without duplicating core pipeline.

**Build order priorities**:
1. Foundation (Phase 1)
2. Planning (Phase 2)
3. Drafting (Phase 3)
4. Quality checks (Phase 4-5)
5. Revision loop (Phase 6)
6. Publication (Phase 7)

This architecture supports greenfield novel projects and integrates cleanly with the GSD framework's state management, skill system, and command patterns.
