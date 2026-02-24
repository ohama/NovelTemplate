# Phase 3: Drafting Engine - Research

**Researched:** 2026-02-24
**Domain:** Scene prose generation, diary format, state tracking, Markdown output
**Confidence:** HIGH

## Summary

Phase 3 builds the prose generation engine that transforms beat sheets into polished scenes. This research investigated scene-by-scene drafting workflows, diary format conventions, emotional state tracking, and Markdown output formatting.

The primary challenge is generating prose that: (1) follows beat sheet specifications without being mechanical, (2) maintains character voice from style_guide.md, (3) tracks emotional arcs and growth milestones for diary format, and (4) outputs well-structured Markdown with proper metadata. The existing architecture from Phases 1-2 provides strong foundations: schemas define state structures, beat sheets provide scene specifications, and the diary-planner has already calculated temporal structure.

The approach is clear: build a scene-writer agent that reads beat specs and canon, generates prose matching style guide constraints, updates state files with progress and emotional tracking, and outputs Markdown scenes with YAML frontmatter. For diary format, add date headers, seasonal context, and first-person retrospective voice.

**Primary recommendation:** Build the scene-writer agent as the central prose generator, orchestrated by `/novel:write` command. Use the existing state-manager skill for all state updates. Diary features are variations on the same workflow, not separate systems.

## Standard Stack

This is a Claude Code project - there are no external libraries. The "stack" is the existing Novel Engine architecture from Phases 1-2.

### Core

| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| Claude Opus 4.5 | 20251101 | Prose generation LLM | Best creative writing model per benchmarks, "show don't tell" capability |
| State Manager Skill | 1.0 | State file I/O | Already implemented, handles load/save/update patterns |
| Git Integration Skill | 1.0 | Auto-commit scenes | Already implemented, commit_scene_completion() ready |
| YAML Frontmatter | Standard | Scene metadata | Industry standard for Markdown metadata |
| ISO 8601 | Standard | Date formatting | Already used in timeline_state, diary_metadata schemas |

### Supporting

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| Beat Sheet Format | Scene specifications | Read beats/scenes/chXX_sYY.md for scene structure |
| Style Guide | Voice constraints | Reference canon/style_guide.md for POV, tense, forbidden phrases |
| Character State | Emotional tracking | Update character_state.json after each scene |
| Timeline State | Date tracking | Update timeline_state.json for diary entries |
| Story State | Progress tracking | Update scene_index, word counts, current position |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Single scene-writer agent | Multiple specialized agents (dialogue, description, action) | Complexity vs. simplicity - single agent is sufficient for v1 |
| YAML frontmatter | JSON metadata block | YAML is more readable, standard for Markdown files |
| Scene-by-scene output | Chapter-level generation | Scene-level preserves granularity, easier to revise |

## Architecture Patterns

### Recommended Directory Structure

```
draft/
  scenes/           # Individual scene files (ch01_s01.md, ch01_s02.md, ...)
  chapters/         # Compiled chapters (Phase 6)
  versions/         # Version snapshots (Phase 6)

beats/
  scenes/           # Beat specifications (input to scene-writer)
  outline.md        # Chapter structure
  diary_plan.md     # Diary temporal structure (if format=diary)

state/
  story_state.json      # Progress, scene_index, current position
  character_state.json  # Emotional states, arc progression
  timeline_state.json   # Events, dates (especially for diary)
  style_state.json      # Voice tracking, phrase usage
```

### Pattern 1: Scene-Writer Agent Workflow

**What:** Agent that transforms beat sheets into prose scenes

**When to use:** Every scene generation via /novel:write

**Workflow:**
```
1. Load next scene from scene_index (status="planned")
2. Read beat sheet: beats/scenes/chXX_sYY.md
3. Load context:
   - canon/style_guide.md (voice constraints)
   - canon/characters.md (character details)
   - state/character_state.json (current emotional states)
   - Previous scene draft (for continuity)
4. Generate prose following beat structure
5. Format as Markdown with YAML frontmatter
6. Write to draft/scenes/chXX_sYY.md
7. Update state files:
   - scene_index status: "planned" -> "drafted"
   - scene word_count
   - current chapter/scene
   - character emotional_state (if changed)
8. Auto-commit if git enabled
```

