---
phase: 01-foundation-canon-system
plan: 02
subsystem: init-command
tags: [commands, templates, canon, git-integration, user-onboarding]

# Dependency graph
requires: [01-01]
provides:
  - /novel:init command with full validation
  - 6 self-documenting canon templates
  - .gitignore template for novel projects
  - Interactive questionnaire for guided setup
  - Symlink for command discoverability
affects: [01-03, 02-01, all-future-commands]

# Tech tracking
tech-stack:
  added: []
  patterns: [command-pattern, self-documenting-templates, graceful-error-handling]

key-files:
  created:
    - claude_src/novel/templates/premise.md
    - claude_src/novel/templates/characters.md
    - claude_src/novel/templates/world.md
    - claude_src/novel/templates/style_guide.md
    - claude_src/novel/templates/timeline.md
    - claude_src/novel/templates/constraints.md
    - claude_src/novel/templates/.gitignore
    - claude_src/novel/commands/init.md
    - .claude/commands/novel/init.md (symlink)
  modified: []

key-decisions:
  - "Self-documenting templates with [bracketed placeholders] and inline examples"
  - "8-step execution flow with comprehensive validation"
  - "Optional interactive mode via --interactive flag (default quiet)"
  - "Symlink from .claude/commands/novel/ to claude_src/novel/commands/"
  - "Actionable error messages with remediation options"

patterns-established:
  - "Canon templates include enforcement note at bottom"
  - "Command structure: frontmatter, role, commands, execution, examples, edge_cases"
  - "Pre-flight validation before any file operations"
  - "Graceful git degradation if git not available"

# Metrics
duration: 6min
completed: 2026-02-24
---

# Phase 01 Plan 02: /novel:init Command Summary

**/novel:init command with 6 self-documenting canon templates, .gitignore, interactive questionnaire, and comprehensive validation**

## Performance

- **Duration:** 6 minutes
- **Started:** 2026-02-24T04:46:38Z
- **Completed:** 2026-02-24T04:52:28Z
- **Tasks:** 6/6 (Task 01-02-04 integrated into 01-02-02)
- **Files created:** 9

## Accomplishments

- Created 6 canon templates (premise, characters, world, style_guide, timeline, constraints) with inline help, examples, and enforcement notes
- Built comprehensive /novel:init command with 8 execution steps
- Created .gitignore template with categorized exclusions
- Implemented interactive questionnaire with 6 questions for guided setup
- Added symlink for command discoverability at .claude/commands/novel/init.md
- Verified end-to-end functionality in clean test directory

## Task Commits

Each task was committed atomically:

1. **Task 01-02-01: Create canon templates** - `889c425` (feat)
2. **Task 01-02-02: Create /novel:init command** - `95f8a42` (feat)
3. **Task 01-02-03: Create .gitignore template** - `1df17fc` (feat)
4. **Task 01-02-04: Interactive questionnaire** - Integrated into 01-02-02
5. **Task 01-02-05: Create symlink** - `6809775` (feat)
6. **Task 01-02-06: End-to-end test** - Verified, no commit needed

## Files Created

### Canon Templates (claude_src/novel/templates/)

| File | Lines | Content |
|------|-------|---------|
| `premise.md` | 69 | Genre, format, logline, theme, story arc, tone |
| `characters.md` | 133 | Protagonist (want/need/fear/wound), antagonist, supporting |
| `world.md` | 136 | Setting, rules (physical/social/economic), institutions |
| `style_guide.md` | 150 | POV, tense, voice, forbidden phrases, motifs |
| `timeline.md` | 131 | Anchor dates, sequences, constraints, seasonal markers |
| `constraints.md` | 199 | Content boundaries, genre conventions, continuity rules |

**Total:** 818 lines of self-documenting templates

### Command (claude_src/novel/commands/)

- `init.md` - 811 lines covering:
  - YAML frontmatter with allowed-tools
  - Role definition for Init Agent
  - Command usage table
  - 8 execution steps
  - 4 examples
  - 8 edge case handlers

### Other Files

- `claude_src/novel/templates/.gitignore` - 115 lines with categorized exclusions
- `.claude/commands/novel/init.md` - Symlink to command

## Canon Template Features

Each template includes:

1. **Section Headers (##)** - Clear organization for parseability
2. **[Bracketed Placeholders]** - Show expected input format
3. **Inline Examples** - Demonstrate quality expectations
4. **Enforcement Note** - Which agent validates the rules
5. **40+ Lines** - Comprehensive inline documentation

Example enforcement notes:
- premise.md: "Enforced by: Canon-Checker Agent"
- style_guide.md: "Enforced by: Voice-Coach Agent"
- timeline.md: "Enforced by: Timeline-Keeper Agent"

## /novel:init Command Features

### Execution Steps

1. **Pre-flight Validation** - Check not already initialized, permissions, disk space
2. **Parse Arguments** - Title, format flags, interactive mode
3. **Create Directories** - canon/, state/, beats/, draft/scenes/, draft/chapters/
4. **Copy State Files** - With title and timestamp updates
5. **Copy Canon Templates** - All 6 templates to canon/
6. **Interactive Questionnaire** - 6 questions if --interactive flag
7. **Git Integration** - Initialize repo, create .gitignore, initial commit
8. **Success Message** - Clear next steps for user

### Supported Flags

- `--diary` - Diary format with dated entries
- `--short` - Short story format
- `--serial` - Web serial format
- `--interactive` - Guided questionnaire mode

### Error Handling

All errors are actionable with remediation steps:
- Already initialized: Suggests /novel:status or delete
- No permissions: Lists permission commands
- Invalid format: Shows valid options with examples
- Title too long: Shows character count and limit
- Git unavailable: Warns but continues

## End-to-End Test Results

Tested in /tmp/novel-test/:

| Check | Result |
|-------|--------|
| Directory structure created | PASS |
| 4 state files created | PASS |
| 6 canon files created | PASS |
| All JSON files valid | PASS |
| Git initialized | PASS |
| Initial commit created | PASS |
| Re-init prevented with error | PASS |
| Error message is actionable | PASS |

## Decisions Made

1. **Self-documenting templates** - No external docs needed
2. **Default quiet mode** - Interactive mode via flag, not default
3. **Symlink over copy** - Single source of truth for command
4. **8-step execution** - Comprehensive validation at each step
5. **Graceful git degradation** - Works without git installed

## Deviations from Plan

**Task 01-02-04 merged into 01-02-02:** The interactive questionnaire logic was naturally part of Step 6 in the init command. Creating it separately would have required refactoring. Both are delivered in the same commit.

## Issues Encountered

None - plan executed as written.

## User Experience

- First-time user can run `/novel:init` in <5 seconds
- Templates are self-explanatory with examples
- Error messages tell users exactly what to do
- Interactive mode guides complete beginners

## Next Phase Readiness

**Ready for Plan 01-03 (/novel:status):**
- /novel:init creates complete project structure
- All state files exist with valid schemas
- Canon templates ready for user editing
- Command pattern established for future commands

**No blockers or concerns.**

---
*Phase: 01-foundation-canon-system*
*Completed: 2026-02-24*
