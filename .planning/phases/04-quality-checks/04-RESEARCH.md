# Phase 4: Quality Checks - Research

**Researched:** 2026-02-24
**Domain:** Consistency verification, canon checking, timeline validation, voice analysis, pacing assessment, tension monitoring
**Confidence:** HIGH

## Summary

Phase 4 builds five specialized checking agents that run in parallel to verify draft quality across multiple dimensions: canon consistency, timeline coherence, character voice, pacing rhythm, and narrative tension. This research investigated multi-agent quality verification architectures, text consistency analysis techniques, and the specific patterns needed for fiction writing quality control.

The primary challenge is designing checkers that: (1) read draft scenes and cross-reference against canon and state files, (2) detect inconsistencies with specific scene references and actionable suggestions, (3) run in parallel for efficiency, and (4) produce a unified report via `/novel:check`. The existing architecture from Phases 1-3 provides strong foundations: JSON schemas define state structures, canon files define truth, and draft scenes with YAML frontmatter provide metadata for analysis.

The approach is clear: build five focused checker agents (canon-checker, timeline-keeper, voice-coach, pacing-analyzer, tension-monitor) that each read their relevant data sources, detect issues, and output structured findings. A `/novel:check` command orchestrates parallel execution and consolidates results into a quality report with severity levels and fix suggestions.

**Primary recommendation:** Build checkers as parallel agents coordinated by `/novel:check`. Each checker focuses on one quality dimension, reads specific data sources, and outputs structured issues. Use severity levels (CRITICAL, MAJOR, MINOR) and always include scene references and actionable suggestions.

## Standard Stack

This is a Claude Code project - there are no external libraries. The "stack" is the existing Novel Engine architecture from Phases 1-3.

### Core

| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| Claude Opus 4.5 | 20251101 | Text analysis LLM | Best reasoning model, handles nuanced consistency analysis |
| State Manager Skill | 1.0 | State file I/O | Already implemented, provides canon/state access |
| Git Integration Skill | 1.0 | Version tracking | Already implemented, tracks scene versions |
| JSON Schemas | 1.0 | State validation | Already defined for all state types |
| YAML Frontmatter | Standard | Scene metadata | Provides scene_id, chapter, pov, dates for cross-reference |

