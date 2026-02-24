# Phase 2: Planning Pipeline - Research

**Researched:** 2026-02-24
**Domain:** AI-driven story structure generation, plot planning, and beat sheet creation
**Confidence:** MEDIUM-HIGH

## Summary

Phase 2 implements a planning pipeline that transforms user-provided canon (premise, characters, world) into structured story plans (outline, beats, scenes). The research focused on proven story structure methodologies, LLM-based outline generation, agent orchestration patterns, and consistency tracking.

The standard approach combines traditional storytelling frameworks (Save the Cat, 3-act structure) with modern LLM prompting techniques (iterative generation, JSON-structured output, prompt chaining). The pipeline uses three specialized agents: plot-planner generates high-level structure, beat-planner breaks it into scenes, and diary-planner handles date-based narratives.

Key findings reveal that AI story generation excels with structured prompts and iterative refinement but struggles with consistency across long narratives. Best practice is to generate outlines hierarchically (act → chapter → scene → beat) rather than all-at-once, using markdown for human readability and JSON state for machine tracking.

**Primary recommendation:** Use prompt chaining with progressive disclosure - plot-planner outputs outline.md, beat-planner reads it and generates scene beats, diary-planner adds temporal structure. Track all story elements in JSON state for consistency validation.

## Standard Stack

This phase uses no external libraries - it's pure Claude Code skill orchestration with markdown generation and JSON state management.

### Core

| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| Claude Code Agent Skills | 2026 | Agent orchestration and skill patterns | Native Claude Code feature, supports progressive disclosure and context injection |
| Markdown | CommonMark | Outline and beat sheet output format | LLM-friendly, human-readable, universally supported for story planning |
| JSON Schema | Draft 2020-12 | State validation and structure | Industry standard for schema validation, already used in Phase 1 |
| Bash | POSIX-compliant | File operations and git integration | Already integrated in Phase 1 git-integration skill |

### Supporting

| Component | Version | Purpose | When to Use |
|-----------|---------|---------|-------------|
| Save the Cat Beat Sheet | Blake Snyder (2005) | 15-beat story structure template | For structured genre fiction; adaptable to novels from screenwriting |
| Three-Act Structure | Traditional | Classic story arc (setup/confrontation/resolution) | Default for most novels; 25%/50%/25% word count distribution |
| Five-Act Structure | Freytag (1863) | More detailed arc with rising/falling action | For complex character-driven narratives with multiple turning points |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Markdown output | JSON-only | Markdown prioritized for human editability; JSON state used for machine consistency |
| Save the Cat | Hero's Journey | Save the Cat more prescriptive with page counts; Hero's Journey better for mythic narratives |
| Agent orchestration | Single monolithic agent | Multi-agent allows specialization (plot vs beats vs diary) and parallel iteration |

**Installation:**

No installation needed. All components are built-in to Claude Code or generated as markdown/JSON files.

## Architecture Patterns

### Recommended Project Structure

```
.claude/
├── agents/
│   ├── plot-planner.md        # AGENT-01: High-level outline generation
│   ├── beat-planner.md         # AGENT-02: Scene-level beat planning
│   └── diary-planner.md        # AGENT-03: Diary format specialization
├── commands/
│   └── outline.md              # CMD-05: /novel:outline orchestrator
└── skills/
    └── git-integration.md      # Already exists from Phase 1

canon/                          # Input: User-written story canon
├── premise.md
├── characters.md
└── timeline.md

state/                          # Tracking: JSON state (Phase 1)
├── story_state.json            # Updated with outline progress
└── character_state.json        # Updated with scene appearances

beats/                          # Output: Generated story structure
├── outline.md                  # High-level chapter/arc structure
├── scenes/
│   ├── ch01_s01.md            # Scene-level beat sheets
│   └── ch01_s02.md
└── diary_plan.md              # (Optional) Diary-specific planning
```

### Pattern 1: Hierarchical Planning Pipeline

**What:** Sequential agent invocation where each agent reads previous outputs and adds detail.

**When to use:** For all story outline generation. Prevents overwhelming single prompts with too much complexity.

**Flow:**