### Pattern 2: Diary Entry Format

**What:** First-person retrospective format with date headers

**When to use:** When story_state.project.format == "diary"

**Format:**
```markdown
---
scene_id: ch01_s01
chapter: 1
scene: 1
pov: [Protagonist]
date: 2024-01-10
time: "21:30"
season: winter
weather: "cold, clear, stars visible"
word_count: 2347
status: drafted
---

# January 10, 2024 - Thursday

## Evening, 9:30 PM

[Prose in first-person past tense, retrospective voice]

---

<!-- Emotional state: determined but nervous -->
<!-- Growth milestone: First decision to start -->
```

### Pattern 3: Standard Chapter Scene Format

**What:** Third-person or first-person scene without diary conventions

**When to use:** When story_state.project.format != "diary"

**Format:**
```markdown
---
scene_id: ch01_s01
chapter: 1
scene: 1
pov: [POV Character]
word_count: 2347
status: drafted
---

# Chapter 1, Scene 1

[Prose following style_guide.md constraints]

---

<!-- Beat: [beat summary from beat sheet] -->
```

### Pattern 4: State Update After Scene

**What:** Atomic state updates after each scene completion

**When to use:** After every scene is drafted

**Updates:**
```
story_state.json:
  - scene_index[scene_id].status = "drafted"
  - scene_index[scene_id].word_count = [count]
  - current.chapter = [chapter]
  - current.scene = [scene]
  - current.date = [date] (if diary)
  - progress.draft = "in_progress"
  - progress.total_word_count += [count]

character_state.json:
  - characters[name].emotional_state = [new state]
  - characters[name].last_appearance = [scene_id]
  - characters[name].arc_stage = [stage] (if milestone reached)
  - arc_notes[name].transformation_status = [status]

timeline_state.json (diary format):
  - events.push({date, description, scene_id, type: "plot"})
```

### Anti-Patterns to Avoid

- **Over-generating:** Don't generate entire chapters at once. One scene at a time maintains quality and allows intervention.

- **Ignoring beat sheets:** The beat sheet is the contract. Scene must accomplish stated goals, not drift into tangents.

- **State mutation without validation:** Always use state-manager skill patterns. Don't write raw JSON without validation.

- **Prose in beat sheets:** Beat sheets are planning notes (150-300 words). Scene-writer generates prose (500-2000 words). Don't blur these.

- **Losing continuity:** Always read previous scene before generating next. Context window allows this.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Date formatting | Custom date parser | ISO 8601 standard | Already in schemas, universal format |
| Season calculation | Custom season logic | diary-planner output | Already calculated in beats/diary_plan.md |
| Word counting | Custom tokenizer | Split on whitespace | Simple is sufficient, consistent |
| YAML parsing | String manipulation | Standard YAML delimiters (---) | Claude understands YAML natively |
| State persistence | Custom file I/O | state-manager skill | Already handles validation, recovery |
| Git commits | Raw git commands | git-integration skill | Handles availability, failure cases |

**Key insight:** Phase 3 builds on Phases 1-2 foundations. Reuse state-manager and git-integration skills. Don't rebuild what exists.

## Common Pitfalls

### Pitfall 1: Mechanical Prose from Beat Sheet

**What goes wrong:** Scene reads like a checklist: "Alex entered the library [Opening]. She searched for the map [Goal]. The shelves were unstable [Conflict]..."

**Why it happens:** Beat sheet structure leaks into prose. Writer follows beats too literally.

**How to avoid:** Beat sheet specifies WHAT happens. Scene-writer decides HOW to tell it. Use beat structure as invisible scaffolding, not visible outline.

**Warning signs:** Prose mirrors beat sheet section order exactly. Transitions feel forced. Reader can see the structure.

### Pitfall 2: Voice Drift

**What goes wrong:** Character voice changes between scenes. Dialogue feels inconsistent.

