# Research: Phase 1 - Foundation & Canon System

**Phase:** 1 of 6
**Researcher:** Phase Research Agent
**Date:** 2026-02-24
**Context:** Novel Engine - Multi-agent novel writing system for Claude Code

---

## Executive Summary

Phase 1 establishes the foundational architecture for the Novel Engine: directory structure, JSON state management, canon template system, and two core commands (`/novel:init` and `/novel:status`). This phase is critical because all subsequent phases depend on these foundations.

**Key Insight:** This is NOT about writing prose—it's about creating the scaffolding, state tracking, and canon truth system that enables consistent multi-agent novel generation in later phases.

**Critical Success Factor:** Get state schema and canon templates right now, because changing them later will break all agents.

---

## Research Questions Answered

### 1. How should Claude Code skills be structured for /novel:init and /novel:status?

**Answer:** Follow the `.claude/commands/*.md` pattern with YAML frontmatter and markdown execution steps.

**Structure Template:**

```markdown
---
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
description: [One-line description]
---

<role>
[Agent persona and responsibility]
</role>

<commands>
## Usage
| Command | Description |
|---------|-------------|
| /novel:init | Initialize novel project |
| /novel:init --diary | Initialize with diary format |
</commands>

<execution>
## Step 1: [Action]
[Detailed instructions]

## Step 2: [Action]
[Detailed instructions]
</execution>

<examples>
[User interaction examples]
</examples>

<edge_cases>
[Error handling scenarios]
</edge_cases>
```

**Key Patterns from Existing Skills:**

1. **Sequential Steps:** Break command into discrete numbered steps
2. **Validation First:** Check prerequisites before acting (e.g., `/commit` checks if git repo exists)
3. **User Feedback:** Show progress at each major step
4. **Error Handling:** Explicit edge cases section
5. **Examples:** Show typical user interactions
6. **Tool Restrictions:** Only list tools actually needed in frontmatter

**For /novel:init Specifically:**

- Step 1: Check if already initialized (detect canon/ directory)
- Step 2: Create directory structure
- Step 3: Initialize state JSON files with schemas
- Step 4: Create canon template files
- Step 5: Optional interactive questionnaire for premise/genre
- Step 6: Git init + .gitignore if needed
- Step 7: Display success message with next steps

**For /novel:status Specifically:**

- Step 1: Load state JSON files (story_state.json, character_state.json, timeline_state.json, style_state.json)
- Step 2: Parse progress indicators (outline done? scenes written? word count?)
- Step 3: Identify current position (which scene/chapter)
- Step 4: Check for open issues (checker warnings, pending revisions)
- Step 5: Display formatted status report
- Step 6: Suggest next action (/novel:outline if not done, /novel:write if ready, etc.)

**File Locations:**

```
claude_src/novel/commands/
├── init.md              # /novel:init
└── status.md            # /novel:status
```

These will be copied/symlinked to `.claude/commands/novel/` during setup.

---

### 2. What's the optimal JSON schema for state files?

