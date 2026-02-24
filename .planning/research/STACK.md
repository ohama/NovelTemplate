# Stack Research: Novel Writing Engine for Claude Code

**Research Date:** 2026-02-24
**Researcher:** Project Research Agent
**Context:** Multi-agent novel writing engine integrated with Claude Code

---

## Executive Summary

The novel writing engine is a **file-based, CLI-native tool** that runs entirely within Claude Code's skill system. The stack prioritizes **zero external dependencies**, **git-native workflows**, and **pure text processing**. No databases, no web servers, no external APIs beyond Claude itself.

**Core Philosophy:** Plain text files + JSON state + Claude Code tools = Complete novel writing system.

---

## Recommended Stack

### 1. Core Runtime

**Claude Code Skill System**
- **Version:** Current Claude Code CLI (2025+)
- **Components:**
  - `.claude/commands/novel/*.md` - User-facing commands (`/novel:init`, `/novel:write`, etc.)
  - `.claude/agents/novel-*.md` - Specialized AI agents (10+ agents)
  - `.claude/skills/novel/*.md` - Reusable methodologies
- **Why:** Native integration, no installation needed, version controlled with project

**Node.js (Optional Hooks Only)**
- **Version:** 18.x LTS or 20.x LTS
- **Use Case:** ONLY for pre-commit hooks or automation scripts (e.g., state validation)
- **Why NOT Python:** Claude Code's existing hooks use Node.js; consistency matters
- **Installation:** Detected at runtime, gracefully degraded if missing

### 2. State Management

**JSON Files**
- **Format:** Strict JSON Schema validation
- **Files:**
  - `state/story_state.json` - Chapter/scene progress, plot threads
  - `state/character_state.json` - Character arcs, relationships, voice notes
  - `state/timeline_state.json` - Chronological events, date tracking
  - `state/style_state.json` - POV, tense, forbidden phrases
  - `state/diary_state.json` - Diary-specific: dates, weather, mood tracking
- **Schema Library:** JSON Schema Draft 2020-12
- **Validation:** Inline validation via Claude Code's Read/Write tools + optional Node.js hook
- **Why JSON over YAML:** Strict parsing, schema validation, better tooling support

**Canon System (Markdown)**
- **Format:** Structured markdown with frontmatter
- **Files:**
  - `canon/premise.md` - Core story concept
  - `canon/world.md` - Setting, rules, constraints
  - `canon/characters.md` - Character sheets
  - `canon/style_guide.md` - Narrative voice, tone, POV
  - `canon/timeline.md` - Master timeline
  - `canon/constraints.md` - Content guidelines, forbidden topics
- **Why Markdown:** Human-readable, git-diffable, Claude-native

### 3. Document Processing

**Markdown (Primary Format)**
- **Spec:** CommonMark with GitHub Flavored Markdown extensions
- **Structure:**
  - Scenes: `draft/scenes/ch{NN}_s{MM}.md`
  - Chapters: `draft/chapters/ch{NN}.md`
  - Diary entries: `draft/diary/YYYY-MM-DD.md`
- **Why:** Universal, version-controlled, Claude-optimized

**EPUB Generation (Secondary Output)**
- **Library:** `pandoc` (CLI tool)
- **Version:** 3.x+
- **Workflow:**
  ```bash
  pandoc draft/compiled.md -o output.epub --metadata title="Novel Title"
  ```
- **Rationale:** Industry-standard tool, no custom code needed
- **Alternative Considered:** Custom JS EPUB builder → Rejected (complexity vs. value)

### 4. Multi-Agent Orchestration

**Claude Code Agent System**
- **Agent Definition:** Markdown files with YAML frontmatter
- **Invocation:** Task tool spawning (parallel or sequential)
- **State Passing:** JSON files + explicit file references
- **Agent Roster (10 agents):**
  1. `novel-plot-planner` - High-level structure
  2. `novel-beat-planner` - Scene-level beats
  3. `novel-scene-writer` - Prose generation
  4. `novel-voice-coach` - Style consistency
  5. `novel-canon-checker` - Continuity validation
  6. `novel-timeline-keeper` - Chronology enforcement
  7. `novel-pacing-analyzer` - Story rhythm
  8. `novel-tension-monitor` - Conflict tracking
  9. `novel-editor` - Revision agent
  10. `novel-quality-gate` - Final approval

**Why NOT External Tools:**
- ❌ LangChain - Overkill, external dependency
- ❌ AutoGen - Not file-native
- ❌ CrewAI - Requires Python environment