```markdown
1. plot-planner reads canon/ → generates beats/outline.md
   - 3-act or 5-act structure
   - Chapter breakdown with summaries
   - Major plot points and turning moments

2. beat-planner reads outline.md + canon/ → generates beats/scenes/*.md
   - Scene-by-scene breakdown
   - Character appearances per scene
   - Emotional beats and pacing

3. diary-planner (if --diary flag) reads outline.md + constraints.md → generates beats/diary_plan.md
   - Date range mapping
   - Seasonal arc progression
   - Growth milestone scheduling
```

**Example (from /novel:outline command):**

```markdown
## Step 1: Invoke plot-planner

Use TeammateTool to spawn plot-planner agent:

Input: canon/premise.md, canon/characters.md, canon/world.md
Output: beats/outline.md

## Step 2: Invoke beat-planner

After plot-planner completes:

Input: beats/outline.md, canon/characters.md
Output: beats/scenes/ch01_s01.md, ch01_s02.md, etc.

## Step 3: Invoke diary-planner (conditional)

If format == "diary":

Input: beats/outline.md, canon/timeline.md, canon/constraints.md
Output: beats/diary_plan.md
```

### Pattern 2: Progressive Disclosure for Agent Skills

**What:** Structure SKILL.md (agent definition) with brief instructions plus linked detail files.

**When to use:** For all three agents. Keeps agent definitions under 500 lines while providing deep reference material.

**Structure:**

```markdown
---
name: plot-planner
description: Generates story outline from premise and characters
---

# Plot Planner Agent

## Role
You generate high-level story structure using proven frameworks.

## Input Files
- canon/premise.md (required)
- canon/characters.md (required)
- canon/world.md (optional)

## Output
beats/outline.md with:
- Act structure (3-act or 5-act based on complexity)
- Chapter breakdown
- Major plot points

## Process
1. Read premise for story concept and theme
2. Identify character arcs from characters.md
3. Apply Save the Cat beat sheet or 3-act structure
4. Generate outline.md with progressive detail

[See beat-sheet-reference.md for full Save the Cat template]
[See examples/outline-example.md for output format]
```

**Reference files (not loaded until accessed):**

- `/references/beat-sheet-reference.md` - Full Save the Cat 15-beat template
- `/examples/outline-example.md` - Sample outline.md output
- `/examples/diary-outline-example.md` - Sample diary format outline

### Pattern 3: JSON State Updates for Consistency

**What:** Agents update story_state.json and character_state.json after generating markdown plans.

**When to use:** After every outline/beat generation to track scene index and character appearances.

**Example:**

```markdown
After beat-planner generates beats/scenes/ch01_s01.md:

1. Read state/story_state.json
2. Add to scene_index:
   {
     "id": "ch01_s01",
     "chapter": 1,
     "scene": 1,
     "status": "planned",
     "pov": "Protagonist",
     "word_count": 0
   }
3. Update progress.beat_plan = "in_progress"
4. Save state/story_state.json

After all scenes planned:
5. Update progress.beat_plan = "complete"
```

### Pattern 4: Prompt Chaining for Multi-Step Reasoning

**What:** Break outline generation into sequential prompts where each step informs the next.

**When to use:** Within agents for complex reasoning (e.g., plot-planner determining act structure).

**Example (inside plot-planner agent):**

```markdown
## Prompt Chain for Outline Generation

### Step 1: Analyze Premise
Prompt: "Read premise.md. What is the core conflict, theme, and story question?"
Output: Theme analysis object

### Step 2: Determine Structure
Prompt: "Given theme '[theme]' and target length [X] words, should this use 3-act or 5-act structure? Why?"
Output: Structure decision with justification

### Step 3: Map Character Arcs to Acts
Prompt: "Map each character's arc from characters.md onto the [structure] framework."
Output: Character arc placement

### Step 4: Generate Beat Sheet
Prompt: "Create Save the Cat beat sheet with acts, chapters, and plot points based on the above."
Output: beats/outline.md (markdown file)
```

### Anti-Patterns to Avoid

