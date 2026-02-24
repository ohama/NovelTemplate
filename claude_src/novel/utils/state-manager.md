---
name: state-manager
description: Reusable skill for loading, saving, and updating JSON state files with validation
version: 1.0
---

# State Manager Skill

This skill provides standardized patterns for state file I/O operations. Invoke these patterns when working with state files in `state/` directory.

## State File Locations

```
state/
├── story_state.json       # Project progress, scenes, plot threads
├── character_state.json   # Characters, relationships, arcs
├── timeline_state.json    # Events, anchors, constraints
├── style_state.json       # POV, tense, voice, forbidden phrases
```

## Schemas Location

```
claude_src/novel/schemas/
├── story_state.schema.json
├── character_state.schema.json
├── timeline_state.schema.json
├── style_state.schema.json
├── story_state.default.json
├── character_state.default.json
├── timeline_state.default.json
├── style_state.default.json
```

---

## Functions

### load_state(type)

**Purpose:** Read and parse a state file, returning valid JSON data.

**Parameters:**
- `type`: One of `story`, `character`, `timeline`, `style`

**Returns:** Parsed JSON object

**Pattern:**

```
1. Determine file path: state/{type}_state.json
2. Check if file exists using Read tool
3. If file exists:
   a. Read file content
   b. Parse as JSON
   c. Validate schema_version field exists
   d. Return parsed object
4. If file missing:
   a. Log warning: "State file missing, using defaults"
   b. Read default from: claude_src/novel/schemas/{type}_state.default.json
   c. Return default object
5. If JSON parse fails:
   a. Log error: "Corrupted state file: {path}"
   b. Attempt recovery from git: git show HEAD:state/{type}_state.json
   c. If recovery succeeds, return recovered object
   d. If recovery fails, return default object
```

**Example Usage:**

```markdown
## Load Character State

I need to check the current character states.

1. Read state/character_state.json
2. Parse the JSON content
3. If the file doesn't exist or is corrupted, fall back to defaults

Result: {parsed character state object}
```

**Error Handling:**
- Missing file: Use default state (not an error, just log info)
- Invalid JSON: Attempt git recovery, then fall back to default
- Missing schema_version: Add it (migration scenario)

---

### save_state(type, data)

**Purpose:** Validate and write state data to file.

**Parameters:**
- `type`: One of `story`, `character`, `timeline`, `style`
- `data`: JavaScript object to save

**Returns:** Boolean success indicator

**Pattern:**

```
1. Validate data has schema_version field
   - If missing, add schema_version: "1.0"
2. Validate required fields exist based on type:
   - story: project, progress, current
   - character: characters
   - timeline: anchors, events
   - style: pov, tense, voice
3. If validation fails:
   a. Log error with specific field that failed
   b. Return false (do NOT write invalid data)
4. If validation passes:
   a. Pretty-print JSON (2-space indent)
   b. Write to state/{type}_state.json
   c. Update last_modified timestamp if applicable
   d. Return true
```

**Example Usage:**

```markdown
## Save Story State

After updating the scene index, I need to persist the changes.

1. Verify data has required fields: project, progress, current
2. Ensure schema_version is present
3. Pretty-print the JSON
4. Write to state/story_state.json

Result: State saved successfully
```

**Validation Approach:**

Since this is Claude Code (not a codebase with imports), use inline checks:

```markdown
## Inline Validation Check

Before saving story_state:
- Check data.project exists and is object
- Check data.project.title is non-empty string
- Check data.project.format is one of: chapter, diary, short_story, serial
- Check data.progress exists and is object
- Check data.current exists with chapter and scene numbers
```

**Error Handling:**
- Missing required field: Log which field, do not save
- Invalid enum value: Log valid options, do not save
- Write failure: Log error, suggest checking permissions

---

### update_state(type, modifications)

**Purpose:** Load, modify, validate, and save state atomically.

**Parameters:**
- `type`: One of `story`, `character`, `timeline`, `style`
- `modifications`: Object with fields to update (deep merge)

**Returns:** Updated state object or null on failure

**Pattern:**

```
1. Load current state using load_state(type)
2. Deep merge modifications into current state
   - Object fields: Recursively merge
   - Array fields: Replace entirely (not append)
   - Primitive fields: Replace
3. Validate merged result
4. Save using save_state(type, merged)
5. Return merged object
```

**Example Usage:**