### 5. Version Control Integration

**Git (Native)**
- **Commits:** Atomic per-scene or per-command
- **Branches:** Optional feature branches for experimental rewrites
- **Tags:** Version milestones (v0.1-draft, v1.0-published)
- **Hooks:** `.claude/hooks/novel-state-check.js` (validates JSON before commit)

**Diff-Friendly Formats**
- **Rule:** One sentence per line in draft markdown
- **Why:** Git diffs show sentence-level changes, not paragraph-level

### 6. Diary Format Support

**Date Management**
- **Format:** ISO 8601 (`YYYY-MM-DD`)
- **Storage:** `state/diary_state.json`
  ```json
  {
    "entries": [
      {
        "date": "2025-03-15",
        "season": "spring",
        "weather": "cloudy",
        "mood": "anxious",
        "scene_file": "draft/diary/2025-03-15.md"
      }
    ]
  }
  ```
- **Season Tracking:** Auto-calculated from date + hemisphere config
- **Why:** Structured data for timeline validation, mood arc analysis

### 7. Command Structure

**Workflow Commands (`.claude/commands/novel/`)**
- `00_init.md` - Project setup, canon scaffolding
- `10_outline.md` - Story structure design
- `20_beats.md` - Scene beat planning
- `30_write.md` - Prose generation
- `40_check.md` - Canon/timeline/style validation
- `50_rewrite.md` - Revision workflow
- `60_status.md` - Progress dashboard
- `70_export.md` - EPUB compilation

**User-Facing Commands:**
- `/novel:init [title]` → Initializes project
- `/novel:write [scene-id]` → Writes a scene
- `/novel:check` → Runs all validators
- `/novel:status` → Shows progress + next action
- `/novel:export` → Generates EPUB

### 8. Testing Strategy

**No Unit Tests**
- **Why:** AI agent outputs are non-deterministic; traditional unit tests don't apply

**Validation Testing**
- **JSON Schema Validation:** All state files validated against schemas
- **Canon Consistency Checks:** Agent-based validation (novel-canon-checker)
- **Timeline Integrity:** Agent-based validation (novel-timeline-keeper)

**Human-in-Loop Verification**
- **Checkpoints:** After each major workflow step (outline → beats → draft)
- **Quality Gate:** novel-quality-gate agent flags issues for human review

### 9. Development Location

**`claude_src/` Directory Structure**
```
claude_src/
├── novel/                    # Novel engine core
│   ├── agents/               # Agent definitions
│   ├── commands/             # Workflow commands
│   ├── skills/               # Reusable methodologies
│   ├── schemas/              # JSON schemas for state files
│   └── templates/            # Scaffolding templates
└── README.md                 # Installation & usage
```

**Integration with `.claude/`**
- Symlink or copy from `claude_src/novel/` to `.claude/` during setup
- `/novel:init` handles this automatically

---

## Rationale

### Why File-Based State (Not SQLite)?

**Pros of JSON files:**
- ✅ Git-native versioning (every state change is tracked)
- ✅ Human-readable diffs
- ✅ No database dependencies
- ✅ Trivial backup/restore (just copy files)
- ✅ Claude Code Read/Write tools work natively

**Cons mitigated:**
- ❌ "Not queryable" → We don't need complex queries; linear scans work fine
- ❌ "No ACID" → Single-user workflow, no concurrency

### Why Markdown Over Other Formats?

**Alternatives Considered:**
- **LaTeX:** Too complex, poor Claude support
- **reStructuredText:** Less common, weaker ecosystem
- **AsciiDoc:** Good for technical docs, overkill for fiction
- **Plain Text:** No structure, harder to parse

**Why Markdown won:**
- Claude's training data is Markdown-heavy (best generation quality)
- Universal tooling support
- GitHub/GitLab rendering
- Pandoc conversion to EPUB/PDF/HTML

### Why Pandoc Over Custom EPUB Builder?

**Pandoc pros:**
- ✅ Battle-tested, used by academia/publishing
- ✅ Handles metadata, TOC, CSS automatically
- ✅ One CLI command vs. 500+ lines of custom code

**Custom builder cons:**
- ❌ EPUB spec is complex (ZIP + XHTML + NCX/OPF)
- ❌ Ongoing maintenance burden
- ❌ Edge cases (footnotes, images, special characters)

### Why No Python?

**Context:** Claude Code's existing hooks use Node.js

**Consistency argument:**
- If we introduce Python, users need TWO runtimes
- Node.js is already required for GSD hooks
- JavaScript JSON parsing is native and fast