- **Monolithic Single Prompt:** Don't try to generate entire outline in one massive prompt. LLMs lose coherence beyond ~20k characters. Use hierarchical generation instead.

- **Ignoring Existing State:** Don't regenerate outline without checking story_state.json progress. Agents should check if outline already exists and prompt user before overwriting.

- **Hand-Rolling Story Frameworks:** Don't invent custom story structures. Use proven frameworks (Save the Cat, 3-act, Hero's Journey) that writers recognize.

- **Markdown Without JSON State:** Don't only output markdown. Always update JSON state for consistency tracking and programmatic access.

- **Forgetting Git Commits:** Don't skip git auto-commit after outline generation. Use git-integration skill's commit_outline() function.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Story structure templates | Custom beat sheet format | Save the Cat 15-beat structure | Proven across thousands of films/novels, writers already know it, 25+ books/courses reference it |
| Character arc tracking | Ad-hoc scene appearance lists | character_state.json with relationships and arc_stage | Already built in Phase 1, integrates with state-manager skill, supports validation |
| Scene ID generation | Random/timestamp IDs | `chXX_sYY` pattern (ch01_s01, ch02_s03) | Human-readable, sortable, maps to file paths, already used in story_state schema |
| Prompt chaining | Manual sequential prompts | Agent orchestration with TeammateTool | Claude Code native feature, manages context isolation, handles errors, supports parallel work |
| Markdown generation | String concatenation | Template-based with frontmatter | JSON Schema for validation, frontmatter for metadata, CommonMark for content |
| Timeline/date validation | Custom date parsing | ISO 8601 format (YYYY-MM-DD) | Already required by timeline_state.json schema, universally parseable, sortable |

**Key insight:** Novel planning is a solved problem in writing craft. Don't invent new structures - use established frameworks that writers trust. Innovation should be in *automation*, not in storytelling theory.

## Common Pitfalls

### Pitfall 1: Context Window Overflow in Single-Shot Generation

**What goes wrong:** Trying to generate entire outline (premise + characters + world + beats) in one massive prompt leads to:
- Lost information in the middle (LLMs "pay more attention to beginning and end")
- Inconsistent character voices across chapters
- Plot holes where details contradict each other
- Generic, shallow output

**Why it happens:** LLMs peak performance around 20,000 characters, degrading beyond that. Single-shot generation tries to hold too much context.

**How to avoid:** Use hierarchical generation with prompt chaining:
1. plot-planner: Generate high-level outline (acts, chapters)
2. beat-planner: Expand each chapter into scenes (one chapter at a time)
3. For each scene: Generate beat sheet referencing only relevant context

**Warning signs:**
- Outline mentions character traits not in characters.md
- Chapter 8 contradicts setup from Chapter 2
- Generic prose that could apply to any story
- Beat sheets that don't reference premise theme

### Pitfall 2: Consistency Drift Across Multiple Generations

**What goes wrong:** Each agent reads canon files independently, leading to:
- plot-planner interprets "coming-of-age" one way
- beat-planner interprets it differently
- Characters appear in scenes they shouldn't based on world.md geography
- Diary dates don't align with seasonal descriptions

**Why it happens:** No single source of truth for generated decisions. Each agent makes independent interpretations.

**How to avoid:**
1. plot-planner writes decisions to story_state.json (chosen structure, act breaks, chapter themes)
2. beat-planner reads story_state.json first, inherits decisions
3. All agents validate against constraints.md
4. Use state-manager skill's validation before saving

**Warning signs:**
- Different word count targets across outline.md and scene beats
- Character appears in Ch3 scene but arc_stage in character_state.json shows them absent
- Diary entries scheduled outside timeline.md date range

### Pitfall 3: Over-Detailed Beat Sheets Too Early

**What goes wrong:** beat-planner generates full prose descriptions, dialogue snippets, detailed descriptions before drafting phase:
- Locks in creative decisions too early
- Makes revision harder (too much to throw away)
- Confuses "planning" with "drafting"

**Why it happens:** LLMs naturally generate flowing prose. Without constraints, they'll write scenes instead of planning them.