**Answer:** Use JSON Schema Draft 2020-12 with strict validation. Design for extensibility (diary format adds fields, doesn't replace).

**Core Principle:** State is mutable (changes frequently), canon is immutable (changes rarely and require approval).

#### story_state.json Schema

**Purpose:** Track overall project progress, scenes, chapters, plot threads

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "story_state.schema.json",
  "title": "Story State",
  "type": "object",
  "required": ["project", "progress", "current"],
  "properties": {
    "project": {
      "type": "object",
      "required": ["title", "version", "format"],
      "properties": {
        "title": {"type": "string", "minLength": 1},
        "version": {"type": "string", "pattern": "^\\d+\\.\\d+$"},
        "format": {
          "type": "string",
          "enum": ["chapter", "diary", "short_story", "serial"]
        },
        "created_at": {"type": "string", "format": "date-time"},
        "last_modified": {"type": "string", "format": "date-time"}
      }
    },
    "progress": {
      "type": "object",
      "properties": {
        "outline": {
          "type": "string",
          "enum": ["not_started", "in_progress", "complete"]
        },
        "beat_plan": {
          "type": "string",
          "enum": ["not_started", "in_progress", "complete"]
        },
        "draft": {
          "type": "string",
          "enum": ["not_started", "in_progress", "complete"]
        },
        "total_word_count": {"type": "integer", "minimum": 0}
      }
    },
    "current": {
      "type": "object",
      "required": ["chapter", "scene"],
      "properties": {
        "chapter": {"type": "integer", "minimum": 1},
        "scene": {"type": "integer", "minimum": 1},
        "date": {
          "type": "string",
          "format": "date",
          "description": "For diary format: current entry date (ISO 8601)"
        }
      }
    },
    "open_threads": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "description"],
        "properties": {
          "id": {"type": "string"},
          "description": {"type": "string"},
          "introduced_in": {"type": "string", "pattern": "^ch\\d{2}_s\\d{2}$"}
        }
      }
    },
    "resolved_threads": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "resolved_in"],
        "properties": {
          "id": {"type": "string"},
          "resolved_in": {"type": "string", "pattern": "^ch\\d{2}_s\\d{2}$"}
        }
      }
    },
    "scene_index": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "chapter", "scene", "status"],
        "properties": {
          "id": {"type": "string", "pattern": "^ch\\d{2}_s\\d{2}$"},
          "chapter": {"type": "integer", "minimum": 1},
          "scene": {"type": "integer", "minimum": 1},
          "status": {
            "type": "string",
            "enum": ["planned", "drafted", "checked", "revised", "approved"]
          },
          "word_count": {"type": "integer", "minimum": 0},
          "date": {"type": "string", "format": "date"},
          "pov": {"type": "string"}
        }
      }
    },
    "diary_metadata": {
      "type": "object",
      "description": "Only for format: diary",
      "properties": {
        "start_date": {"type": "string", "format": "date"},
        "current_date": {"type": "string", "format": "date"},
        "end_date": {"type": "string", "format": "date"},
        "entries_per_week": {"type": "integer", "minimum": 1, "maximum": 7},
        "total_duration_weeks": {"type": "integer", "minimum": 1},
        "seasonal_progression": {
          "type": "object",
          "properties": {
            "current_season": {
              "type": "string",
              "enum": ["spring", "summer", "fall", "winter"]
            }
          }
        },
        "growth_milestones": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["date", "milestone", "status"],
            "properties": {
              "date": {"type": "string", "format": "date"},
              "milestone": {"type": "string"},
              "status": {
                "type": "string",
                "enum": ["pending", "completed", "failed"]
              }
            }
          }
        }
      }
    }
  }
}
```

**Key Decisions:**

- **format field:** Enables diary-specific features without breaking base schema
- **scene_index:** Central registry of all scenes/entries with status tracking
- **open_threads/resolved_threads:** Plot continuity tracking
- **diary_metadata:** Optional, only populated when format = "diary"
- **ISO 8601 dates:** Standard format for all date fields

#### character_state.json Schema

**Purpose:** Track character arcs, relationships, voice notes, current emotional states

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "character_state.schema.json",
  "title": "Character State",
  "type": "object",
  "required": ["characters"],
  "properties": {
    "characters": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "required": ["name", "role"],
        "properties": {
          "name": {"type": "string"},
          "role": {
            "type": "string",
            "enum": ["protagonist", "antagonist", "supporting", "minor"]
          },
          "arc_stage": {
            "type": "string",
            "enum": ["setup", "rising", "crisis", "climax", "resolution"]
          },
          "emotional_state": {"type": "string"},
          "last_appearance": {
            "type": "string",
            "pattern": "^ch\\d{2}_s\\d{2}$"
          },
          "development_notes": {
            "type": "array",
            "items": {"type": "string"}
          }
        }
      }
    },
    "relationships": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["char_a", "char_b", "type"],
        "properties": {
          "char_a": {"type": "string"},
          "char_b": {"type": "string"},
          "type": {
            "type": "string",
            "enum": ["ally", "enemy", "romantic", "mentor", "neutral"]
          },
          "status": {"type": "string"},
          "established_in": {"type": "string", "pattern": "^ch\\d{2}_s\\d{2}$"}
        }
      }
    },
    "voice_notes": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "speech_patterns": {"type": "array", "items": {"type": "string"}},
          "vocabulary": {"type": "array", "items": {"type": "string"}},
          "mannerisms": {"type": "array", "items": {"type": "string"}},
          "example_lines": {"type": "array", "items": {"type": "string"}}
        }
      }
    },
    "arc_notes": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "want": {"type": "string"},
          "need": {"type": "string"},
          "lie_believed": {"type": "string"},
          "truth_learned": {"type": "string"},
          "transformation_status": {
            "type": "string",
            "enum": ["not_started", "in_progress", "complete"]
          }
        }
      }
    }
  }
}
```

**Key Decisions:**

- **characters object:** Keyed by character name for easy lookup
- **voice_notes:** Enables voice-coach agent to check consistency
- **arc_notes:** Tracks character transformation (want/need/lie/truth pattern)
- **relationships array:** Tracks dynamic character connections

#### timeline_state.json Schema

**Purpose:** Track chronology, event ordering, date constraints

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "timeline_state.schema.json",
  "title": "Timeline State",
  "type": "object",
  "required": ["anchors", "events"],
  "properties": {
    "anchors": {
      "type": "array",
      "description": "Fixed dates that cannot change",
      "items": {
        "type": "object",
        "required": ["date", "event"],
        "properties": {
          "date": {"type": "string", "format": "date"},
          "event": {"type": "string"},
          "scene_id": {"type": "string", "pattern": "^ch\\d{2}_s\\d{2}$"}
        }
      }
    },
    "events": {
      "type": "array",
      "description": "All dated events in chronological order",
      "items": {
        "type": "object",
        "required": ["date", "description"],
        "properties": {
          "date": {"type": "string", "format": "date"},
          "time": {"type": "string", "pattern": "^\\d{2}:\\d{2}$"},
          "description": {"type": "string"},
          "scene_id": {"type": "string", "pattern": "^ch\\d{2}_s\\d{2}$"},
          "type": {
            "type": "string",
            "enum": ["plot", "milestone", "background", "deadline"]
          }
        }
      }
    },
    "constraints": {
      "type": "array",
      "description": "Ordering rules (X must happen before Y)",
      "items": {
        "type": "object",
        "required": ["before", "after"],
        "properties": {
          "before": {"type": "string"},
          "after": {"type": "string"},
          "reason": {"type": "string"}
        }
      }
    }
  }
}
```

**Key Decisions:**

- **anchors:** Immutable dates (e.g., "story starts Jan 1, 2024")
- **events:** Chronologically sorted, validated by timeline-keeper agent
- **constraints:** Logical ordering (e.g., "character meets X" before "character leaves X")

#### style_state.json Schema

**Purpose:** Track POV, tense, voice consistency, forbidden phrases

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "style_state.schema.json",
  "title": "Style State",
  "type": "object",
  "required": ["pov", "tense", "voice"],
  "properties": {
    "pov": {
      "type": "string",
      "enum": ["first", "second", "third_limited", "third_omniscient"]
    },
    "tense": {
      "type": "string",
      "enum": ["past", "present"]
    },
    "voice": {
      "type": "string",
      "enum": ["clean", "lyrical", "minimal", "ornate"]
    },
    "narrative_distance": {
      "type": "string",
      "enum": ["close", "medium", "far"]
    },
    "forbidden_phrases": {
      "type": "array",
      "items": {"type": "string"},
      "default": ["suddenly", "all at once", "couldn't help but"]
    },
    "cliche_watchlist": {
      "type": "array",
      "items": {"type": "string"},
      "default": [
        "eyes widened",
        "heart pounded",
        "let out a breath she didn't realize she was holding"
      ]
    },
    "usage_stats": {
      "type": "object",
      "description": "Track phrase frequency for variation checking",
      "additionalProperties": {"type": "integer"}
    }
  }
}
```

