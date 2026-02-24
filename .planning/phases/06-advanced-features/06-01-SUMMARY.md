---
phase: "06"
plan: "01"
name: "Version Management"
subsystem: "revision"
tags: ["version-control", "snapshots", "diff", "rollback"]

dependency_graph:
  requires:
    - "05-01: Editor and Quality Gate"
    - "05-02: Pipeline Integration"
  provides:
    - "Snapshot creation for draft recovery"
    - "Word-level version comparison"
    - "Scene rollback with safety backups"
  affects:
    - "06-02: EPUB export (will snapshot before export)"
    - "06-03: /novel:publish (will trigger pre_publish snapshot)"

tech_stack:
  added: []
  patterns:
    - "File-based snapshots with JSON manifests"
    - "git diff --word-diff for prose comparison"
    - "Backup-before-restore safety pattern"

key_files:
  created:
    - "claude_src/novel/skills/version-manager.md"
    - "claude_src/novel/templates/directories/draft/versions/README.md"
  modified:
    - "claude_src/novel/schemas/story_state.schema.json"
    - "claude_src/novel/utils/state-manager.md"

decisions:
  - id: "timestamp-format"
    decision: "Use YYYY-MM-DD_HH-MM-SS for snapshot directories"
    rationale: "Filesystem-safe, sorts chronologically, readable"
  - id: "manifest-location"
    decision: "Store manifest.json in each snapshot directory"
    rationale: "Self-contained snapshots can be moved/archived independently"
  - id: "state-summary"
    decision: "State tracks snapshot summaries, manifest has full details"
    rationale: "Keeps state file compact while preserving full snapshot metadata"

metrics:
  duration: "3.7 minutes"
  completed: "2026-02-24"
---

# Phase 6 Plan 01: Version Management Summary

File-based version management with snapshot creation, word-level diff, and safe rollback for draft recovery during revision cycles.

## What Was Built

### 1. Version Manager Skill (789 lines)

**Location:** `claude_src/novel/skills/version-manager.md`

Core operations:
- **create_snapshot(trigger, notes):** Creates timestamped snapshot with manifest.json
- **compare_versions(version_a, version_b):** Word-level diff using git diff --word-diff
- **rollback_scene(snapshot_id, scene_id):** Restores scenes with backup safety
- **list_snapshots():** Lists all available snapshots with metadata
- **delete_snapshot(snapshot_id):** Removes snapshot to free space

Manifest structure:
```json
{
  "snapshot_id": "snap_2026-02-24_14-30-00",
  "timestamp": "2026-02-24T14:30:00Z",
  "trigger": "revision_cycle",
  "scenes_included": ["ch01_s01", "ch01_s02"],
  "scenes_count": 2,
  "total_word_count": 5000,
  "source_commit": "abc1234",
  "notes": "After revision pass"
}
```

### 2. State Schema Extension (v1.2)

**Location:** `claude_src/novel/schemas/story_state.schema.json`

Added `versions` property:
```json
{
  "versions": {
    "snapshots": [{
      "snapshot_id": "snap_...",
      "timestamp": "ISO 8601",
      "trigger": "revision_cycle|manual|pre_publish",
      "scenes_count": 12
    }],
    "last_snapshot": "snap_...",
    "last_rollback": {
      "snapshot_id": "snap_...",
      "timestamp": "ISO 8601",
      "scenes_restored": ["ch01_s01"]
    }
  }
}
```

### 3. State Manager Documentation

**Location:** `claude_src/novel/utils/state-manager.md`

Added "Version Tracking" section documenting:
- Versions object structure
- How to add snapshot entries
- How to record rollback events
- Example JSON for full versions object
- Patterns for accessing version data

### 4. Directory Template

**Location:** `claude_src/novel/templates/directories/draft/versions/README.md`

Documents:
- Snapshot directory naming (YYYY-MM-DD_HH-MM-SS)
- Manifest file format
- Trigger types and when they occur
- Storage estimates and cleanup guidance

## Snapshot Triggers

| Trigger | When Created | Automatic |
|---------|--------------|-----------|
| `revision_cycle` | After /novel:check completes revision | Yes |
| `manual` | User explicitly requests | No |
| `pre_publish` | Before /novel:publish runs | Yes |

## Key Design Decisions

1. **File-based snapshots, not git branches**
   - Simpler for non-git users
   - Self-contained directories can be archived
   - git used only for word-level diff, not storage

2. **Backup-before-restore pattern**
   - Rollback creates .bak files before overwriting
   - Prevents accidental data loss
   - Backups can be cleaned up later

3. **State tracks summaries only**
   - Full manifest lives in snapshot directory
   - Keeps story_state.json compact
   - Allows snapshot directories to be self-describing

## Commits

| Hash | Description |
|------|-------------|
| c2c13dc | Create version-manager skill |
| f2f627d | Extend state schema for version tracking |
| 7afa878 | Create directory template for versions |

## Deviations from Plan

None - plan executed exactly as written.

## Next Phase Readiness

Ready for Plan 06-02 (EPUB Export):
- Version management infrastructure in place
- pre_publish snapshot trigger ready for /novel:publish
- Schema extended and documented

## Success Criteria Met

- [x] version-manager.md skill provides complete snapshot/diff/rollback operations
- [x] story_state.schema.json extended with versions tracking (v1.2)
- [x] state-manager.md documents version tracking fields
- [x] Directory template created for draft/versions/
- [x] All files follow existing project patterns and conventions