**How to avoid:**
1. Explicitly prompt: "Generate PLANNING notes, not prose. Use bullet points."
2. Limit beat sheets to 150-300 words per scene
3. Format: Goal → Conflict → Outcome → Emotional beat → POV notes
4. Save prose generation for draft phase (Phase 3)

**Warning signs:**
- beats/scenes/ch01_s01.md is 2000+ words
- Beat sheet includes dialogue
- Descriptions use past tense prose instead of planning notes

### Pitfall 4: Ignoring Format-Specific Requirements

**What goes wrong:** Using chapter-based planning for diary format:
- No date assignments to entries
- Missing seasonal progression
- Growth milestones not mapped to timeline
- Narrative arc ignores diary constraints (first-person, dated entries, retrospective tone)

**Why it happens:** plot-planner and beat-planner default to chapter thinking. Diary format needs different planning.

**How to avoid:**
1. CMD-05 (/novel:outline) checks format from story_state.json
2. If format == "diary": Invoke diary-planner after beat-planner
3. diary-planner generates diary_plan.md with:
   - Entry dates across timeline
   - Seasonal transitions
   - Growth milestones from constraints.md
   - Weather/environmental changes
4. beat-planner reads diary_plan.md to align scenes with dates

**Warning signs:**
- Diary format project has beats/outline.md with "Chapter 1, Chapter 2"
- No diary_plan.md exists
- story_state.json missing diary_metadata object
- Beat sheets don't reference entry dates

### Pitfall 5: Agent Orchestration Without Error Handling

**What goes wrong:** plot-planner fails (missing premise.md), but beat-planner runs anyway:
- Tries to read non-existent outline.md
- Generates generic scenes unrelated to story
- Updates state incorrectly
- Commits broken files to git

**Why it happens:** Commands don't check agent success before proceeding to next agent.

**How to avoid:**
1. CMD-05 checks for required canon files before invoking plot-planner
2. After plot-planner: Verify beats/outline.md exists and is valid markdown
3. After beat-planner: Verify at least one scene file generated
4. Use try/catch equivalent in agent skill patterns
5. Rollback state changes if generation fails

**Warning signs:**
- Command reports "success" but no files created
- story_state.json shows progress.outline = "complete" but beats/outline.md missing
- Git commit includes empty or corrupted files

## Code Examples

Verified patterns from research and existing Phase 1 artifacts:

### Agent Definition Structure (plot-planner.md)

```markdown
---
allowed-tools: [Read, Write, Bash, Glob, Grep]
description: Generate story outline from canon using proven story structure frameworks
---

<role>
You are the **Plot Planner Agent**, responsible for creating high-level story structure. Your job is to:

1. Read canon files (premise, characters, world) to understand the story
2. Determine appropriate story structure (3-act, 5-act, Save the Cat)
3. Generate beats/outline.md with act breakdown and chapter summaries
4. Update story_state.json with outline progress

You are meticulous about story consistency and provide clear act/chapter structure.
</role>

<commands>
## Usage

Invoked by /novel:outline command. Not called directly by user.

**Input:**
- canon/premise.md (required)
- canon/characters.md (required)
- canon/world.md (optional)
- state/story_state.json (for project metadata)

**Output:**
- beats/outline.md
- Updated state/story_state.json
</commands>

<execution>

## Step 1: Validate Input

Read required canon files and check they exist:

1. Read canon/premise.md - if missing, ERROR and exit
2. Read canon/characters.md - if missing, ERROR and exit
3. Read state/story_state.json - get project.format, project.title

## Step 2: Analyze Story

Use prompt chaining to understand the story:

Prompt 1: Analyze premise.md
- Extract: Core concept, theme, story question, ending type

Prompt 2: Analyze characters.md
- Extract: Protagonist, antagonist, character arcs, relationships

Prompt 3: Determine structure
- Based on target length and complexity, choose 3-act or 5-act
- If target < 50k words: 3-act recommended
- If complex character ensemble: 5-act recommended

## Step 3: Generate Outline

Apply Save the Cat beat sheet to chosen structure:

For 3-act:
- Act 1 (25%): Setup, Catalyst, Break into Two
- Act 2 (50%): B Story, Midpoint, All Is Lost
- Act 3 (25%): Break into Three, Finale, Final Image

Generate beats/outline.md with:
- Act summaries
- Chapter breakdown (estimate scenes per chapter)
- Major plot points
- Character arc placement

## Step 4: Update State

Use state-manager skill to update story_state.json:

1. Set progress.outline = "complete"
2. Add to open_threads if any plot threads introduced
3. Save state

## Step 5: Git Commit

Use git-integration skill to commit:

1. Stage beats/outline.md and state/story_state.json
2. Commit with message: "Generate story outline"
</execution>
```