**Key Decisions:**

- **Simple enums:** Clear choices, easy validation
- **forbidden_phrases:** User-configurable blacklist
- **cliche_watchlist:** Soft warnings, not hard blocks
- **usage_stats:** Enables variation checking (flag if phrase used >3 times)

**Schema Validation Strategy:**

1. **At Init:** Create state files with default valid values
2. **Before Write:** Validate against schema using Ajv (if Node.js available) or inline checks
3. **On Read:** Graceful fallback if validation fails (use last good state)
4. **Version Migration:** If schema changes, provide migration scripts

**File Locations:**

```
claude_src/novel/schemas/
├── story_state.schema.json
├── character_state.schema.json
├── timeline_state.schema.json
└── style_state.schema.json
```

---

### 3. How should canon templates be designed for easy editing?

**Answer:** Use guided Markdown templates with comments explaining each field. Provide examples inline. Make fields discoverable without documentation.

**Design Principles:**

1. **Self-Documenting:** Template includes inline help
2. **Progressive Disclosure:** Simple fields first, advanced later
3. **Examples Embedded:** Show what good entries look like
4. **Validation-Friendly:** Structure parseable by agents
5. **Human-Editable:** Plain Markdown, no complex syntax

#### premise.md Template

```markdown
# Premise

## Basic Information

**Genre:** [e.g., Coming-of-age, Thriller, Romance, Fantasy]
**Format:** [chapter / diary / short_story / serial]
**Target Length:** [e.g., 50,000 words, 26 diary entries, 12 chapters]

## Core Concept

**Logline:** [One sentence: Who wants what, but what stands in the way?]

Example: "A middle school student in Jeju decides to walk instead of taking the crowded bus, and over one year trains to complete a full marathon."

**Theme Statement:** [What is this story really about?]

Example: "Small daily choices compound into transformative change."

**Core Question:** [What question drives the story forward?]

Example: "Can an ordinary student become extraordinary through consistency?"

## Story Arc

**Opening Image:** [How does the story begin?]

**Ending Type:** [hopeful / tragic / bittersweet / ambiguous / triumphant]

**Ending Image:** [How does the story end?]

## Tone & Mood

**Overall Tone:** [e.g., Hopeful, Dark, Humorous, Reflective]
**Key Emotions:** [e.g., Determination, Loneliness, Joy, Fear]

---

*This file defines the core story concept. All other canon files should align with this premise.*
```

**Why This Works:**

- Bracketed placeholders show expected format
- Inline examples demonstrate quality
- Comments explain purpose
- Section headers organize by concern

#### characters.md Template

```markdown
# Characters

## Protagonist

**Name:** [Full name]
**Age:** [Number]
**Role:** [What they do in the story]

**External Goal:** [What they want to achieve]

**Internal Need:** [What they actually need to grow]

**Fear:** [What holds them back]

**Wound:** [Past hurt shaping current behavior]

**Arc:** [How will they change by the end?]

**Distinctive Traits:**
- [Physical trait]
- [Personality quirk]
- [Speech pattern]
- [Habit or mannerism]

**Voice:**
- [How they speak when confident]
- [How they speak when afraid]
- [Vocabulary they use/avoid]

---

## Antagonist

**Name:**
**Role:** [What opposes the protagonist]

Note: Antagonist doesn't have to be a person (can be internal conflict, society, nature, etc.)

**Goal:** [What they want]
**Method:** [How they pursue it]
**Pressure:** [How they create obstacles]

---

## Supporting Characters

### [Character Name]

**Role:** [Mentor / Sidekick / Love Interest / Rival]
**Relationship to Protagonist:**
**Key Trait:**
**Purpose in Story:** [Why this character exists]

---

*Add more supporting characters as needed. Each should serve a clear story function.*
```

**Why This Works:**

