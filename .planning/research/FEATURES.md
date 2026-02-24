# Features Research: Novel Writing Engine

## Executive Summary

Based on analysis of existing novel writing software (Scrivener, Atticus, yWriter, Sudowrite, NovelCrafter) and the current novel-engine implementation, this document categorizes features into table stakes, differentiators, and anti-features for a Claude Code-based multi-agent novel writing engine.

**Key Finding**: The market is saturated with complex GUI tools. A CLI-based, AI-powered engine with strong consistency guarantees and version control is a clear differentiator.

---

## Table Stakes (Must-Have Features)

These features are essential - users will abandon the tool if missing:

### 1. Core Writing & Organization

**Scene/Chapter Management**
- Hierarchical organization (chapters contain scenes)
- Ability to write, edit, and rearrange scenes/chapters
- Clear scene boundaries with metadata (POV, time, location)
- Support for multiple draft formats (chapter-based, scene-based, diary entries)

**Canon System (Story Bible)**
- Character profiles with consistency tracking
- World-building documentation
- Timeline/chronology management
- Style guide enforcement
- Premise and thematic constraints

**State Persistence**
- JSON-based state files for progress tracking
- Character state (arcs, relationships, voice notes)
- Timeline state (events, ordering constraints)
- Story state (chapter/scene status, open threads)
- Style state (POV, tense, forbidden phrases)

### 2. Consistency Enforcement

**Character Consistency**
- Track character attributes, relationships, and arcs
- Voice consistency checking across scenes
- Flag contradictions in character behavior/knowledge

**Timeline Consistency**
- Detect temporal contradictions
- Track event ordering
- Validate date/time references

**Canon Validation**
- Check drafts against established world rules
- Verify style guide compliance
- Flag violations with severity levels (blocker/warning)

### 3. Basic Workflow Support

**Multi-Agent Pipeline**
- Plot planning → beat planning → scene writing → review → revision
- Clear separation of concerns (planner, writer, checker, editor roles)
- Sequential execution with state updates between stages

**Output Management**
- Markdown file output (industry standard for portability)
- Organized directory structure (canon/, state/, draft/, beats/)
- Clear scene format with headers and metadata

### 4. Minimal UX Requirements

**CLI Integration**
- Simple command structure (`/novel:init`, `/novel:write`, `/novel:check`, `/novel:status`)
- Clear feedback on progress and issues
- Non-blocking workflow (no extensive menus or navigation)

---

## Differentiators (Competitive Advantages)

These features set the engine apart from existing tools:

### 1. AI-Native Multi-Agent Architecture

**Specialized Agent Roles** (UNIQUE TO CLAUDE CODE)
- 10+ specialized agents (plot_planner, beat_planner, scene_writer, canon_checker, timeline_keeper, voice_coach, pacing_analyzer, tension_monitor, editor, quality_gate)
- Each agent has narrow, well-defined responsibilities
- Agents collaborate through shared state and sequential pipeline
- Quality gates prevent bad content from advancing

**Intelligent Consistency Checking**
- Automated canon violation detection (vs manual checking in Scrivener)
- AI-powered voice coaching for character dialogue
- Timeline conflict resolution with suggestions
- Pacing and tension analysis (lacking in most tools)

### 2. Version Control Integration

**Git-Native Draft Management** (MAJOR DIFFERENTIATOR)
- Treat drafts as code: commit, branch, diff, merge
- Snapshot entire story state (not just text like Scrivener)
- Compare character arcs across versions
- Rollback to previous story states with full context
- History of canon changes tracked explicitly

**Revision Tracking**
- Explicit version markers (v0.1 → v0.2 → v1.0)
- Diff-friendly JSON state files
- Branch per revision (draft-1, draft-2, final-edit)

### 3. Diary/Journal Format Support

**Date-Driven Writing** (UNIQUE FEATURE)
- First-class support for diary entry format
- Automatic date/time tracking per entry
- Seasonal and weather progression tracking
- Emotional arc mapping over time
- Growth milestones at temporal intervals