### Outline.md Output Format

```markdown
# Story Outline: [Title]

**Generated:** [ISO timestamp]
**Structure:** [3-act / 5-act]
**Format:** [chapter / diary]
**Target Length:** [X words]

---

## Theme & Core Question

**Theme:** [One sentence theme statement from premise.md]

**Story Question:** [Central question driving narrative]

**Ending Type:** [hopeful / tragic / bittersweet / triumphant]

---

## Act Structure

### Act 1: Setup (Chapters 1-3, ~15,000 words)

**Purpose:** Introduce protagonist in their ordinary world, inciting incident, decision to pursue goal

**Major Beats:**
- Opening Image: [scene description]
- Theme Stated: [where/how theme appears]
- Catalyst: [inciting incident]
- Break into Two: [commitment to story journey]

**Chapters:**

#### Chapter 1: [Chapter Title]
- **Scenes:** 3-4 estimated
- **Summary:** [2-3 sentence chapter summary]
- **Character Focus:** [POV character, who appears]
- **Emotional Arc:** [where character starts → where they end chapter]

#### Chapter 2: [Chapter Title]
[Same structure]

### Act 2: Confrontation (Chapters 4-12, ~30,000 words)

[Same structure as Act 1]

### Act 3: Resolution (Chapters 13-15, ~15,000 words)

[Same structure as Act 1]

---

## Character Arc Placement

### [Protagonist Name]
- Act 1: [arc_stage from character_state.json]
- Act 2: [development notes]
- Act 3: [transformation completion]

[Repeat for major characters]

---

## Plot Threads

### Open Threads
1. [Thread description] - Introduced in [Chapter X], must resolve by [Chapter Y]

### Expected Resolutions
1. [Thread] resolves in [Chapter X] via [method]

---

*This outline should be edited before running /novel:write. It's a starting point, not a constraint.*
```

### Scene Beat Sheet Format (beats/scenes/ch01_s01.md)

```markdown
---
id: ch01_s01
chapter: 1
scene: 1
status: planned
pov: [Character Name]
---

# Chapter 1, Scene 1: [Scene Title/Description]

## Purpose

**Story Goal:** What this scene accomplishes for the plot
**Character Goal:** What POV character wants in this scene
**Thematic Resonance:** How this scene connects to premise theme

## Structure

**Opening:** [How scene begins - location, time, who's present]

**Conflict:** [What goes wrong, what opposes the goal]

**Turning Point:** [Moment of change, decision, revelation]

**Outcome:** [How scene ends, what changes]

## Character Notes

**POV:** [Character name] in [POV type from style_state.json]

**Appears In Scene:**
- [Character 1]: [Role in scene, emotional state]
- [Character 2]: [Role in scene, emotional state]

**Character Development:**
- [POV character] moves from [emotional state] to [emotional state]
- [Arc progression note]

## Emotional Beat

**Target Emotion:** [What reader should feel]
**Pacing:** [Fast/Medium/Slow based on outline]

## Continuity Notes

**Follows:** [Previous scene ID or "Story opening"]
**Leads to:** [Next scene ID]
**Timeline:** [Date/time if relevant, especially for diary format]
**Location:** [Where scene takes place per world.md]

## Drafting Notes

**Estimated Length:** [500-2000 words based on pacing]
**Key Details to Include:** [Specific world-building, character traits, etc.]
**Avoid:** [Potential pitfalls for this specific scene]

---

*Generated by beat-planner. Edit as needed before drafting.*
```

### diary_plan.md Format (for diary format projects)