```markdown
## Update Scene Progress

Mark scene ch01_s01 as drafted with word count.

1. Load state/story_state.json
2. Find scene in scene_index or add if not exists
3. Update: status = "drafted", word_count = 2500
4. Update progress.total_word_count
5. Save state/story_state.json

Result: Scene status updated
```

**Deep Merge Example:**

```markdown
## Merge Logic

Current state:
{
  "progress": {"outline": "complete", "draft": "not_started"},
  "current": {"chapter": 1, "scene": 1}
}

Modifications:
{
  "progress": {"draft": "in_progress"},
  "current": {"scene": 2}
}

Result:
{
  "progress": {"outline": "complete", "draft": "in_progress"},
  "current": {"chapter": 1, "scene": 2}
}
```

**Error Handling:**
- Load fails: Return null, do not attempt save
- Validation fails after merge: Return null, state unchanged
- Save fails: Log error, state unchanged

---

## Rollback Strategy

If validation fails AFTER a write has occurred (rare edge case):

```
1. Check git status for the state file
2. If file modified:
   a. Run: git checkout -- state/{type}_state.json
   b. Log: "Rolled back invalid state write"
3. If git unavailable:
   a. Read default state
   b. Write default to file
   c. Log: "Reset to default state (no git available)"
```

**When to Use Rollback:**
- Only if post-write validation reveals corruption
- Not for normal validation failures (those are caught pre-write)

---

## Common Operations

### Add Character

```markdown
1. Load character_state
2. Add new character to characters object:
   {
     "CharacterName": {
       "name": "Character Name",
       "role": "protagonist",
       "arc_stage": "setup",
       "emotional_state": "curious",
       "development_notes": []
     }
   }
3. Save character_state
```

### Update Scene Status

```markdown
1. Load story_state
2. Find scene in scene_index by id
3. If not found, create new entry:
   {
     "id": "ch01_s01",
     "chapter": 1,
     "scene": 1,
     "status": "planned"
   }
4. Update status and word_count
5. Recalculate progress.total_word_count
6. Save story_state
```

### Add Timeline Event

```markdown
1. Load timeline_state
2. Add event to events array:
   {
     "date": "2024-03-15",
     "description": "Character arrives at location",
     "scene_id": "ch01_s01",
     "type": "plot"
   }
3. Sort events by date
4. Save timeline_state
```

### Track Phrase Usage

```markdown
1. Load style_state
2. Check if phrase in usage_stats
3. If exists, increment count
4. If not, add with count 1
5. If count > 3, flag for variation check
6. Save style_state
```

---

## Validation Rules by Type

### story_state
- `project.title`: Non-empty string, max 200 chars
- `project.format`: Enum [chapter, diary, short_story, serial]
- `project.version`: Matches pattern X.Y
- `progress.outline`: Enum [not_started, in_progress, complete]
- `current.chapter`: Integer >= 1
- `current.scene`: Integer >= 1
- `scene_index[].id`: Matches pattern chXX_sYY
- `scene_index[].status`: Enum [planned, drafted, checked, revised, approved]

### character_state
- `characters[name].role`: Enum [protagonist, antagonist, supporting, minor]
- `characters[name].arc_stage`: Enum [setup, rising, crisis, climax, resolution]
- `relationships[].type`: Enum [ally, enemy, romantic, mentor, neutral]
- `arc_notes[name].transformation_status`: Enum [not_started, in_progress, complete]

### timeline_state
- `anchors[].date`: Valid ISO 8601 date (YYYY-MM-DD)
- `events[].date`: Valid ISO 8601 date
- `events[].time`: Matches pattern HH:MM if present
- `events[].type`: Enum [plot, milestone, background, deadline]

### style_state
- `pov`: Enum [first, second, third_limited, third_omniscient]
- `tense`: Enum [past, present]
- `voice`: Enum [clean, lyrical, minimal, ornate]
- `narrative_distance`: Enum [close, medium, far]

---

## Graceful Degradation

When state operations fail, the system should continue operating:

1. **Missing state file:** Use defaults, create file on next save
2. **Corrupted JSON:** Attempt git recovery, then use defaults
3. **Validation warning:** Log but don't block (soft validation)
4. **Validation error:** Block save but don't crash command
5. **Git unavailable:** Continue without rollback capability

**Principle:** State errors should degrade gracefully, not crash the pipeline.

---

*State Manager Skill v1.0*
*For use with Novel Engine state management*