**Why it happens:** Context window doesn't include enough prior scenes. Style guide not referenced.

**How to avoid:** Always load style_guide.md and previous scene. Include voice_notes from character_state.json. Add example lines to prompt context.

**Warning signs:** Protagonist sounds different in chapter 5 vs chapter 1. Dialogue patterns shift without narrative reason.

### Pitfall 3: Diary Date Inconsistency

**What goes wrong:** Entry says "Tuesday, January 10" but January 10, 2024 is actually Wednesday.

**Why it happens:** Day-of-week not validated against date. Manual date generation instead of using diary_plan.md.

**How to avoid:** Read dates from beats/diary_plan.md where diary-planner already calculated them. Don't generate new dates.

**Warning signs:** Day names don't match dates. Seasons don't match months.

### Pitfall 4: State Desync

**What goes wrong:** story_state.json says scene is "drafted" but file doesn't exist. Or file exists but status is "planned".

**Why it happens:** State update and file write aren't atomic. Error between operations leaves inconsistent state.

**How to avoid:** Write file FIRST, then update state. If state update fails, file still exists. Never update state if file write fails.

**Warning signs:** /novel:status shows different info than file system. scene_index count doesn't match beats/scenes/ count.

### Pitfall 5: Showing Everything

**What goes wrong:** Prose shows every minor detail with equal weight. Coffee purchase gets as much description as breakup scene.

**Why it happens:** "Show don't tell" applied uniformly. No judgment about what deserves showing.

**How to avoid:** Beat sheet marks emotional beats and pacing. High-intensity beats get showing. Transitions can tell.

**Warning signs:** All scenes same length regardless of importance. Mundane moments overwritten.

## Code Examples

### Scene File Output Format

```markdown
---
scene_id: ch03_s02
chapter: 3
scene: 2
pov: Alex
date: 2024-02-15
word_count: 1847
status: drafted
---

# Chapter 3, Scene 2

The library door groaned on its hinges, a sound that seemed too loud in the empty corridor. Alex pressed forward, flashlight beam cutting through the dust motes that hung suspended in the stale air.

[... prose continues ...]

She pulled the map free, heart pounding. Someone had been here. Recently.

---

<!-- Beat: Discovery of the map, realization someone else is searching -->
<!-- Emotional shift: curiosity -> alarm -->
```

### Diary Entry Output Format

```markdown
---
scene_id: ch05_s01
chapter: 5
scene: 1
pov: Mina
date: 2024-03-21
time: "06:15"
season: spring
weather: "first warm morning, cherry blossoms starting"
word_count: 1456
status: drafted
emotional_state: hopeful
growth_milestone: "First 5K without stopping"
---

# March 21, 2024 - Thursday

## Early Morning, 6:15 AM

I ran the whole thing. All five kilometers without stopping.

I keep writing it because I still can't believe it. Two months ago, I couldn't run to the end of the block without wheezing. This morning, I watched the sun come up over the river, my legs moving in a rhythm I didn't know my body could find.

[... prose continues in first-person retrospective ...]

Tomorrow I'm signing up for the April 10K. I know it's fast. Maybe too fast. But today proved something I needed to know: my body isn't the enemy I thought it was.

---

<!-- Growth milestone: First completed 5K -->
<!-- Emotional arc: From doubt (entry 1-15) to confidence (entry 16+) -->
<!-- Season transition: Winter to Spring - renewal theme -->
```

### State Update Pattern

```markdown
## After Scene Completion

1. Read current story_state.json

2. Update scene_index:
   Find entry with id == "ch03_s02"
   Set status = "drafted"
   Set word_count = 1847

3. Update progress:
   Set draft = "in_progress"
   Set total_word_count = [previous] + 1847

4. Update current:
   Set chapter = 3
   Set scene = 2
   Set date = "2024-02-15" (if diary)

5. Write story_state.json

6. Read character_state.json

7. Update character:
   Set characters.Alex.emotional_state = "alarmed"
   Set characters.Alex.last_appearance = "ch03_s02"

8. Write character_state.json
```

### /novel:write Command Pattern