**Exception:** If user explicitly prefers Python, we can adapt. But default is Node.js.

### Why 10 Agents Instead of 1 Monolithic Agent?

**Separation of Concerns:**
- Each agent has ONE job (scene writing vs. timeline checking)
- Smaller contexts = better Claude performance
- Parallel execution possible (e.g., canon_checker + timeline_keeper run simultaneously)

**GSD Pattern:**
- Follows established GSD multi-agent architecture
- Users already familiar with `.claude/agents/` structure

---

## Alternatives Considered

### State Management

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **JSON files** (chosen) | Git-native, human-readable, no deps | No ACID, manual schema validation | ✅ CHOSEN |
| SQLite | Queryable, ACID | Binary (bad git diffs), requires runtime | ❌ Rejected |
| YAML | More readable than JSON | Parsing ambiguities (tabs vs. spaces) | ❌ Rejected |
| TOML | Good for config | Not as common in AI workflows | ❌ Rejected |

### Document Format

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **Markdown** (chosen) | Claude-optimized, universal tooling | Limited semantic structure | ✅ CHOSEN |
| LaTeX | Professional typesetting | Complex syntax, poor Claude support | ❌ Rejected |
| Org-mode | Powerful outlining | Emacs-centric, niche | ❌ Rejected |
| DocBook XML | Semantic markup | Too verbose, dying ecosystem | ❌ Rejected |

### EPUB Generation

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **Pandoc** (chosen) | Industry standard, one command | External dependency | ✅ CHOSEN |
| epub.js (Node.js) | Programmatic control | Complex API, maintenance burden | ❌ Rejected |
| Python ebooklib | Good Python integration | Requires Python runtime | ❌ Rejected |
| Manual ZIP/XHTML | No dependencies | 500+ lines of error-prone code | ❌ Rejected |

### Agent Orchestration

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **Claude Code native** (chosen) | Zero deps, built-in parallelism | No advanced features (retry, fallback) | ✅ CHOSEN |
| LangChain | Rich ecosystem, many integrations | Heavy dependency, version churn | ❌ Rejected |
| AutoGen | Multi-agent framework | Requires Python, not file-native | ❌ Rejected |
| CrewAI | Agent collaboration | External service, costs | ❌ Rejected |

---

## Anti-Recommendations

### DO NOT Use

#### 1. External Databases (PostgreSQL, MongoDB, etc.)
**Why:**
- Breaks file-based simplicity
- Requires running services
- Not git-trackable
- Overkill for single-user workflow

**When it WOULD make sense:** Multi-user web app (not our use case)

#### 2. Web Frameworks (Express, FastAPI, etc.)
**Why:**
- Novel engine is CLI-only
- No web UI requirement
- Adds complexity, security surface

**When it WOULD make sense:** If building a hosted service (explicitly out of scope)

#### 3. Heavy AI Frameworks (LangChain, LlamaIndex, etc.)
**Why:**
- Claude Code already provides agent primitives
- Unnecessary abstraction layer
- Version instability

**When it WOULD make sense:** Multi-LLM support, RAG pipelines (not needed)

#### 4. Complex Build Systems (Webpack, Vite, etc.)
**Why:**
- No bundling needed (pure text files)
- No transpilation needed

**When it WOULD make sense:** Frontend JavaScript apps (not applicable)

#### 5. Python Runtime for Core Logic
**Why:**
- Claude Code hooks are Node.js
- Introducing second runtime confuses users
- JSON parsing equally good in JS

**Exception:** Pandoc (written in Haskell) is OK because it's a well-known external tool

#### 6. Custom EPUB Generators
**Why:**
- EPUB spec is complex (ZIP + XHTML + metadata)
- Pandoc solves this in one command
- Maintenance nightmare

**When it WOULD make sense:** If Pandoc didn't exist (but it does)

#### 7. Real-Time Collaboration Tools (CRDT, Yjs, etc.)
**Why:**
- Explicitly single-user workflow
- Git is the collaboration layer (if needed)

**When it WOULD make sense:** Google Docs-style co-writing (not our model)

#### 8. Proprietary File Formats (Scrivener, Ulysses, etc.)
**Why:**
- Lock-in risk
- Not Claude-readable
- No git diffs