- Structured fields agents can parse
- Protagonist gets most detail (they're most important)
- Supporting characters use simplified template
- Voice section enables voice-coach agent
- Flexible (add more characters as needed)

#### world.md Template

```markdown
# World

## Setting

**Primary Location:** [Where does most of the story take place?]

**Time Period:** [When? Modern day, historical, future?]

**Geography:** [Physical environment details]

**Climate/Seasons:** [Relevant weather patterns]

---

## Rules

**Physical Rules:** [How does the world work? (Laws of physics, magic systems, technology levels)]

**Social Rules:** [Cultural norms, taboos, power structures]

**Economic Rules:** [How do people make a living? What has value?]

---

## Institutions

**Key Organizations:** [Schools, governments, corporations, guilds]

**Power Structures:** [Who has authority? How is it maintained?]

---

## Conflicts

**External Conflicts:** [Society-level problems affecting characters]

**Environmental Pressures:** [Natural forces, scarcity, dangers]

---

*This file defines the story's universe. Characters should act consistently with these rules.*
```

**Why This Works:**

- Separates physical/social/economic rules (easier to track)
- Institutions section helps with worldbuilding consistency
- Conflicts section connects world to plot
- Flexible structure (skip irrelevant sections)

#### style_guide.md Template

```markdown
# Style Guide

## Narrative Perspective

**POV:** [first / second / third_limited / third_omniscient]

**Tense:** [past / present]

**Narrative Distance:** [close / medium / far]

Explanation:
- Close: Deep in character's head, limited vocabulary
- Medium: Character's perspective but some authorial voice
- Far: Distant, observational, broader vocabulary

---

## Voice & Diction

**Voice Type:** [clean / lyrical / minimal / ornate]

**Diction Level:** [plain / literary / technical]

**Sentence Rhythm:** [short and punchy / varied / long and flowing]

---

## Dialogue Rules

**Formatting:**
- [Standard quotation marks / em dashes / other]

**Style:**
- Keep lines short, subtext-forward
- Avoid exposition dumps
- [Add project-specific rules]

---

## Forbidden Elements

**Banned Phrases:**
- "suddenly"
- "all at once"
- "couldn't help but"
- [Add more as needed]

**Cliché Watchlist:**
- "eyes widened"
- "heart pounded"
- "let out a breath she didn't realize she was holding"
- [Add more as needed]

**Other Restrictions:**
- [No adverbs in dialogue tags]
- [No passive voice except when deliberate]
- [Add project-specific rules]

---

## Signature Motifs

**Recurring Elements:**
- [e.g., Weather imagery, Clock references, Smell descriptions]
- [These make your voice distinctive]

**Color Palette:** [Dominant colors in imagery, if any]

**Sensory Focus:** [Which senses emphasized? Visual, auditory, tactile, etc.]

---

*This file is law for all generated prose. The voice-coach agent enforces these rules.*
```

**Why This Works:**

- Explicit POV/tense prevents drift
- Forbidden phrases enable automated checking
- Motifs section captures authorial voice
- Organized by concern (perspective, voice, rules, style)

#### timeline.md Template

```markdown
# Timeline

## Anchor Dates

These dates are fixed and cannot change.

| Date | Event | Notes |
|------|-------|-------|
| 2024-01-10 | Story begins | First day of walking |
| 2024-12-15 | Story ends | Marathon completion |

---

## Known Sequences

Events that must happen in this order (even if exact dates unknown):

1. [First event]
2. [Second event]
3. [Third event]

---

## Constraints

**Must happen before X:**
- [Event A] before [Event B] because [reason]

**Must not happen before Y:**
- [Event C] cannot happen until [Event D] because [reason]

**Duration Rules:**
- [Event E] takes [X days/weeks]
- Between [Event F] and [Event G]: [minimum/maximum duration]

---

## Seasonal Markers

For diary format: Track seasonal progression

| Season | Start Date | End Date | Key Events |
|--------|------------|----------|------------|
| Winter | 2024-01-10 | 2024-03-20 | Initial training |
| Spring | 2024-03-21 | 2024-06-20 | First 10k run |
| Summer | 2024-06-21 | 2024-09-20 | Half marathon prep |
| Fall | 2024-09-21 | 2024-12-15 | Final training, marathon |

---

*This file constrains the timeline-keeper agent. Violations are flagged as errors.*
```

**Why This Works:**

- Table format for easy parsing
- Separate sections for dates vs. ordering
- Constraints section captures logic
- Seasonal markers support diary format

#### constraints.md Template

```markdown
# Constraints

## Content Boundaries

**Must Include:**
- [Required elements, themes, or scenes]
- [Non-negotiable story beats]

**Must Avoid:**
- [Topics, themes, or content types to exclude]
- [Sensitive subjects]

**Rating Target:** [G / PG / PG-13 / R]

---

## Genre Constraints

**Genre:** [Primary genre]

**Must Have (Genre Conventions):**
- [Tropes or elements readers expect]

**Subversions:**
- [Which tropes are deliberately broken or twisted]

---

## Locale & Era Constraints

**Setting Rules:**
- [Geographic limitations]
- [Time period accuracy requirements]
- [Cultural authenticity notes]

**Language:**
- [Dialect, slang, or period-appropriate speech]
- [Words/phrases to avoid (anachronisms)]

---

## Continuity Hard Rules

**Physical:**
- [e.g., Character X cannot be in two places at once]
- [e.g., Technology level is consistent throughout]

**Character:**
- [e.g., Character Y has established fear of water]
- [e.g., Character Z never uses violence]

**Plot:**
- [e.g., No deus ex machina solutions]
- [e.g., All foreshadowing must pay off]

---

*This file is enforced by the canon-checker agent. Violations are critical errors.*
```

**Why This Works:**

- Clear boundaries prevent scope creep
- Rating target guides content decisions
- Continuity rules enable automated checking
- Subversions section allows intentional rule-breaking

**Template Design Principles Applied:**

1. **Comments in [brackets]:** Show expected input format
2. **Examples embedded:** Demonstrate quality
3. **Tables where appropriate:** Structured data for parsing
4. **Section headers:** Organize by concern
5. **Bottom note:** Explains enforcement mechanism

**File Locations:**

```
claude_src/novel/templates/
├── premise.md
├── characters.md
├── world.md
├── style_guide.md
├── timeline.md
└── constraints.md
```

These are copied to user's `canon/` directory during `/novel:init`.

---

### 4. How should Git integration work (auto-commit on what events)?

**Answer:** Follow GSD atomic commit pattern—one commit per significant artifact. Make commits optional (configurable).

**Commit Strategy:**

**When to Auto-Commit:**

1. **After `/novel:init`:** Initial project structure
   ```
   commit message: "Initialize novel project: [Title]"
   files: canon/*, state/*.json, .gitignore
   ```

2. **After canon file edits:** When user manually updates canon
   ```
   commit message: "Update canon: [which file]"
   files: canon/[file].md
   strategy: Detect changes via git status, commit only changed canon files
   ```

3. **After `/novel:outline`:** When outline is generated
   ```
   commit message: "Generate story outline"
   files: beats/outline.md, beats/act_structure.md, state/story_state.json
   ```

4. **After scene completion:** When scene is approved by quality gate
   ```
   commit message: "Complete scene ch[XX]_s[YY]: [scene title]"
   files: draft/scenes/ch[XX]_s[YY].md, state/*.json
   ```

5. **After revision:** When rewrite is completed
   ```
   commit message: "Revise scene ch[XX]_s[YY]: [issue addressed]"
   files: draft/scenes/ch[XX]_s[YY].md, state/story_state.json
   ```

**When NOT to Auto-Commit:**

- After every state file update (too frequent)
- During planning/checking phases (intermediate work)
- On command failures or errors

**Configuration:**

Add to `state/story_state.json`:

```json
{
  "project": {
    "git_integration": {
      "enabled": true,
      "auto_commit_canon": true,
      "auto_commit_scenes": true,
      "auto_commit_state": false
    }
  }
}
```

**Implementation Pattern:**

From GSD reference (`.claude/get-shit-done/references/git-integration.md`):

```markdown
## Atomic Commit Pattern

1. Complete discrete unit of work
2. Verify outputs valid
3. Stage only related files
4. Generate descriptive message
5. Commit with co-author tag
6. Update state

Co-Author Format:
```
[message]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```
```

**Git Workflow for /novel:init:**

```bash
# Step 1: Check if git repo exists
if ! git rev-parse --is-inside-work-tree 2>/dev/null; then
  git init
fi

# Step 2: Create .gitignore if missing
if [ ! -f .gitignore ]; then
  cat > .gitignore <<EOF
# Novel Engine temporary files
.novel_cache/
state/.backup/
draft/versions/.tmp/

# OS files
.DS_Store
Thumbs.db

# Editor files
*.swp
*.swo
.vscode/
.idea/
EOF
fi

# Step 3: After creating structure, stage and commit
git add canon/ state/ beats/ draft/ .gitignore
git commit -m "$(cat <<'EOF'
Initialize novel project: [Title]

Created directory structure and canon templates.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

**Git Workflow for Canon Changes:**

```bash
# Detect changed canon files
changed_files=$(git status --porcelain canon/ | awk '{print $2}')

if [ -n "$changed_files" ]; then
  # User modified canon, commit changes
  git add canon/

  # Generate commit message based on which files changed
  if echo "$changed_files" | grep -q "premise.md"; then
    msg="Update premise"
  elif echo "$changed_files" | grep -q "characters.md"; then
    msg="Update character profiles"
  else
    msg="Update canon files"
  fi

  git commit -m "$(cat <<EOF
$msg

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
fi
```

**Safety Rules:**

1. **Never commit secrets:** .gitignore must include `.env`, `credentials.json`, etc.
2. **Never force push:** No destructive git operations
3. **Never amend:** Always create new commits (GSD pattern)
4. **Always use heredoc for messages:** Ensure proper formatting
5. **Graceful degradation:** If git fails, continue operation (don't block user)

**File Location:**

```
claude_src/novel/skills/
└── git-integration.md
```

Referenced by commands that need git operations.

---

### 5. What validation should /novel:init perform?

**Answer:** Validate environment, detect conflicts, verify prerequisites, provide actionable errors.

**Validation Checklist:**

#### Pre-Flight Checks

1. **Check if already initialized:**
   ```bash
   if [ -d "canon" ] || [ -d "state" ]; then
     echo "ERROR: Novel project already initialized in this directory."
     echo "Found: $(ls -d canon state beats draft 2>/dev/null | tr '\n' ', ')"
     echo ""
     echo "Options:"
     echo "  - Run /novel:status to see current project"
     echo "  - Delete directories to re-initialize (WARNING: loses data)"
     echo "  - Initialize in a different directory"
     exit 1
   fi
   ```

2. **Check write permissions:**
   ```bash
   if ! touch .novel_test_write 2>/dev/null; then
     echo "ERROR: No write permission in current directory."
     echo "Cannot create novel project files."
     exit 1
   fi
   rm .novel_test_write
   ```

3. **Check available disk space:**
   ```bash
   # Warn if less than 100MB free (not blocking, just warning)
   available=$(df . | tail -1 | awk '{print $4}')
   if [ "$available" -lt 102400 ]; then
     echo "WARNING: Less than 100MB disk space available."
     echo "Novel project may grow large with many scenes."
   fi
   ```

#### Argument Validation

1. **Format flag validation:**
   ```bash
   if [ "$1" = "--diary" ] || [ "$1" = "--chapter" ] || [ "$1" = "--short" ]; then
     format=${1#--}  # Remove -- prefix
   else
     format="chapter"  # Default
   fi

   # Validate format is recognized
   case "$format" in
     diary|chapter|short|serial)
       # Valid
       ;;
     *)
       echo "ERROR: Unknown format: $format"
       echo "Valid formats: diary, chapter, short, serial"
       exit 1
       ;;
   esac
   ```

2. **Title validation (if provided):**
   ```bash
   # /novel:init "My Novel Title"
   title="$2"

   if [ -n "$title" ]; then
     # Check title length
     if [ ${#title} -lt 1 ]; then
       echo "ERROR: Title cannot be empty"
       exit 1
     fi

     if [ ${#title} -gt 200 ]; then
       echo "ERROR: Title too long (max 200 characters)"
       exit 1
     fi
   else
     # Prompt for title interactively
     title="Untitled Novel"
   fi
   ```

#### Post-Creation Validation

1. **Verify directory structure created:**
   ```bash
   for dir in canon state beats draft; do
     if [ ! -d "$dir" ]; then
       echo "ERROR: Failed to create directory: $dir"
       echo "Initialization incomplete. Cleaning up..."
       rm -rf canon state beats draft
       exit 1
     fi
   done
   ```

2. **Verify state JSON files valid:**
   ```bash
   for file in state/story_state.json state/character_state.json \
               state/timeline_state.json state/style_state.json; do
     if ! jq empty "$file" 2>/dev/null; then
       echo "ERROR: Invalid JSON in $file"
       echo "Initialization incomplete. Cleaning up..."
       rm -rf canon state beats draft
       exit 1
     fi
   done
   ```

3. **Verify canon templates created:**
   ```bash
   for file in premise.md characters.md world.md style_guide.md \
               timeline.md constraints.md; do
     if [ ! -f "canon/$file" ]; then
       echo "ERROR: Missing canon template: canon/$file"
       echo "Initialization incomplete. Cleaning up..."
       rm -rf canon state beats draft
       exit 1
     fi
   done
   ```

#### Interactive Validation (Optional Questionnaire)

If user provides `--interactive` flag:

```markdown
## Interactive Setup

Ask these questions in sequence:

1. **Project Format:**
   "What format is your novel? [chapter / diary / short / serial]"
   → Validate against enum

2. **Project Title:**
   "What is your novel's title?"
   → Validate length (1-200 chars)

3. **Genre:**
   "What genre? [fantasy / scifi / romance / thriller / literary / other]"
   → Store in premise.md

4. **Target Length:**
   "Target length? [e.g., 50000 words, 26 entries, 12 chapters]"
   → Parse and validate format

5. **POV:**
   "Narrative perspective? [first / third_limited / third_omniscient]"
   → Validate against enum, store in style_state.json

6. **Tense:**
   "Narrative tense? [past / present]"
   → Validate against enum, store in style_state.json

After questions, show summary:
```
You're creating:
  Title: [title]
  Format: [format]
  Genre: [genre]
  Length: [length]
  POV: [pov]
  Tense: [tense]

Proceed? [Y/n]
```

Validate answer is Y/y/yes/Yes (case-insensitive) or empty (default yes).
```

**Error Message Design Principles:**

1. **Actionable:** Tell user how to fix, not just what's wrong
2. **Specific:** Include exact values that failed validation
3. **Graceful:** Offer alternatives when blocking
4. **Clean up on failure:** Don't leave partial state

**Example Error Messages:**

```
❌ Good Error:
"ERROR: Novel project already initialized.
Found directories: canon, state, beats

Options:
  • Run /novel:status to view current project
  • Move to a different directory to start fresh
  • Delete existing directories (WARNING: deletes all work)"

❌ Bad Error:
"Error: init failed"
```

```
✅ Good Error:
"ERROR: Invalid format: 'novella'

Valid formats:
  • chapter  - Traditional chapter-based novel
  • diary    - Dated diary entries
  • short    - Short story (single file)
  • serial   - Web serial with episodes

Example: /novel:init --diary"

❌ Bad Error:
"Unknown format"
```

**Validation Order:**

1. Environment checks (permissions, space) - FIRST (fail fast)
2. Argument validation - BEFORE any file creation
3. Creation validation - AFTER file creation
4. Interactive validation - OPTIONAL, user-triggered

**File Location:**

```
claude_src/novel/commands/init.md
```

Validation logic embedded in execution steps.

---

## Architecture Decisions

### 1. Directory Structure

**Decision:** Four-layer architecture (canon, state, beats, draft)

**Rationale:**

- **canon/** — Immutable truth, human-editable
- **state/** — Mutable progress, machine-managed JSON
- **beats/** — Plot structure, intermediate layer
- **draft/** — Output manuscripts, versioned

**Why Not Flat?**

- Mixing canon and state in one directory causes confusion
- Agents need clear boundaries (read canon, update state)
- Enables selective git commits (canon changes vs. state updates)

**Why Not Nested?**

- `draft/state/` would bury state files
- Flat top-level makes state accessible for status checks

**Directory Tree:**

```
project-root/
├── canon/                     # Immutable truth (user edits)
│   ├── premise.md
│   ├── characters.md
│   ├── world.md
│   ├── style_guide.md
│   ├── timeline.md
│   └── constraints.md
├── state/                     # Mutable progress (agent updates)
│   ├── story_state.json
│   ├── character_state.json
│   ├── timeline_state.json
│   └── style_state.json
├── beats/                     # Story structure (agent-generated)
│   ├── outline.md
│   ├── act_structure.md
│   └── beat_plan.md
├── draft/                     # Manuscripts (agent-generated)
│   ├── scenes/
│   │   ├── ch01_s01.md
│   │   └── ch01_s02.md
│   ├── chapters/
│   │   └── ch01.md
│   └── versions/
│       ├── v1_draft/
│       └── v2_revised/
└── .gitignore
```

**Additional Directories (Created Later):**

- `beats/diary_plan.md` — If format=diary (Phase 3)
- `draft/entries/` — If format=diary (Phase 3)
- `published/` — EPUB output (Phase 6)

---

### 2. State vs. Canon Boundary

**Decision:** Canon is immutable law, State is mutable tracking

**Canon (Immutable):**

- Changes require explicit user approval
- Updated manually by user editing Markdown
- Committed to git immediately when changed
- Agents READ canon, never write

**State (Mutable):**

- Updated automatically by agents after operations
- JSON format (machine-managed)
- Committed to git only at milestones (scene completion)
- Agents READ and WRITE state

**Why This Matters:**

Prevents drift. If canon could be auto-updated, agents might accidentally change core story decisions. Forcing manual canon updates ensures user control.

**Example:**

- Canon: `characters.md` says "Character X is afraid of water"
- State: `character_state.json` tracks "Character X arc_stage: setup"
- If scene violates canon (X swims happily), canon-checker flags it
- Solution: Either fix scene OR user manually updates canon (removes fear)

---

### 3. JSON Schema Versioning

**Decision:** Include schema version in state files, plan for migration

**Schema Version Field:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "schema_version": "1.0",
  "project": { ... }
}
```

**Why:**

When Phase 3 adds diary features, existing projects need migration:

```json
// v1.0 (Phase 1)
{
  "schema_version": "1.0",
  "project": { "title": "...", "version": "..." }
}

// v1.1 (Phase 3)
{
  "schema_version": "1.1",
  "project": {
    "title": "...",
    "version": "...",
    "format": "chapter"  // NEW FIELD
  }
}
```

**Migration Strategy:**

1. `/novel:init` creates v1.1 directly
2. Existing v1.0 projects auto-migrate on first command
3. Migration adds missing fields with sensible defaults
4. Log migration in git commit

---

### 4. Template Design Philosophy

**Decision:** Self-documenting templates with inline help

**Anti-Pattern:** Minimal templates requiring external documentation

```markdown
# BAD: Minimal Template
# Premise
- Genre:
- Logline:
- Theme:
```

User has to read separate docs to know what "Logline" means.

**Pattern:** Inline examples and explanations

```markdown
# GOOD: Self-Documenting Template
# Premise

**Logline:** [One sentence: Who wants what, but what stands in the way?]

Example: "A middle school student decides to walk instead of taking the crowded bus..."
```

User knows exactly what to write without leaving the file.

**Why:**

- Reduces onboarding friction
- Makes templates discoverable
- Agents can parse structure even with examples present
- Users can delete examples once they understand

---

### 5. Git Integration as Optional Feature

**Decision:** Auto-commit is configurable, not mandatory

**Rationale:**

- Some users may not want git
- Others may prefer manual commits
- Default to enabled (opinionated but useful)

**Implementation:**

Check `story_state.json` for `git_integration.enabled` before git operations. If false, skip silently.

**Why Not Always On?**

- Users may already have git workflow
- Some may use other VCS
- Flexibility increases adoption

---

## Implementation Dependencies

### Required for Phase 1

1. **Claude Code CLI** — Runtime environment (already available)
2. **Git** — Version control (detect at runtime, gracefully degrade if missing)
3. **Bash** — Command execution (already available)

### Optional for Phase 1

1. **Node.js** — For JSON schema validation with Ajv (fallback: inline validation)
2. **jq** — For JSON manipulation (fallback: use Read/Write tools)

### NOT Required for Phase 1

- Pandoc (Phase 6)
- Python (not needed)
- External databases (file-based state)
- Web server (CLI-only)

---

## Pitfalls to Avoid (Phase 1 Specific)

Based on `.planning/research/PITFALLS.md`:

### 1. Jumping to Code Without Architecture ✓ ADDRESSED

**Mitigation:** This research document defines architecture before implementation

### 2. State Mutation Without Verification ✓ ADDRESSED

**Mitigation:** JSON schema validation mandatory, state transition validators planned

### 3. Bloated Context Files ✓ ADDRESSED

**Mitigation:** Canon files are modular (6 separate files), each under cognitive budget

### 4. JSON Syntax Errors ✓ ADDRESSED

**Mitigation:** Validation before every write, pretty-printing enforced

### 5. Inadequate Context Provision ✓ ADDRESSED

**Mitigation:** Rich canon templates with examples, self-documenting design

### 6. Version Control Chaos ✓ ADDRESSED

**Mitigation:** Atomic commits, semantic versioning, never delete policy

### 7. Poor Problem Domain Organization ✓ ADDRESSED

**Mitigation:** Directory structure organized by concern (canon/state/beats/draft), not technical layers

### 8. Complexity Overload ✓ ADDRESSED

**Mitigation:** Minimal viable state schema, no redundancy, flat structures

### 9. Specification Errors Before Coordination ✓ ADDRESSED

**Mitigation:** State schemas defined explicitly, agent I/O contracts clear

### 10. Lacking Long-Form Memory Architecture ✓ ADDRESSED

**Mitigation:** Persistent state separate from context, canon as long-term memory

---

## Testing Strategy for Phase 1

### Unit Tests (Not Applicable)

AI-generated content is non-deterministic, traditional unit tests don't apply.

### Validation Tests

1. **JSON Schema Validation:**
   - Create sample state files
   - Validate against schemas
   - Ensure all required fields present
   - Test with invalid data (expect failure)

2. **Template Parsing:**
   - Create sample canon files
   - Parse with simple regex/string matching
   - Verify agents can extract fields

3. **Directory Creation:**
   - Run `/novel:init` in clean directory
   - Verify all 4 directories created
   - Verify all 6 canon templates created
   - Verify all 4 state JSON files created

### Integration Tests

1. **Full Init Workflow:**
   ```
   /novel:init "Test Novel"
   → Verify directories created
   → Verify state files valid JSON
   → Verify git commit created (if git enabled)
   → /novel:status
   → Verify status shows "No scenes written yet"
   ```

2. **Init Failure Recovery:**
   ```
   /novel:init (in read-only directory)
   → Verify error message actionable
   → Verify no partial state left behind
   ```

3. **Re-Init Prevention:**
   ```
   /novel:init "First Novel"
   /novel:init "Second Novel"  (should fail)
   → Verify error message explains conflict
   → Verify first project untouched
   ```

### User Acceptance Tests

1. **User can initialize project without documentation**
   - Metric: Template comments sufficient?
   - Test: Give to test user, observe if they ask questions

2. **User can understand status output**
   - Metric: Status message clear?
   - Test: Show status output, ask what it means

3. **User can edit canon files without breaking agents**
   - Metric: Templates remain parseable?
   - Test: User edits templates, verify agents still read correctly

---

## Open Questions & Decisions Needed

### 1. Interactive vs. Non-Interactive Init

**Question:** Should `/novel:init` default to interactive questionnaire or minimal setup?

**Options:**

A. **Default Interactive:** Always ask questions, `--quiet` flag skips
B. **Default Quiet:** Minimal setup, `--interactive` flag enables questionnaire
C. **Smart Detection:** Interactive if terminal supports it, quiet otherwise

**Recommendation:** Option B (Default Quiet)

**Rationale:**

- Faster for experienced users
- Scriptable/automatable
- Interactive mode available when needed
- Follows Unix philosophy (do one thing, do it well)

**Example:**

```bash
/novel:init                        # Quick setup with defaults
/novel:init --interactive          # Guided questionnaire
/novel:init "My Novel" --diary     # Quick setup with args
```

---

### 2. Canon File Format: Freeform vs. Structured

**Question:** Should canon files be pure Markdown (flexible) or structured YAML frontmatter + Markdown (parseable)?

**Options:**

A. **Pure Markdown:** Human-editable, flexible, harder to parse
B. **YAML Frontmatter:** Machine-parseable, structured, less flexible
C. **Hybrid:** Structured sections in Markdown (current design)

**Recommendation:** Option C (Hybrid)

**Rationale:**

- Current template design uses Markdown headers as structure
- Agents can parse via simple regex (no YAML parser needed)
- Users can add freeform notes in any section
- Best of both worlds

**Example:**

```markdown
# Characters

## Protagonist

**Name:** Alice Chen
**Age:** 14

(User can add freeform notes here and agents ignore them)
```

Agents extract: `Name: Alice Chen`, `Age: 14` via regex. User notes preserved.

---

### 3. State File Backup Strategy

**Question:** Should state files auto-backup before each write?

**Options:**

A. **No Backup:** Rely on git history
B. **Rolling Backup:** Keep last N versions (state/.backup/)
C. **Timestamp Backup:** Backup on every write with timestamp

**Recommendation:** Option A (No Backup) + Git

**Rationale:**

- Git already provides backup/history
- Additional backups add complexity
- Disk space grows unbounded
- If user doesn't use git, they accept the risk

**Fallback:** If critical bug found, add backups in patch release

---

### 4. Error Handling Philosophy

**Question:** Should errors be blocking (halt execution) or warnings (continue with degraded function)?

**Options:**

A. **Always Block:** Any error stops command
B. **Always Warn:** Log error, continue
C. **Critical Block, Non-Critical Warn:** Hybrid approach

**Recommendation:** Option C (Hybrid)

**Critical Errors (Block):**

- Cannot write files (permissions)
- Invalid state JSON (corruption)
- Missing required canon files

**Non-Critical Errors (Warn):**

- Git operations fail (continue without git)
- Optional validation fails (log warning)
- Disk space low (warn but continue)

**Rationale:**

- Blocking critical errors prevents data loss
- Warning non-critical errors improves UX
- User stays in control

---

## Next Steps (Implementation)

### Plan 1.1: Directory Structure & State Initialization

**Tasks:**

1. Create directory scaffolding logic
2. Define JSON state file schemas
3. Implement state loading/saving utilities
4. Validate state files after creation

**Deliverables:**

- `claude_src/novel/schemas/*.json` (4 files)
- `claude_src/novel/utils/state.js` (if Node.js) or inline in commands
- Test: Can create valid state files

**Blockers:** None (greenfield)

---

### Plan 1.2: /novel:init Command

**Tasks:**

1. Build initialization command
2. Create canon file templates
3. Add interactive questionnaire
4. Implement validation checks

**Deliverables:**

- `claude_src/novel/commands/init.md`
- `claude_src/novel/templates/*.md` (6 files)
- Test: Can initialize project end-to-end

**Blockers:** Requires Plan 1.1 (state schemas)

---

### Plan 1.3: /novel:status Command & Git Integration

**Tasks:**

1. Build status reporting command
2. Implement git auto-commit logic
3. Add .gitignore generation
4. Create git integration skill

**Deliverables:**

- `claude_src/novel/commands/status.md`
- `claude_src/novel/skills/git-integration.md`
- `.gitignore` template
- Test: Can show status, auto-commit works

**Blockers:** Requires Plan 1.2 (init must run first)

---

## Success Metrics

### Phase 1 Complete When:

1. ✓ User can run `/novel:init` and see all 4 directories created
2. ✓ User can view all 4 state JSON files with valid content
3. ✓ User can edit all 6 canon template files with inline help
4. ✓ User can run `/novel:status` and see meaningful output
5. ✓ Git auto-commits canon changes (if git enabled)

### Quality Gates:

- JSON schema validation passes for all state files
- Canon templates are self-documenting (no external docs needed)
- Error messages are actionable
- Commands complete in <5 seconds on typical hardware
- No partial state left on error (clean failure)

---

## References

### Internal Documents

- `.planning/PROJECT.md` — Core value and constraints
- `.planning/REQUIREMENTS.md` — v1 requirements
- `.planning/ROADMAP.md` — Phase breakdown
- `.planning/research/STACK.md` — Technology decisions
- `.planning/research/ARCHITECTURE.md` — Multi-agent design
- `.planning/research/PITFALLS.md` — Common mistakes

### Novel Engine Reference

- `novel-engine/state/*.json` — Example state files
- `novel-engine/canon/*.md` — Example canon templates
- `novel-engine/CLAUDE.md` — Orchestrator pattern

### Claude Code Patterns

- `.claude/commands/commit.md` — Command structure example
- `.claude/commands/current.md` — Status reporting pattern
- `.claude/docs/skills.md` — Skill system documentation
- `.claude/get-shit-done/references/git-integration.md` — Git workflow

### External Standards

- JSON Schema Draft 2020-12: https://json-schema.org/
- ISO 8601 (Dates): https://en.wikipedia.org/wiki/ISO_8601
- CommonMark (Markdown): https://commonmark.org/
- Semantic Versioning: https://semver.org/

---

## Conclusion

Phase 1 is architecturally complete when:

1. **Foundation is stable:** Directory structure, state schema, canon templates
2. **Commands work:** `/novel:init` and `/novel:status` functional
3. **Git integration optional:** Auto-commit works but doesn't block
4. **Validation comprehensive:** Errors are caught early and reported clearly
5. **Templates self-document:** Users don't need external docs to start

**Critical Path:** This phase must be rock-solid because all future phases build on these foundations. State schema changes later are expensive.

**Risk Mitigation:** Extensive validation testing before Phase 2 starts.

**Next Phase:** Phase 2 (Planning Pipeline) can begin once all Plan 1.1-1.3 tasks complete and verification passes.

---

*Research complete: 2026-02-24*
*Ready for planning: Phase 1 Plans 1.1, 1.2, 1.3*