**Timeline-First Design**
- Natural chronological ordering for diary novels
- "On this day" references across entries
- Time-gap pacing analysis
- Seasonal consistency enforcement

### 4. Claude Code Native Integration

**Skills-Based Commands**
- No separate app to learn - works in Claude Code sessions
- Context-aware suggestions based on conversation
- Inline editing and refinement with AI assistance
- Natural language interaction with the engine

**State-Aware Orchestration**
- Engine knows where you are in the writing process
- Automatically invokes appropriate agents for the task
- Maintains conversation context across sessions
- Integrates with existing Claude Code workflows

### 5. Programmatic Canon Enforcement

**Style as Code**
- Style guide as enforceable rules (not guidelines)
- Forbidden phrases list with automatic detection
- POV/tense consistency validation
- Diction level monitoring (lyrical vs plain)

**Constraint Satisfaction**
- Plot constraints as logical rules
- Theme enforcement through structural analysis
- Character arc validation against defined trajectories

---

## Anti-Features (Deliberately Avoid)

Things competitors do that we should NOT build:

### 1. Complex GUI/Visual Tools

**Why Avoid**: Users chose Claude Code for CLI workflow; GUIs add friction
- ❌ No corkboard/visual storyboard (Scrivener's approach)
- ❌ No drag-and-drop scene rearranging
- ❌ No rich text formatting editor
- ❌ No visual timeline graphs or charts

**Instead**: Markdown files, text-based commands, simple status outputs

### 2. Publishing/Formatting Features

**Why Avoid**: Focus on writing, not final output; other tools do this better
- ❌ No built-in EPUB generation (use Atticus, Reedsy, or Pandoc)
- ❌ No print layout/typesetting
- ❌ No custom fonts, margins, or page design
- ❌ No cover design tools

**Instead**: Export clean Markdown; users handle formatting elsewhere

### 3. Kitchen Sink Features

**Why Avoid**: Bloat kills tools; common complaint about Scrivener
- ❌ No image management/galleries
- ❌ No research document storage beyond text
- ❌ No built-in thesaurus/dictionary
- ❌ No word count goals/targets (distracting metrics)
- ❌ No social features/collaboration (single-user focus)
- ❌ No cloud sync (git handles this)

**Instead**: One tool, one job - write consistent novels

### 4. Forcing a Specific Writing Method

**Why Avoid**: Writers hate being forced into someone else's system
- ❌ No mandatory outlining (support pantsers)
- ❌ No rigid story structure enforcement (hero's journey, three-act, etc.)
- ❌ No required character questionnaires
- ❌ No opinionated template systems

**Instead**: Flexible pipeline - skip agents you don't need

### 5. Performance Killers

**Why Avoid**: Common complaint about Word/Google Docs on large projects
- ❌ No single giant document approach
- ❌ No rich media embeds that slow parsing
- ❌ No real-time collaborative editing
- ❌ No auto-save every keystroke (git commits are deliberate)

**Instead**: Fast file-based operations, explicit state updates

### 6. Platform Lock-In

**Why Avoid**: Writers want portability and longevity
- ❌ No proprietary file formats (Scrivener .scriv)
- ❌ No platform-specific features (Mac-only like Vellum)
- ❌ No vendor lock-in for basic functionality
- ❌ No subscription required for core features

**Instead**: Plain text (Markdown), JSON state, open formats

### 7. AI Overreach

**Why Avoid**: Writers want tools, not replacement; common AI writing tool complaint
- ❌ No "write entire book" button
- ❌ No automatic scene generation without human review
- ❌ No AI making final creative decisions
- ❌ No opaque AI suggestions without explanation
- ❌ No hiding the writing process from the author

**Instead**: AI as collaborator - suggest, check, refine, not replace

---

## Feature Dependencies

### Dependency Graph

```
Level 0 (Foundation):
├─ Canon System (premise, world, characters, style, timeline, constraints)
├─ State Management (JSON files for story/character/timeline/style state)
└─ File Organization (canon/, state/, draft/, beats/ directories)

Level 1 (Core Pipeline):
├─ Plot Planner (depends on: canon system)
├─ Beat Planner (depends on: plot planner output, canon system)
└─ Scene Writer (depends on: beat planner specs, style guide)

Level 2 (Quality Checking):
├─ Canon Checker (depends on: draft scenes, canon system)
├─ Timeline Keeper (depends on: draft scenes, timeline state)
├─ Voice Coach (depends on: draft scenes, character state)
├─ Pacing Analyzer (depends on: draft scenes, story state)
└─ Tension Monitor (depends on: draft scenes, beat plan)

Level 3 (Refinement):
├─ Editor (depends on: draft scenes, all checker outputs)
└─ Quality Gate (depends on: edited scenes, all checker outputs, state)

Level 4 (Advanced Features):
├─ Version Control (depends on: state management, git integration)
├─ Diary Format Support (depends on: timeline keeper, state management)
└─ Multi-Format Output (depends on: completed drafts, style state)
```

### Critical Path for MVP

**Phase 1: Foundation (Ship First)**
1. Canon system (files + JSON schema)
2. State management (read/write JSON state)
3. File organization structure
4. `/novel:init` command (bootstrap project)
5. `/novel:status` command (show current state)

**Phase 2: Basic Pipeline (Ship Second)**
6. Plot Planner agent (outline generation)
7. Beat Planner agent (scene specs)
8. Scene Writer agent (draft generation)
9. `/novel:write` command (invoke pipeline)

**Phase 3: Consistency Layer (Ship Third)**
10. Canon Checker agent
11. Timeline Keeper agent
12. Voice Coach agent
13. `/novel:check` command (run validations)

**Phase 4: Refinement (Ship Fourth)**
14. Editor agent (apply fixes)
15. Quality Gate agent (approve/reject)
16. Revision loop (iterate until approved)

**Phase 5: Advanced Features (Ship Last)**
17. Version control integration (git commits per draft)
18. Diary format support (date/time tracking)
19. Multi-format support (chapter/scene/diary modes)
20. Pacing/Tension analysis agents

### Sequential Dependencies

**Must Build Before:**
- State Management → All Agents (agents read/write state)
- Canon System → All Agents (agents enforce canon)
- Plot Planner → Beat Planner (beats derive from outline)
- Beat Planner → Scene Writer (scenes follow beat specs)
- Scene Writer → All Checkers (need draft to check)
- All Checkers → Editor (editor needs issues to fix)
- Editor → Quality Gate (gate reviews edited draft)

**Can Build in Parallel:**
- Canon Checker + Timeline Keeper + Voice Coach (independent checks)
- Pacing Analyzer + Tension Monitor (both analyze completed scenes)
- All command handlers (init, write, check, status) after foundation

---

## Competitive Feature Matrix

| Feature | Scrivener | yWriter | Sudowrite | NovelCrafter | Novel Engine (Ours) |
|---------|-----------|---------|-----------|--------------|---------------------|
| **Table Stakes** |||||
| Scene/Chapter Org | ✅ (Binder) | ✅ (Scenes) | ❌ | ✅ (Codex) | ✅ (Files) |
| Character Tracking | ✅ (Metadata) | ✅ (Database) | ✅ (Story Bible) | ✅ (Codex) | ✅ (JSON State) |
| Timeline Management | ⚠️ (Manual) | ✅ (Built-in) | ⚠️ (Manual) | ⚠️ (Manual) | ✅ (Auto-checked) |
| Style Guide | ⚠️ (Notes) | ❌ | ❌ | ⚠️ (Prompts) | ✅ (Enforced) |
| Draft Output | ✅ (Compile) | ✅ (Export) | ✅ (Scenes) | ✅ (Manuscript) | ✅ (Markdown) |
| **Differentiators** |||||
| AI Agents | ❌ | ❌ | ✅ (Story Engine) | ✅ (AI Models) | ✅ (Multi-Agent) |
| Consistency Checking | ⚠️ (Manual) | ⚠️ (Manual) | ✅ (Story Bible) | ✅ (Codex) | ✅ (Automated) |
| Version Control | ⚠️ (Snapshots) | ❌ | ❌ | ⚠️ (Versions) | ✅ (Git Native) |
| Diary Format | ❌ | ❌ | ❌ | ❌ | ✅ (First-class) |
| CLI Integration | ❌ | ❌ | ❌ | ❌ | ✅ (Native) |
| State as Code | ❌ | ⚠️ (Database) | ❌ | ⚠️ (JSON) | ✅ (JSON + Git) |
| Multi-Agent Pipeline | ❌ | ❌ | ⚠️ (Single) | ⚠️ (Single) | ✅ (10+ Agents) |
| **Anti-Features** |||||
| Visual UI | ✅ (Has) | ✅ (Has) | ✅ (Has) | ✅ (Has) | ❌ (Avoid) |
| Publishing Tools | ✅ (Compile) | ✅ (RTF) | ❌ | ⚠️ (Basic) | ❌ (Avoid) |
| Cloud Sync | ⚠️ (iOS) | ❌ | ✅ (Has) | ✅ (Has) | ❌ (Use Git) |
| Forced Methodology | ❌ (Flexible) | ⚠️ (Scene-based) | ⚠️ (Story Engine) | ⚠️ (Codex) | ❌ (Flexible) |
| Proprietary Format | ✅ (.scriv) | ⚠️ (SQLite) | ⚠️ (Cloud) | ⚠️ (Cloud) | ❌ (Markdown/JSON) |

**Legend**: ✅ = Full Support | ⚠️ = Partial/Manual | ❌ = Not Supported/Avoided

---

## Research Sources

### Novel Writing Software Analysis
- [12 Best Novel Writing Software Tools for Authors in 2026](https://www.shyeditor.com/blog/post/novel-writing-software)
- [Best Writing Apps for Authors (2026) — 26 Tools Compared | NowNovel](https://nownovel.com/best-writing-apps/)
- [Novel Planning Software: Best Tools & Tips for Authors in 2026](https://www.automateed.com/novel-planning-software)
- [7 Scrivener Alternatives For You in 2026](https://www.novel-software.com/scrivener-alternatives/)

### AI Novel Writing Tools
- [Best AI for writing: top options for authors in 2026](https://monday.com/blog/ai-agents/best-ai-for-creative-writing/)
- [Best AI Writing Platforms for Fiction in 2026](https://sudowrite.com/blog/best-ai-writing-platforms-for-fiction-in-2026-why-your-workflow-matters-more-than-features/)
- [I tested the 5 best AI novel writing software platforms in 2026](https://www.eesel.ai/blog/ai-novel-writing-software)
- [Best AI for writing a book 2026: top tools for authors & novelists](https://monday.com/blog/ai-agents/best-ai-for-writing-a-book/)
- [The 12 AI Novel Writers I Recommend for 2026](https://technicalwriterhq.com/tools/ai-writer/ai-novel-writer/)
- [Best AI for Creative Writing in 2026: Tested & Compared](https://sudowrite.com/blog/best-ai-for-creative-writing-in-2026-tested-compared/)
- [Best AI Tools for Novel Writing in 2026](https://cognitivefuture.ai/best-ai-tools-for-novel-writing/)
- [Best AI for Writing Fiction 2026: 11 Tools Tested](https://blog.mylifenote.ai/the-11-best-ai-tools-for-writing-fiction-in-2026/)

### Diary/Journal Format Tools
- [Diarium: Cross-platform diary & journal app](https://diariumapp.com/en)
- [Writing a novel in journal/diary format | Kindle Forum](https://www.kboards.com/threads/writing-a-novel-in-journal-diary-format.89028/)
- [Diarly — Secure, simple & beautiful diary app](https://diarly.app/)
- [How to Write a Diary-Style Book: A Comprehensive Guide](https://guruathome.org/blog/write-diary-style-book/)
- [Best Diary Journal Software: Features, Benefits & Apps](https://penzu.com/diary-journal-software)
- [Free Online Journal & Diary App | Journey.Cloud](https://journey.cloud/)

### Version Control & Revision Features
- [#1 Novel & Book Writing Software For Writers](https://www.literatureandlatte.com/scrivener/overview)
- [Revising in Scrivener](https://scrivener.tenderapp.com/help/kb/general/revising-in-scrivener)
- [How to Revise the First Draft of Your Novel in Scrivener](https://www.literatureandlatte.com/blog/how-to-revise-the-first-draft-of-your-novel-in-scrivener)
- [How to Review Old Drafts With Scrivener Snapshots](https://www.well-storied.com/blog/how-to-review-old-drafts-with-scrivener-snapshots)

### Export & Publishing
- [Reedsy Studio: A FREE Online Book Formatting App](https://reedsy.com/studio/format-a-book)

### Workflow & Essential Features
- [AI Writing Assistants: Ultimate Guide to Your Automated Co-Author](https://www.authorflows.com/blogs/ai-writing-assistants-automated-co-author-guide)
- [Comparing Novel Writing Software: The Top Three Programs](https://www.printingcenterusa.com/blog/comparing-novel-writing-software-the-top-three-programs/)
- [Use This 8-Part Workflow to Write a Book](https://stephenlloydwebber.com/2019/03/use-this-8-part-workflow-to-write-a-book/)

### Problems & Limitations
- [6 Best Book Writing Tools (What Actually Works)](https://kindlepreneur.com/best-book-writing-software/)
- [I tested 22 writing tools—yeah, almost all of them—so you don't have to](https://legendfiction.substack.com/p/i-tested-23-writing-toolsyeah-almost)
- [The Best Novel Writing Software in 2024 (Reviewed by a Novelist)](https://www.novel-software.com/best-novel-writing-software/)
- [Book Writing Software (2026): Top 10 for Writers](https://thewritepractice.com/best-book-writing-software/)

---

## Recommendations for Implementation

### Ship First (MVP - Weeks 1-2)
1. Canon system with JSON schemas
2. State management (read/write operations)
3. `/novel:init` command (bootstrap new project)
4. `/novel:status` command (show progress)
5. Basic scene file structure

### Ship Second (Basic Pipeline - Weeks 3-4)
6. Plot Planner agent (outline generation)
7. Beat Planner agent (scene specifications)
8. Scene Writer agent (draft prose)
9. `/novel:write` command (execute pipeline)

### Ship Third (Consistency - Weeks 5-6)
10. Canon Checker agent (validate against rules)
11. Timeline Keeper agent (chronology validation)
12. Voice Coach agent (character voice consistency)
13. `/novel:check` command (run all validations)

### Ship Fourth (Refinement - Weeks 7-8)
14. Editor agent (apply suggested fixes)
15. Quality Gate agent (approval/rejection logic)
16. Revision loop workflow

### Ship Last (Differentiators - Weeks 9+)
17. Git integration (version control)
18. Diary format support (date/time tracking)
19. Pacing/Tension analysis agents
20. Multi-format output (EPUB/PDF via external tools)

### Success Metrics
- **Table Stakes**: Can write a basic novel with chapter/scene organization (Week 4)
- **Consistency**: Catches 90%+ canon violations automatically (Week 6)
- **Differentiator**: Version control works with git branching (Week 9)
- **Unique Value**: Diary format produces temporal-consistent entries (Week 10)

### Risk Mitigation
- **Complexity Risk**: Start simple, add agents incrementally
- **Performance Risk**: Keep state files small, cache parsed canon
- **UX Risk**: Test commands with real writing sessions weekly
- **Scope Risk**: Cut Pacing/Tension analysis if timeline slips (nice-to-have)