```markdown
## Command Execution

1. Validate: beat_plan must be "complete" in story_state.json

2. Find next scene:
   - Read scene_index
   - Find first entry where status == "planned"
   - If none found: Report "All scenes drafted"

3. Spawn scene-writer agent with context:
   - beat_sheet: beats/scenes/[scene_id].md
   - style_guide: canon/style_guide.md
   - characters: canon/characters.md
   - previous_scene: draft/scenes/[previous_id].md (if exists)
   - character_state: state/character_state.json
   - is_diary: project.format == "diary"
   - diary_plan: beats/diary_plan.md (if diary)

4. Agent generates scene, writes file, updates state

5. Git commit if enabled:
   commit_scene_completion(scene_id, title, word_count)

6. Report completion:
   "Drafted scene [scene_id]: [title]
    Word count: [count]
    Status: drafted"

7. Prompt for continuation:
   "Continue to next scene? [y/N]"
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Generate full chapters | Scene-by-scene generation | 2024-2025 | Better quality control, easier revision |
| Separate emotion/prose agents | Single agent with context | 2025 | Simpler architecture, better coherence |
| Manual continuity tracking | State file tracking | Current | Automated consistency |
| Prose-first editing | Beat-first planning | Current | Structure before prose |

**Deprecated/outdated:**
- Generating long chapters in one pass: Quality degrades, revision harder
- Ignoring context window: Modern models (Claude Opus) handle 200K+ tokens, use it
- Manual date tracking: ISO 8601 in state files handles this automatically

## Open Questions

1. **Scene length variation**
   - What we know: Beat sheets suggest word count. Typical range 500-2000 words.
   - What's unclear: How strictly to enforce word count targets?
   - Recommendation: Treat as guidance, not hard limits. Quality over quantity.

2. **Multiple POV handling**
   - What we know: style_state.json tracks POV type, beat sheets assign POV per scene
   - What's unclear: Voice differentiation between POV characters
   - Recommendation: Include voice_notes from character_state.json in scene-writer context

3. **Emotional state granularity**
   - What we know: character_state.json has emotional_state as free text
   - What's unclear: How fine-grained should updates be?
   - Recommendation: Update after significant emotional beats, not every scene

## Sources

### Primary (HIGH confidence)

- Existing Phase 1-2 artifacts (state-manager.md, git-integration.md, schemas, templates) - Authoritative for this project
- Beat sheet format from beat-planner agent - Defines input contract
- draft/README.md - Defines output structure expectations

### Secondary (MEDIUM confidence)

- [Writing a Novel in Markdown with Obsidian](https://pdworkman.com/writing-a-novel-in-markdown/) - YAML frontmatter patterns
- [How to Write a Diary-Style Book](https://guruathome.org/blog/write-diary-style-book/) - Diary format conventions
- [Tracking Character Emotional Arcs](https://www.helpingwritersbecomeauthors.com/characters-emotional-arc/) - Emotional state tracking
- [Show Don't Tell Examples & Techniques](https://rivereditor.com/blogs/show-dont-tell-examples-techniques-2026) - Prose quality patterns

### Tertiary (LOW confidence)

- [Best LLMs for Creative Writing](https://intellectualead.com/best-llm-writing/) - Model capabilities (general guidance)
- [Claude Book Framework](https://hackernoon.com/claude-book-a-multi-agent-framework-for-writing-novels-with-claude-code) - Multi-agent patterns (architectural reference)
- [Scene-by-Scene AI Workflow](https://www.eesel.ai/blog/ai-novel-writing-software) - Workflow patterns (general guidance)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Builds directly on existing Phase 1-2 architecture
- Architecture patterns: HIGH - Clear patterns from existing agents and draft/README.md
- Pitfalls: HIGH - Well-documented issues in writing and AI writing domains
- Diary format: MEDIUM - Combines established conventions with project-specific needs
- Emotional tracking: MEDIUM - Schema exists, update frequency is judgment call

**Research date:** 2026-02-24
**Valid until:** 2026-03-24 (30 days - stable domain, existing architecture)