```markdown
# Diary Planning: [Title]

**Generated:** [ISO timestamp]
**Date Range:** [start_date] to [end_date]
**Duration:** [X weeks/months]
**Entry Frequency:** [X entries per week]

---

## Temporal Structure

### Timeline

| Entry # | Date | Season | Chapter | Summary |
|---------|------|---------|---------|---------|
| 01 | 2024-03-01 | Early Spring | Ch1 | [Entry summary] |
| 02 | 2024-03-05 | Early Spring | Ch1 | [Entry summary] |
| 03 | 2024-03-12 | Early Spring | Ch2 | [Entry summary] |
[... continues ...]

### Seasonal Progression

**Spring (March-May):**
- Entries: 1-20
- Character arc stage: setup → rising
- Weather progression: Cold/rainy → Warming → Blooming
- Mood: Cautious curiosity → Growing confidence

**Summer (June-August):**
[Similar structure]

**Fall (September-November):**
[Similar structure]

**Winter (December-February):**
[Similar structure]

---

## Growth Milestones

Mapped from canon/constraints.md:

| Date | Entry # | Milestone | Arc Impact |
|------|---------|-----------|------------|
| 2024-04-15 | 10 | [First major achievement] | [How it changes character] |
| 2024-07-01 | 25 | [Midpoint crisis] | [Emotional low point] |
| 2024-11-15 | 45 | [Breakthrough moment] | [Transformation visible] |

---

## Entry Pattern Analysis

### Frequency Variations

- **Normal pace:** 2 entries/week (March-October)
- **Intensified:** 3-4 entries/week during crisis (Chapters 8-10, July-August)
- **Sparse:** 1 entry/week during reflection period (November)

### Narrative Distance Shifts

- Early entries: Present-tense recording ("Today I...")
- Mid-story: More reflection ("Looking back, I realize...")
- Late entries: Wisdom/insight ("I've learned that...")

---

## Date-Based Constraints

From canon/timeline.md:

- **School year:** Sept-June (affects availability, stress levels)
- **Weather events:** [Specific dates that impact story]
- **Fixed milestones:** [Birthdays, holidays, deadlines from timeline.md]

---

*This plan ensures temporal consistency across diary entries. Cross-reference with beats/outline.md for narrative structure.*
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual beat sheets in spreadsheets | LLM-generated markdown with JSON state tracking | 2023-2024 | Writers can iterate 10x faster on structure; AI handles format/consistency while writer focuses on creativity |
| Single-prompt outline generation | Hierarchical prompt chaining (plot → beats → scenes) | 2024-2025 | Reduces context overflow, improves consistency, allows incremental refinement |
| Hero's Journey dominance | Save the Cat beat sheet for novels | 2010s | More prescriptive structure; easier to apply page counts; better pacing guidance |
| Generic story planning | Format-specific planning (diary, serial, chapter) | 2020s | Specialized planners respect format constraints (dates, POV, structure) |
| Static templates | Progressive disclosure agent skills | 2025-2026 | Agents load only relevant context; faster execution; clearer reasoning |

**Deprecated/outdated:**

- **Snowflake Method for AI generation:** Too iterative for LLMs; prompt chaining achieves similar depth with less back-and-forth
- **All-in-one outline prompts:** LLMs lose coherence beyond 20k chars; hierarchical generation now standard
- **Ignoring JSON state:** Early AI tools only output text; modern approach uses dual markdown+JSON for human/machine readability

## Open Questions

Things that couldn't be fully resolved:

1. **Optimal chapter count for different target lengths**
   - What we know: Save the Cat designed for ~110-page screenplay; scales to novels
   - What's unclear: Best chapter count for 50k vs 80k vs 120k word novels; varies by genre
   - Recommendation: Let plot-planner calculate: (target_words / 2000 words per scene) / 3 scenes per chapter = chapter estimate; provide as guidance, not constraint

2. **5-act vs 3-act decision criteria**
   - What we know: 3-act simpler, 5-act adds detail for complex narratives
   - What's unclear: Precise threshold where 5-act becomes better choice
   - Recommendation: Default to 3-act; offer 5-act if: (target > 80k words) OR (characters.md lists 5+ major characters) OR (premise describes multiple subplots)

3. **Beat sheet detail level before drafting**
   - What we know: Too detailed = constraining; too sparse = vague
   - What's unclear: Optimal word count per scene beat sheet
   - Recommendation: 150-300 words per scene beat (goal/conflict/outcome structure); research showed "brief notes" preferred, but no consensus on exact length

4. **Diary entry frequency variation**
   - What we know: Real diaries have irregular entries reflecting life intensity
   - What's unclear: How to algorithmically determine when to vary frequency in fictional diary
   - Recommendation: diary-planner uses simple heuristic: 2/week baseline, 4/week during "crisis" acts, 1/week during "reflection" beats; user can edit diary_plan.md

5. **Agent orchestration: sequential vs parallel**
   - What we know: Claude Code supports both via TeammateTool
   - What's unclear: Whether beat-planner should process chapters in parallel for speed
   - Recommendation: Start with sequential (easier to debug, better consistency); consider parallel in Phase 4 optimization if outline generation takes >2 minutes

## Sources

### Primary (HIGH confidence)

- [Save the Cat Beat Sheet Explained](https://www.studiobinder.com/blog/save-the-cat-beat-sheet/) - Beat sheet structure and novel adaptation
- [Three-Act vs Five-Act Structure](https://nownovel.com/three-act-vs-five-act-structure/) - Structure comparison for novels
- [Claude Code Agent Teams Official Docs](https://code.claude.com/docs/en/agent-teams) - Native orchestration feature
- [Claude Agent Skills Documentation](https://code.claude.com/docs/en/skills) - Progressive disclosure pattern, SKILL.md structure
- [JSON Schema Official Guide](https://json-schema.org/learn/getting-started-step-by-step) - Validation best practices

### Secondary (MEDIUM confidence)

- [AI Story Outline Generation LLM Prompting](https://ainovel.com/threads/prompts-for-generating-long-form-stories.352/) - Iterative generation techniques
- [Prompt Chaining Tutorial](https://www.datacamp.com/tutorial/prompt-chaining-llm) - Sequential reasoning patterns
- [Markdown for LLMs](https://medium.com/@wetrocloud/why-markdown-is-the-best-format-for-llms-aa0514a409a7) - Why markdown over other formats
- [PlotForge Consistency Tracking](https://plotforge.app/) - Character/scene tracking features in novel software
- [Story Arcs Explained](https://penwise.ai/story_arcs-explained/) - Structure, beats, character change

### Tertiary (LOW confidence)

- [AI Can't Catch Plot Holes](https://verityproofreading.com/ai-cant-catch-plot-holes-you-need-an-editor/) - Limitations of AI consistency checking (editorial opinion, not research)
- [Season-long Arcs in TV Writing](https://fiveable.me/tv-writing/unit-5/season-long-arcs/study-guide/LhyukgUn3lxMA6Dl) - Adapted seasonal arc concepts to diary planning; TV-specific, not prose
- [Scene List Article](https://thewritepractice.com/scene-list/) - Scene tracking methods (blog post, not academic)

## Metadata

**Confidence breakdown:**

- **Standard stack:** HIGH - All components either built-in (Claude Code, markdown, JSON) or established standards (Save the Cat, 3-act structure)
- **Architecture:** MEDIUM-HIGH - Agent orchestration well-documented; hierarchical planning proven in research; some details (optimal chapter count) require experimentation
- **Pitfalls:** MEDIUM - Context overflow and consistency drift verified across multiple sources; diary-specific pitfalls inferred from format constraints, less directly sourced

**Research date:** 2026-02-24

**Valid until:** 2026-04-24 (60 days - story structure principles stable; LLM prompting techniques evolving slowly)

**Limitations:**

- Research focused on English-language storytelling frameworks; international story structures not investigated
- Save the Cat is Western screenwriting-derived; may not fit all literary traditions
- Diary format planning based on first-principles reasoning + general narrative arc theory; less direct research on diary-specific AI generation
- Agent orchestration patterns assume Claude Code environment; not portable to other LLM frameworks without adaptation