**When it WOULD make sense:** If using those apps (we're not)

#### 9. Vector Databases (Pinecone, Weaviate, etc.)
**Why:**
- No RAG use case (canon is <10 files)
- Overkill for small context windows

**When it WOULD make sense:** 1000+ chapter novels with complex lore (edge case)

#### 10. GraphQL APIs
**Why:**
- No API needed (file-based)
- Unnecessary abstraction

**When it WOULD make sense:** Multi-client architecture (not applicable)

---

## Technology Matrix

### Required (Hard Dependencies)

| Technology | Version | Purpose | Installation |
|------------|---------|---------|--------------|
| Claude Code CLI | Latest (2025+) | Runtime environment | Pre-installed by user |
| Git | 2.x+ | Version control | Assumed present |

### Recommended (Soft Dependencies)

| Technology | Version | Purpose | Fallback |
|------------|---------|---------|----------|
| Pandoc | 3.x+ | EPUB generation | Manual export warning |
| Node.js | 18.x LTS / 20.x LTS | Validation hooks | Hooks disabled gracefully |

### Explicitly Avoided

| Technology | Reason |
|------------|--------|
| Python runtime | Inconsistent with Node.js hooks |
| SQLite / PostgreSQL | File-based state preferred |
| Redis | No caching layer needed |
| Docker | Unnecessary containerization |
| npm packages (except dev tools) | Minimize dependencies |

---

## File Format Specifications

### State JSON Schema Example

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/story_state.schema.json",
  "title": "Story State",
  "type": "object",
  "required": ["project", "progress", "current"],
  "properties": {
    "project": {
      "type": "object",
      "required": ["title", "version"],
      "properties": {
        "title": {"type": "string"},
        "version": {"type": "string", "pattern": "^\\d+\\.\\d+$"}
      }
    },
    "progress": {
      "type": "object",
      "properties": {
        "outline": {"type": "string", "enum": ["not_started", "in_progress", "complete"]},
        "beat_plan": {"type": "string", "enum": ["not_started", "in_progress", "complete"]},
        "draft": {"type": "string", "enum": ["not_started", "in_progress", "complete"]}
      }
    },
    "current": {
      "type": "object",
      "required": ["chapter", "scene"],
      "properties": {
        "chapter": {"type": "integer", "minimum": 1},
        "scene": {"type": "integer", "minimum": 1}
      }
    },
    "open_threads": {"type": "array", "items": {"type": "string"}},
    "resolved_threads": {"type": "array", "items": {"type": "string"}},
    "scene_index": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "chapter", "scene", "status"],
        "properties": {
          "id": {"type": "string", "pattern": "^ch\\d{2}_s\\d{2}$"},
          "chapter": {"type": "integer"},
          "scene": {"type": "integer"},
          "status": {"type": "string", "enum": ["planned", "drafted", "revised", "approved"]},
          "word_count": {"type": "integer", "minimum": 0}
        }
      }
    }
  }
}
```

### Scene Markdown Template

```markdown
---
scene_id: ch01_s01
chapter: 1
scene: 1
pov: "Character Name"
location: "Setting"
date: "2025-03-15"
time: "morning"
status: "drafted"
word_count: 1200
---

# Scene Goal
- What does the POV character want?

# Conflict
- What stands in their way?

# Outcome
- How does the scene end?

---

[Scene prose goes here, one sentence per line for git-friendly diffs.]

This is the opening line.
Character walks into the room.
They notice something unusual.

<!-- END SCENE -->
```

---

## Deployment Model

### Installation (One-Time Setup)

```bash
# User clones or copies claude_src/ to their project
cd my-novel-project

# Initialize novel engine (creates symlinks to .claude/)
claude-code "/novel:init 'My Novel Title'"
```

**What happens:**
1. Copies agent definitions to `.claude/agents/novel-*.md`
2. Copies commands to `.claude/commands/novel/`
3. Creates `canon/`, `state/`, `draft/` directories
4. Initializes state JSON files
5. Creates `.gitignore` for temporary files

### Runtime (Zero Services)

- No daemons to start
- No servers to run
- No background processes
- Just Claude Code CLI + text files

### Updates

```bash
# Pull latest claude_src/ changes
git pull origin main