### Supporting

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| story_state.json | Scene index, progress tracking | Canon checker needs scene list, status |
| character_state.json | Character facts, relationships, voice_notes | Voice coach references voice patterns |
| timeline_state.json | Events, anchors, constraints | Timeline keeper verifies chronology |
| style_state.json | POV, tense, forbidden phrases | Voice coach checks style compliance |
| canon/characters.md | Character profiles, traits | Canon checker validates character facts |
| canon/world.md | World facts, locations | Canon checker validates world consistency |
| canon/timeline.md | Timeline anchors, date constraints | Timeline keeper cross-references |
| canon/style_guide.md | Voice rules, banned phrases | Voice coach enforces style |
| draft/scenes/*.md | Prose to analyze | All checkers read draft scenes |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| 5 parallel checkers | Single sequential checker | Parallel is faster, but requires coordination overhead |
| Scene-by-scene checking | Full manuscript analysis | Scene-level preserves granularity, identifies exact locations |
| Severity levels | Binary pass/fail | Severity allows prioritization, not all issues equal |
| Natural language reports | JSON-only output | Natural language more actionable for writers |

## Architecture Patterns

### Recommended Check Report Structure

```
check_reports/
  YYYY-MM-DD_HH-MM/           # Timestamped check run
    summary.md                # Consolidated report
    canon_check.json          # Raw canon checker output
    timeline_check.json       # Raw timeline keeper output
    voice_check.json          # Raw voice coach output
    pacing_check.json         # Raw pacing analyzer output
    tension_check.json        # Raw tension monitor output
```

### Pattern 1: Parallel Checker Orchestration

**What:** `/novel:check` spawns all five checkers in parallel, then consolidates results

**When to use:** Every quality check invocation

**Workflow:**
```
1. /novel:check validates prerequisites (draft scenes exist)
2. Spawn checkers in parallel:
   - novel-canon-checker
   - novel-timeline-keeper
   - novel-voice-coach
   - novel-pacing-analyzer
   - novel-tension-monitor
3. Each checker reads its data sources, analyzes scenes
4. Each checker outputs structured findings (JSON + summary)
5. /novel:check consolidates all findings into unified report
6. Report sorted by severity (CRITICAL first)
7. Save reports to check_reports/
8. Display summary to user
```

**Rationale:** Research shows multi-agent parallel execution yields +81% gains on parallelizable tasks. These five checkers are independent - they don't depend on each other's output, making them ideal for parallel execution.

### Pattern 2: Checker Agent Structure

**What:** Common structure for all checker agents

**When to use:** Building each of the five checkers

**Agent Template:**
```markdown
---
name: novel-[checker-type]
description: [Purpose]
allowed-tools: [Read, Grep, Glob]
version: 1.0
---

<role>
You are the [Checker Name] Agent, responsible for detecting [issue type].

Your job is to:
1. Read relevant canon/state files
2. Read draft scenes
3. Cross-reference for inconsistencies
4. Output structured findings with scene references
</role>

<inputs>
- canon/[relevant files]
- state/[relevant files]
- draft/scenes/*.md
</inputs>

<outputs>
Structured JSON with findings:
{
  "checker": "[checker-type]",
  "timestamp": "[ISO 8601]",
  "scenes_checked": [count],
  "issues": [
    {
      "severity": "CRITICAL|MAJOR|MINOR",
      "scene_id": "chXX_sYY",
      "type": "[issue category]",
      "description": "[what's wrong]",
      "evidence": {
        "expected": "[what should be]",
        "found": "[what was found]",
        "source": "[reference to canon/state]"
      },
      "suggestion": "[how to fix]"
    }
  ],
  "summary": {
    "critical": [count],
    "major": [count],
    "minor": [count],
    "passed": true|false
  }
}
</outputs>
```

### Pattern 3: Issue Severity Classification

**What:** Three-tier severity system for quality issues

**When to use:** All checker agents must classify issues

**Severity Levels:**

| Level | Definition | Examples | Action |
|-------|------------|----------|--------|
| CRITICAL | Canon contradiction, timeline impossibility, fundamental error | Character dead in ch3 appears alive in ch5; event happens before its cause | Must fix before approval |
| MAJOR | Significant consistency issue, style violation | Character voice drift; forbidden phrase used; pacing extremely off | Should fix, may block approval |
| MINOR | Small inconsistency, minor style issue | Slight voice variation; cliche usage; minor pacing imbalance | Nice to fix, won't block |

### Pattern 4: Check Report Format

**What:** Unified report format for user consumption

**When to use:** `/novel:check` output

**Format:**
```markdown
# Quality Check Report

**Generated:** [timestamp]
**Scenes Checked:** [count] of [total]
**Overall Status:** [PASS / NEEDS ATTENTION / CRITICAL ISSUES]

## Summary

| Checker | Critical | Major | Minor | Status |
|---------|----------|-------|-------|--------|
| Canon Checker | 0 | 2 | 3 | ATTENTION |
| Timeline Keeper | 0 | 0 | 1 | PASS |
| Voice Coach | 1 | 0 | 2 | CRITICAL |
| Pacing Analyzer | 0 | 1 | 0 | ATTENTION |
| Tension Monitor | 0 | 0 | 0 | PASS |

**Total:** 1 critical, 3 major, 6 minor

## Critical Issues (Must Fix)

### VOICE-001: Character voice inconsistency [ch05_s02]
**Severity:** CRITICAL
**Description:** Protagonist uses vocabulary inconsistent with established voice
**Evidence:**
- Expected: Simple vocabulary, contractions (per voice_notes)
- Found: "Nevertheless, the circumstances necessitated..."
- Source: character_state.json > voice_notes.Alex

**Suggestion:** Rewrite dialogue using established speech patterns. Reference voice_notes for approved vocabulary.

---

## Major Issues (Should Fix)

[... issues listed ...]

## Minor Issues (Nice to Fix)

[... issues listed ...]

---

## Recommendations

1. [Prioritized action item]
2. [Prioritized action item]

## Next Steps

- Fix critical issues before marking scenes as "checked"
- Run `/novel:check` again after revisions
- Once all critical/major issues resolved, scenes can be approved
```

### Pattern 5: Individual Checker Designs

#### Canon Checker (novel-canon-checker)

**Data Sources:**
- canon/characters.md (character facts)
- canon/world.md (world facts)
- canon/premise.md (story facts)
- state/character_state.json (current character info)
- draft/scenes/*.md (scenes to check)

**What It Checks:**
- Character physical descriptions match
- Character relationships match
- Location details consistent
- Object/item consistency (mentioned in canon, used correctly)
- Character knowledge appropriate for scene timing

**Detection Pattern:**
1. Extract factual claims from canon files
2. For each scene, identify factual assertions about characters/world
3. Cross-reference assertions against canon
4. Flag contradictions with specific quotes

#### Timeline Keeper (novel-timeline-keeper)

**Data Sources:**
- canon/timeline.md (anchor dates, constraints)
- state/timeline_state.json (events, ordering)
- beats/diary_plan.md (if diary format)
- draft/scenes/*.md (scene dates/times)

**What It Checks:**
- Scene dates are chronologically ordered
- Events respect cause-effect ordering
- Dates match day-of-week
- Seasonal descriptions match dates
- Time spans are realistic (travel, healing, growth)
- Anchors are respected

**Detection Pattern:**
1. Build timeline from scene frontmatter dates
2. Check ordering against timeline_state constraints
3. Verify anchor dates not violated
4. Check realistic time passages
5. For diary format: verify date + day-of-week match

#### Voice Coach (novel-voice-coach)

**Data Sources:**
- canon/style_guide.md (POV, tense, forbidden phrases)
- canon/characters.md (character voice descriptions)
- state/character_state.json (voice_notes per character)
- state/style_state.json (forbidden_phrases, usage_stats)
- draft/scenes/*.md (prose to analyze)

**What It Checks:**
- POV consistency (no head-hopping)
- Tense consistency (no slippage)
- Forbidden phrases not used
- Cliche watchlist items flagged
- Character dialogue matches voice_notes
- Narrative voice matches style guide

**Detection Pattern:**
1. For each scene, identify POV character
2. Check all prose stays in that POV
3. Check tense consistency throughout
4. Search for forbidden phrases (exact match)
5. Search for cliche watchlist (flag, don't fail)
6. Compare dialogue against voice_notes patterns

#### Pacing Analyzer (novel-pacing-analyzer)

**Data Sources:**
- beats/scenes/*.md (beat sheets with pacing guidance)
- draft/scenes/*.md (actual scenes)
- state/story_state.json (scene_index with word counts)

**What It Checks:**
- Scene length vs. beat sheet guidance
- Sentence length variation (not monotonous)
- Balance of action/dialogue/description
- Chapter pacing across scenes
- Rushed climactic scenes
- Dragging transition scenes

**Detection Pattern:**
1. Calculate word count for each scene
2. Compare against beat sheet target
3. Analyze sentence length distribution
4. Flag scenes with >80% similar-length sentences
5. Check high-intensity beats have adequate length
6. Check low-intensity beats aren't overwritten

#### Tension Monitor (novel-tension-monitor)

**Data Sources:**
- beats/outline.md (expected tension curve)
- beats/scenes/*.md (beat tension expectations)
- draft/scenes/*.md (actual prose)
- state/story_state.json (scene progression)

**What It Checks:**
- Conflict present in each scene
- Stakes are clear
- Tension rises toward midpoint/climax
- Appropriate tension release after peaks
- No extended flat sections
- Scene goals are challenged

**Detection Pattern:**
1. For each scene, identify conflict markers
2. Track tension curve across scenes
3. Compare against expected arc (rising action, midpoint, etc.)
4. Flag scenes with no apparent conflict
5. Flag flat tension for 3+ consecutive scenes
6. Verify resolution scenes have tension release

### Anti-Patterns to Avoid

- **Over-flagging:** Don't flag stylistic choices as errors. Only flag objective inconsistencies.

- **Vague issues:** "Voice seems off" is unhelpful. Must include specific evidence and source reference.

- **Missing scene references:** Every issue must specify which scene (chXX_sYY) it relates to.

- **No fix suggestions:** Detection without remediation is frustrating. Always include actionable suggestion.

- **Sequential execution:** Checkers are independent - run them in parallel for efficiency.

- **Blocking on minor issues:** Critical issues must be fixed; minor issues shouldn't block progress.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Date validation | Custom date parser | ISO 8601 already in schemas | Standard format, reliable |
| Day-of-week check | Manual calculation | ISO 8601 date libraries | Edge cases in calendar math |
| Phrase matching | Regex from scratch | Simple string search | Forbidden phrases are exact matches |
| Severity classification | Ad-hoc decisions | Three-tier system (CRITICAL/MAJOR/MINOR) | Consistent, prioritizable |
| Report generation | Custom templating | Markdown format | Human-readable, versionable |
| Parallel execution | Custom threading | Spawn agents independently | Claude handles orchestration |

**Key insight:** Phase 4 builds on Phases 1-3 foundations. Canon and state files already define truth - checkers compare draft against that truth. Don't recreate the truth tracking system.

## Common Pitfalls

### Pitfall 1: False Positives from Context Ignorance

**What goes wrong:** Checker flags "inconsistency" that's actually intentional (e.g., unreliable narrator, character lies, flashback).

**Why it happens:** Checker doesn't understand narrative devices.

**How to avoid:** Check context clues. If scene is marked as flashback/memory, timeline rules differ. If dialogue, character may lie intentionally.

**Warning signs:** High volume of issues that feel wrong. User frequently dismisses findings.

### Pitfall 2: Missing Cross-Scene Issues

**What goes wrong:** Issue only visible when comparing multiple scenes (character knows something before learning it).

**Why it happens:** Checker analyzes scenes in isolation.

**How to avoid:** Canon checker maintains character knowledge timeline. Cross-reference what character knows at each scene.

**Warning signs:** Readers catch continuity errors checkers missed.

### Pitfall 3: Voice Analysis Too Rigid

**What goes wrong:** Voice coach flags natural voice evolution as inconsistency.

**Why it happens:** Character voice SHOULD evolve through arc. Early voice != late voice.

**How to avoid:** Reference character arc_stage. Voice drift within arc is expected; drift between similar arc stages is suspicious.

**Warning signs:** All later scenes flagged for voice issues.

### Pitfall 4: Pacing Analysis by Numbers Only

**What goes wrong:** Pacing analyzer flags scenes purely on word count deviation.

**Why it happens:** Ignores that some scenes need more/fewer words regardless of target.

**How to avoid:** Consider scene type. Climax scenes may exceed target. Transition scenes may be shorter. Flag extreme deviations (>50%) not minor variations.

**Warning signs:** Every scene flagged for being "off target" by small amounts.

### Pitfall 5: Report Information Overload

**What goes wrong:** 50+ issues overwhelm writer. Nothing gets fixed.

**Why it happens:** No prioritization. All issues presented equally.

**How to avoid:** Sort by severity. Show critical first. Limit detail for minor issues. Provide "focus on these 3 things" summary.

**Warning signs:** User ignores check reports. Analysis paralysis.

## Code Examples

### Checker Output JSON Format

```json
{
  "checker": "canon-checker",
  "timestamp": "2024-03-15T14:30:00Z",
  "scenes_checked": 12,
  "issues": [
    {
      "severity": "CRITICAL",
      "scene_id": "ch05_s02",
      "type": "character_fact",
      "description": "Character hair color changed",
      "evidence": {
        "expected": "brown hair (established ch01_s01)",
        "found": "her blonde hair caught the light",
        "source": "canon/characters.md > Protagonist > Physical"
      },
      "suggestion": "Change 'blonde' to 'brown' to match established description"
    },
    {
      "severity": "MAJOR",
      "scene_id": "ch03_s01",
      "type": "character_knowledge",
      "description": "Character references information not yet learned",
      "evidence": {
        "expected": "Maya learns about the cave in ch03_s03",
        "found": "'I knew about the cave,' Maya said (ch03_s01)",
        "source": "beats/outline.md > Chapter 3 breakdown"
      },
      "suggestion": "Move knowledge revelation earlier, or change dialogue to remove reference"
    }
  ],
  "summary": {
    "critical": 1,
    "major": 1,
    "minor": 0,
    "passed": false
  }
}
```

### Timeline Keeper Check Pattern

```markdown
## Timeline Verification

1. Load timeline_state.json for anchors and events
2. Load all draft scenes with frontmatter dates

3. For each scene pair (scene_n, scene_n+1):
   - If scene_n.date > scene_n+1.date:
     CRITICAL: Timeline reversal
     scene_n: [scene_id] on [date]
     scene_n+1: [scene_id] on [date]
     Suggestion: Check scene order or adjust dates

4. For each constraint in timeline_state.constraints:
   - Find scenes for before/after events
   - If scene(before).date >= scene(after).date:
     CRITICAL: Constraint violated
     Constraint: [before] must happen before [after]
     Found: [before] on [date], [after] on [date]
     Suggestion: Adjust scene dates to respect ordering

5. For diary format:
   - Parse date header (e.g., "March 15, 2024 - Friday")
   - Verify day-of-week matches date
   - If mismatch:
     MINOR: Day-of-week mismatch
     Date: March 15, 2024 is actually [calculated_day]
     Found: "Friday"
     Suggestion: Change to [calculated_day]
```

### Voice Coach Check Pattern

```markdown
## Voice Consistency Verification

1. Load style_state.json for POV, tense, forbidden_phrases
2. Load character voice_notes from character_state.json
3. For each draft scene:

   a. POV Check:
      - Expected POV: [scene frontmatter pov]
      - Scan for pronouns, perspective shifts
      - If third_limited and other character's thoughts appear:
        MAJOR: POV violation (head-hopping)
        Scene: [scene_id]
        Evidence: "She wondered what he was thinking about her"
        Suggestion: Remove other character's thoughts or use inference

   b. Tense Check:
      - Expected tense: [style_state.tense]
      - Scan verb forms
      - If past tense expected and present tense found:
        MAJOR: Tense shift
        Scene: [scene_id]
        Evidence: Line [X]: "She walks to the door" (present in past narrative)
        Suggestion: Change to "She walked to the door"

   c. Forbidden Phrases:
      - For each phrase in forbidden_phrases:
        - Search scene content (case-insensitive)
        - If found:
          MAJOR: Forbidden phrase used
          Scene: [scene_id]
          Phrase: "[phrase]"
          Suggestion: Rewrite to avoid this phrase

   d. Character Voice:
      - Get voice_notes for POV character
      - Check dialogue against speech_patterns, vocabulary
      - If significant deviation:
        MINOR: Voice drift detected
        Scene: [scene_id]
        Expected: [patterns from voice_notes]
        Found: [example of deviation]
        Suggestion: Review character voice_notes and adjust dialogue
```

### /novel:check Command Pattern

```markdown
## /novel:check Execution

1. Validate prerequisites:
   - state/story_state.json exists
   - At least one scene with status "drafted" exists
   - Canon files exist

2. Display start message:
   ========================================
   RUNNING QUALITY CHECKS
   ========================================

   Scenes to check: [count]
   Checkers: 5 (parallel execution)

   - Canon Checker: Verifying facts
   - Timeline Keeper: Checking chronology
   - Voice Coach: Analyzing style
   - Pacing Analyzer: Evaluating rhythm
   - Tension Monitor: Measuring conflict

   Running...

3. Spawn all five checker agents in parallel:
   [canon_result, timeline_result, voice_result, pacing_result, tension_result]
   = parallel_execute([
     spawn("novel-canon-checker"),
     spawn("novel-timeline-keeper"),
     spawn("novel-voice-coach"),
     spawn("novel-pacing-analyzer"),
     spawn("novel-tension-monitor")
   ])

4. Consolidate results:
   - Merge all issues from all checkers
   - Sort by severity (CRITICAL > MAJOR > MINOR)
   - Calculate totals
   - Determine overall status:
     - Any CRITICAL: "CRITICAL ISSUES"
     - Any MAJOR: "NEEDS ATTENTION"
     - Only MINOR or none: "PASS"

5. Save reports:
   mkdir -p check_reports/[timestamp]/
   Write consolidated summary.md
   Write individual checker JSON outputs

6. Display summary report (see Pattern 4)

7. Return structured result for automation:
   {
     "status": "PASS|ATTENTION|CRITICAL",
     "critical_count": N,
     "major_count": N,
     "minor_count": N,
     "report_path": "check_reports/[timestamp]/summary.md"
   }
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual proofreading | Automated consistency checking | 2024-2025 | Catches errors humans miss |
| Single sequential checker | Parallel multi-agent checking | 2026 | 50%+ faster execution |
| Binary pass/fail | Severity-based triage | 2025 | Prioritized fixing, less overwhelm |
| Generic style checks | Character-specific voice analysis | 2024 | Better character consistency |
| Word count only for pacing | Sentence rhythm + scene type analysis | 2025 | More nuanced pacing feedback |

**Deprecated/outdated:**
- Checking full manuscript at once: Scene-by-scene provides actionable references
- Ignoring narrative context: Good checkers understand flashbacks, unreliable narrators
- Equal treatment of all issues: Severity levels essential for prioritization

## Open Questions

1. **How strict on forbidden phrases?**
   - What we know: style_state.json has forbidden_phrases list
   - What's unclear: Block entire scene or just flag?
   - Recommendation: Flag as MAJOR, don't auto-reject. Context may justify use.

2. **Voice drift threshold**
   - What we know: Characters evolve through arc
   - What's unclear: How much drift is acceptable?
   - Recommendation: Compare against arc_stage-appropriate voice. Early vs late voice differs.

3. **Pacing deviation tolerance**
   - What we know: Beat sheets suggest word counts
   - What's unclear: How far from target triggers flag?
   - Recommendation: >30% deviation = MINOR, >50% = MAJOR, >100% = investigate

4. **Tension measurement**
   - What we know: Scenes should have conflict
   - What's unclear: How to quantify "enough" tension
   - Recommendation: Look for conflict markers (opposition, stakes, obstacle). Flag absence, not degree.

## Sources

### Primary (HIGH confidence)

- Existing Phase 1-3 artifacts (schemas, state-manager.md, agents, commands) - Authoritative for this project architecture
- [Google's Eight Essential Multi-Agent Design Patterns](https://www.infoq.com/news/2026/01/multi-agent-design-patterns/) - Parallel orchestration patterns
- [How to Build Multi-Agent Systems: Complete 2026 Guide](https://dev.to/eira-wexford/how-to-build-multi-agent-systems-complete-2026-guide-1io6) - Agent coordination patterns
- [Parallel Agent Processing - Kore.ai](https://www.kore.ai/ai-insights/parallel-agent-processing) - Benchmark data for parallel execution gains

### Secondary (MEDIUM confidence)

- [How to Master Narrative Pacing - MasterClass 2026](https://www.masterclass.com/articles/how-to-master-narrative-pacing) - Pacing analysis fundamentals
- [The narrative arc: Revealing core narrative structures - Science Advances](https://www.science.org/doi/10.1126/sciadv.aba2196) - Research on tension/cognitive tension measurement
- [LIWC Narrative Arc Analysis](https://www.liwc.app/help/aon) - Text analysis for narrative structure
- [Portrayal: Leveraging NLP and Visualization for Analyzing Fictional Characters](https://arxiv.org/abs/2308.04056) - Character analysis techniques
- [Defect Report Best Practices - BrowserStack](https://www.browserstack.com/guide/how-to-write-a-good-defect-report) - Issue report structure patterns
- [Bug Severity Levels Guide - Brainhub](https://brainhub.eu/library/bug-severity-levels-guide) - Severity classification patterns

### Tertiary (LOW confidence)

- [Sudowrite Story Bible features](https://sudowrite.com/blog/best-ai-writing-platforms-for-fiction-in-2026-why-your-workflow-matters-more-than-features/) - Commercial tool patterns for consistency
- [World Anvil world-building tools](https://www.worldanvil.com/author) - Story bible organization patterns
- [AI Document Consistency - TestManagement](https://www.testmanagement.com/blog/2025/11/ai-document-consistency/) - General AI consistency checking

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Builds directly on existing Phase 1-3 architecture
- Architecture patterns: HIGH - Multi-agent parallel execution well-documented for 2026
- Pitfalls: HIGH - Combines established QA practices with fiction-specific challenges
- Checker designs: HIGH - Clear data sources and detection patterns from canon/state structure
- Issue severity: HIGH - Adapted from established software QA severity systems

**Research date:** 2026-02-24
**Valid until:** 2026-03-24 (30 days - stable domain, existing architecture)