# Re-run init to update agents/commands
claude-code "/novel:init --update"
```

---

## Performance Considerations

### File I/O
- **Typical state file size:** 5-50 KB
- **Read/parse time:** <10ms (negligible)
- **No optimization needed** for single-user use case

### Agent Spawning
- **Parallel agents:** Up to 4 simultaneous (claude_checker, timeline_keeper, voice_coach, pacing_analyzer)
- **Token usage:** Each agent gets own context window
- **Cost optimization:** Use Sonnet for most agents, Haiku for simple checks

### Git Performance
- **Commit frequency:** Once per scene (10-30 commits per session)
- **Repo size growth:** ~1 MB per 10,000 words (text compresses well)
- **No concerns** unless novel exceeds 1M words (rare)

---

## Security Considerations

### No Sensitive Data
- All files are plain text (Markdown, JSON)
- No passwords, API keys, or secrets
- Safe to commit to public repos (if desired)

### Content Safety
- Agent instructions include content policy enforcement
- `canon/constraints.md` defines forbidden topics
- Quality gate agent checks for policy violations

### Git Hooks (Optional)
```javascript
// .claude/hooks/novel-state-check.js
// Validates JSON schema before commit
const fs = require('fs');
const Ajv = require('ajv'); // If user has Node.js installed

// Validate state/*.json against schemas
// Exit 1 if validation fails
```

---

## Future-Proofing

### Extensibility Points

1. **New Formats:** Add agents for screenplay, graphic novel scripts
2. **Export Targets:** Pandoc supports PDF, HTML, DOCX (same workflow)
3. **Advanced Timeline:** Replace JSON with directed acyclic graph (if needed)
4. **AI Model Upgrades:** Agent definitions are model-agnostic (just change prompts)

### Migration Path

**From:** Basic Markdown + Claude Code
**To:** Novel Engine
- User copies their existing draft into `draft/` directory
- Run `/novel:init --import` to generate state files retroactively

**From:** Novel Engine
**To:** Other Tools
- Markdown files are portable (import into Scrivener, Google Docs, etc.)
- EPUB output is industry-standard

---

## Comparative Analysis: Novel Writing Tools

| Tool | Format | Versioning | AI Integration | Claude Code Native | Cost |
|------|--------|------------|----------------|-------------------|------|
| **Novel Engine** (this) | Markdown | Git | Full (10 agents) | ✅ Yes | Free |
| Scrivener | Proprietary | Manual snapshots | None | ❌ No | $50 |
| Ulysses | Markdown (locked) | iCloud sync | None | ❌ No | $6/mo |
| Google Docs | DOCX export | Version history | Plugin only | ❌ No | Free |
| Obsidian | Markdown | Git (plugin) | Plugin only | ❌ No | Free |
| NovelAI | Web-only | None | Basic | ❌ No | $10/mo |

**Unique Value Proposition:**
- Only tool with **native Claude Code multi-agent** support
- Only tool with **git-native version control** for fiction
- Only **fully open-source, dependency-free** option

---

## Decision Log

| Decision | Date | Rationale |
|----------|------|-----------|
| Use JSON for state (not YAML) | 2026-02-24 | Strict parsing, schema validation |
| Pandoc for EPUB (not custom) | 2026-02-24 | Industry standard, one command |
| Node.js for hooks (not Python) | 2026-02-24 | Consistency with Claude Code ecosystem |
| 10 specialized agents (not monolith) | 2026-02-24 | Separation of concerns, parallelism |
| File-based state (not SQLite) | 2026-02-24 | Git-native, human-readable |
| Markdown (not LaTeX) | 2026-02-24 | Claude-optimized, universal tooling |

---

## References

### Industry Standards (2025)

- **Markdown Spec:** CommonMark 0.30 (https://commonmark.org/)
- **JSON Schema:** Draft 2020-12 (https://json-schema.org/)
- **EPUB Spec:** EPUB 3.3 (https://www.w3.org/TR/epub-33/)
- **ISO 8601 Dates:** Standard for date/time representation

### Claude Code Documentation

- `.claude/docs/structure.md` - Directory layout
- `.claude/docs/skills.md` - Skill system reference
- `.claude/docs/agents.md` - Agent patterns
- `.claude/get-shit-done/references/git-integration.md` - Atomic commits

### Existing Reference Implementation

- `/home/shoh/vibe-coding/Run42.195/novel-engine/` - Prototype structure
- Good: Canon system, agent separation
- Needs: Diary support, versioning, command integration

---

## Next Steps for Implementation

1. **Phase 1: Foundation** - Setup `claude_src/` structure, base schemas
2. **Phase 2: Core Agents** - Implement 10 agents with skill references
3. **Phase 3: Commands** - Create `/novel:*` workflow commands
4. **Phase 4: Diary Support** - Add date/weather/mood tracking
5. **Phase 5: EPUB Export** - Integrate Pandoc pipeline
6. **Phase 6: Testing** - Human-in-loop validation with example novel

**Feeds into:** ROADMAP.md creation (next research phase)

---

*End of Stack Research*
