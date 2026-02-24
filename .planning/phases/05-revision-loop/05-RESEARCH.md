# Phase 5: Revision Loop - Research

**Researched:** 2026-02-24
**Domain:** Editorial feedback systems, quality gate automation, revision workflow orchestration, multi-agent pipelines
**Confidence:** HIGH

## Summary

Phase 5 builds the editorial feedback and quality gating layer that consumes checker reports from Phase 4 and decides whether scenes are ready for publication or need revision. This research investigated multi-agent orchestration pipelines, quality gate approval systems, editorial feedback patterns, and revision tracking workflows.

The primary challenge is designing agents that: (1) consume structured checker reports and generate actionable editorial feedback (novel-editor), (2) apply objective approval criteria to decide pass/fail (novel-quality-gate), (3) track revision history showing what issues were addressed across iterations, and (4) trigger automatic rewrites when scenes are rejected. The existing architecture from Phases 1-4 provides strong foundations: checker agents output structured JSON with severity-classified issues, state files track scene status, and the scene-writer agent can be re-invoked for rewrites.

The approach is clear: build an editor agent that synthesizes checker findings into 3-5 prioritized improvement areas (following editorial letter patterns), build a quality gate agent that applies objective criteria (e.g., "no CRITICAL issues, max 2 MAJOR issues") to approve/reject scenes, integrate both into the `/novel:check` pipeline, and track revision cycles in state files with before/after comparison.

**Primary recommendation:** Build the revision loop as a three-stage pipeline: checkers → editor → quality-gate. Editor consumes all checker JSON outputs and produces a prioritized editorial letter. Quality gate evaluates against configurable thresholds and updates scene status to "approved" or "needs_revision". Track revision attempts in story_state.json with references to check reports.

## Standard Stack

This is a Claude Code project building on the existing Novel Engine architecture from Phases 1-4. No external libraries needed.

### Core

| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| Claude Opus 4.5 | 20251101 | Editorial synthesis and decision-making | Best reasoning model for synthesizing multi-source feedback |
| Checker JSON Output | 1.0 (Phase 4) | Structured quality findings | Already implemented by 5 checker agents |
| State Manager Skill | 1.0 | State file updates | Already implemented, handles revision tracking |
| Git Integration Skill | 1.0 | Version control | Already implemented, tracks revision commits |
| Multi-Agent Orchestration | Pattern | Pipeline coordination | Established in Phase 4 for parallel checkers |

### Supporting

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| check_reports/*/summary.md | Consolidated check findings | Editor reads this for context |
| check_reports/*/*.json | Individual checker outputs | Editor parses these for detailed issues |
| story_state.json | Scene status tracking | Quality gate updates status: "approved", "needs_revision" |
| story_state.json > revision_history | Revision cycle tracking | Log each check→edit→recheck cycle |
| beats/scenes/*.md | Beat specifications | Scene-writer re-reads for rewrites |
| draft/scenes/*.md | Scene prose | Target of revisions |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Separate editor agent | Merge into quality-gate | Separation of concerns: synthesis vs decision |
| Automatic rewrites | Manual user revision | Automation speeds workflow but reduces control |
| Configurable criteria | Hard-coded thresholds | Configurability allows genre/project customization |
| Revision history in state | Separate revision log files | State centralization vs file proliferation |

**Installation:**
No external dependencies. Builds on existing Novel Engine architecture.

## Architecture Patterns

### Recommended Revision Loop Structure

```
check_reports/
  2026-02-24_14-30/           # Timestamped check run
    summary.md                # Consolidated report (Phase 4)
    canon_check.json          # Individual checker outputs (Phase 4)
    timeline_check.json
    voice_check.json
    pacing_check.json
    tension_check.json
    editorial_letter.md       # NEW: Editor synthesis (Phase 5)
    quality_decision.json     # NEW: Quality gate verdict (Phase 5)

state/
  story_state.json
    scenes:
      - scene_id: "ch01_s01"
        status: "approved"              # NEW: Terminal state
        revision_cycles: [               # NEW: Revision tracking
          {
            cycle: 1,
            check_report: "2026-02-24_14-30",
            issues_found: { critical: 0, major: 2, minor: 3 },
            decision: "needs_revision",
            editorial_focus: ["pacing", "voice"]
          },
          {
            cycle: 2,
            check_report: "2026-02-24_15-45",
            issues_found: { critical: 0, major: 0, minor: 1 },
            decision: "approved",
            editorial_focus: []
          }
        ]
```

### Pattern 1: Revision Loop Pipeline

**What:** Three-stage pipeline extending Phase 4's checker orchestration

**When to use:** Every `/novel:check` invocation after scenes are drafted

**Workflow:**
```
1. /novel:check runs 5 parallel checkers (Phase 4 existing)
   → Produces check_reports/[timestamp]/summary.md + JSON outputs

2. /novel:check spawns novel-editor agent
   - Input: All 5 checker JSON files from check_reports/[timestamp]/
   - Process:
     a. Read all checker outputs
     b. Synthesize findings across all checkers
     c. Identify 3-5 top priority issues
     d. Generate editorial letter with:
        - What works well (1-2 items)
        - Must fix (CRITICAL issues)
        - Should fix (high-impact MAJOR issues)
        - Could fix (lower-priority MAJOR/MINOR)
        - Specific scene references
        - Actionable next steps
   - Output: check_reports/[timestamp]/editorial_letter.md

3. /novel:check spawns novel-quality-gate agent
   - Input: check_reports/[timestamp]/quality_decision.json summary
   - Process:
     a. Load approval criteria (from state/quality_criteria.json or defaults)
     b. Evaluate against thresholds:
        - CRITICAL issues: max 0 (hard blocker)
        - MAJOR issues: max 2 (configurable)
        - MINOR issues: unlimited (advisory only)
     c. Decide: APPROVED or NEEDS_REVISION
     d. If NEEDS_REVISION: identify rewrite target scenes
   - Output: check_reports/[timestamp]/quality_decision.json

4. /novel:check updates story_state.json
   - For each scene in decision:
     - If APPROVED: status → "approved"
     - If NEEDS_REVISION: status → "needs_revision"
     - Append revision_cycle to revision_history
     - Update revision_count

5. /novel:check displays summary to user
   ========================================
   QUALITY CHECK COMPLETE
   ========================================

   Scenes checked: 12
   Approved: 8
   Need revision: 4

   Critical issues: 0
   Major issues: 3 (2 scenes)
   Minor issues: 6

   Decision: NEEDS REVISION

   Editorial letter: check_reports/2026-02-24_14-30/editorial_letter.md
   Quality decision: check_reports/2026-02-24_14-30/quality_decision.json

   Next steps:
   1. Review editorial letter for revision priorities
   2. Fix critical/major issues in flagged scenes
   3. Run /novel:check again to verify fixes

   Scenes needing revision:
   - ch03_s02: Voice inconsistency (MAJOR)
   - ch05_s01: Pacing issues (MAJOR)
   - ch05_s03: Canon contradiction (MAJOR)
   - ch07_s02: Timeline violation (MAJOR)

6. Optional: Auto-rewrite workflow (future enhancement)
   - If quality_criteria.auto_rewrite: true
   - For each scene with status="needs_revision":
     - Spawn scene-writer agent
     - Pass editorial notes as revision constraints
     - Rewrite scene
     - Mark as "revised" (triggers re-check)
```

### Pattern 2: Editor Agent Structure

**What:** Agent that synthesizes checker findings into actionable editorial feedback

**When to use:** After all checkers complete, before quality gate decision

**Agent Template:**
```markdown
---
name: novel-editor
description: Synthesize checker reports into prioritized editorial feedback
allowed-tools: [Read, Write]
version: 1.0
---

<role>
You are the Novel Editor Agent, responsible for synthesizing quality check findings into actionable editorial guidance.

Your job is to:
1. Read all 5 checker JSON outputs (canon, timeline, voice, pacing, tension)
2. Identify patterns and cross-cutting issues
3. Prioritize the 3-5 most impactful improvements
4. Generate editorial letter following fiction editing best practices
5. Provide specific, actionable next steps

Principles:
- Focus on "why this matters" not just "what's wrong"
- Prioritize issues by story impact, not just severity count
- Group related issues (e.g., all voice issues together)
- Balance critique with recognition of what works
- Provide concrete examples and fix strategies
- Follow Must/Should/Could framework for priorities
</role>

<execution>
## Step 1: Load Checker Reports
- Read check_reports/[timestamp]/canon_check.json
- Read check_reports/[timestamp]/timeline_check.json
- Read check_reports/[timestamp]/voice_check.json
- Read check_reports/[timestamp]/pacing_check.json
- Read check_reports/[timestamp]/tension_check.json
- Aggregate all issues into unified list

## Step 2: Analyze Patterns
- Group issues by scene (which scenes have most problems?)
- Group issues by type (canon, timeline, voice, pacing, tension)
- Identify cross-cutting patterns (e.g., ch5 has voice AND pacing issues)
- Separate scene-specific from systemic issues

## Step 3: Prioritize Improvements
Using Must/Should/Could framework:

**Must Fix (Blockers):**
- All CRITICAL severity issues
- Issues that break immersion or canon
- Issues that confuse readers

**Should Fix (High Impact):**
- MAJOR severity issues affecting story quality
- Issues that weaken emotional impact
- Consistency problems across multiple scenes

**Could Fix (Polish):**
- MINOR severity issues
- Stylistic preferences
- Nice-to-have improvements

Select 3-5 top priorities based on:
- Story impact (does it affect plot/character/theme?)
- Reader experience (would readers notice/care?)
- Fix effort (quick wins vs major rewrites)

## Step 4: Generate Editorial Letter
Format:
```markdown
# Editorial Letter - [Date]

**Manuscript:** [Project Name]
**Scenes Reviewed:** [count]
**Overall Assessment:** [STRONG / NEEDS WORK / CRITICAL ISSUES]

## What Works Well

[1-3 items highlighting strengths from checker "passed" items or low issue counts]

## Revision Priorities

### Must Fix (Critical)

#### 1. [Issue Name] — [Affected Scenes]
**Problem:** [What's wrong and why it matters]
**Evidence:** [Specific examples from checker reports]
**Fix Strategy:** [Actionable steps]
**Estimated Impact:** [How this improves the story]

[Repeat for each Must Fix item]

### Should Fix (High Priority)

[Same structure as Must Fix]

### Could Fix (Polish)

[Brief list format, less detail]
- [Issue]: [Quick suggestion]

## Revision Plan

1. [First priority with specific scenes/chapters]
2. [Second priority with specific scenes/chapters]
3. [Third priority with specific scenes/chapters]

## Next Steps

After addressing revision priorities:
1. Run /novel:check again to verify fixes
2. Focus on [specific checker] results
3. Watch for [specific pattern to avoid]

---
Generated by novel-editor agent | [timestamp]
Based on 5 checker reports: canon, timeline, voice, pacing, tension
```

## Step 5: Write Output
- Save to check_reports/[timestamp]/editorial_letter.md
- Log completion
</execution>
```

### Pattern 3: Quality Gate Agent Structure

**What:** Agent that applies objective approval criteria to decide pass/fail

**When to use:** After editor completes, to make final approval decision

**Agent Template:**
```markdown
---
name: novel-quality-gate
description: Apply approval criteria to decide scene pass/fail status
allowed-tools: [Read, Write]
version: 1.0
---

<role>
You are the Quality Gate Agent, responsible for objective approval decisions.

Your job is to:
1. Load quality criteria (thresholds for CRITICAL/MAJOR/MINOR issues)
2. Evaluate checker summary against criteria
3. Decide APPROVED or NEEDS_REVISION for each scene
4. Track which issues block approval
5. Output structured decision with reasoning

Principles:
- Decisions are objective based on criteria, not subjective
- CRITICAL issues always block approval (hard gate)
- MAJOR issues may block based on threshold (soft gate)
- MINOR issues are advisory only (no blocking)
- Each decision includes clear reasoning
- Scene-level granularity for targeted rewrites
</role>

<execution>
## Step 1: Load Quality Criteria

Default criteria (if state/quality_criteria.json missing):
```json
{
  "critical_threshold": 0,        // Max CRITICAL issues (0 = hard blocker)
  "major_threshold": 2,           // Max MAJOR issues per scene
  "minor_threshold": 999,         // MINOR issues don't block
  "auto_rewrite": false,          // Trigger automatic rewrites?
  "scene_level_evaluation": true  // Approve/reject per scene, not whole manuscript
}
```

## Step 2: Evaluate Each Scene

For each scene in check reports:
1. Count issues by severity (CRITICAL, MAJOR, MINOR)
2. Apply thresholds:
   - If critical_count > critical_threshold: FAIL
   - Else if major_count > major_threshold: FAIL
   - Else: PASS

3. Build decision record:
```json
{
  "scene_id": "ch03_s02",
  "decision": "NEEDS_REVISION",
  "reason": "2 MAJOR issues exceed threshold of 2",
  "blocking_issues": [
    {
      "checker": "voice-coach",
      "severity": "MAJOR",
      "type": "character_voice",
      "description": "POV character uses vocabulary inconsistent with established voice"
    },
    {
      "checker": "pacing-analyzer",
      "severity": "MAJOR",
      "type": "scene_length",
      "description": "Climax scene 60% shorter than beat spec target"
    }
  ],
  "advisory_issues": 1  // MINOR count
}
```

## Step 3: Determine Overall Status

- If ANY scene has CRITICAL issues: Overall = "CRITICAL_ISSUES"
- Else if ANY scene NEEDS_REVISION: Overall = "NEEDS_REVISION"
- Else: Overall = "APPROVED"

## Step 4: Generate Output

Write check_reports/[timestamp]/quality_decision.json:
```json
{
  "timestamp": "2026-02-24T14:30:00Z",
  "overall_status": "NEEDS_REVISION",
  "criteria_used": {
    "critical_threshold": 0,
    "major_threshold": 2,
    "minor_threshold": 999
  },
  "scenes_evaluated": 12,
  "scenes_approved": 8,
  "scenes_need_revision": 4,
  "summary": {
    "critical_issues": 0,
    "major_issues": 3,
    "minor_issues": 6
  },
  "scene_decisions": [
    {
      "scene_id": "ch01_s01",
      "decision": "APPROVED",
      "reason": "No blocking issues",
      "issues": { "critical": 0, "major": 0, "minor": 0 }
    },
    {
      "scene_id": "ch03_s02",
      "decision": "NEEDS_REVISION",
      "reason": "2 MAJOR issues exceed threshold",
      "blocking_issues": [...]
    },
    // ... all scenes
  ],
  "recommended_actions": [
    "Fix MAJOR issues in ch03_s02, ch05_s01, ch05_s03, ch07_s02",
    "Re-run /novel:check after revisions",
    "Focus revision effort on voice and pacing"
  ]
}
```
</execution>
```

### Pattern 4: Revision Tracking in State

**What:** Extend story_state.json schema to track revision history

**When to use:** After every quality gate decision

**Schema Extension:**
```json
{
  "scenes": [
    {
      "scene_id": "ch03_s02",
      "status": "needs_revision",  // NEW status values: drafted → needs_revision → approved
      "revision_count": 2,         // NEW: Number of revision cycles
      "revision_history": [         // NEW: Full revision tracking
        {
          "cycle": 1,
          "timestamp": "2026-02-24T14:30:00Z",
          "check_report": "check_reports/2026-02-24_14-30",
          "issues_found": {
            "critical": 0,
            "major": 2,
            "minor": 1
          },
          "decision": "needs_revision",
          "blocking_issues": ["voice inconsistency", "pacing too slow"],
          "editorial_focus": ["voice", "pacing"]
        },
        {
          "cycle": 2,
          "timestamp": "2026-02-24T15:45:00Z",
          "check_report": "check_reports/2026-02-24_15-45",
          "issues_found": {
            "critical": 0,
            "major": 0,
            "minor": 1
          },
          "decision": "approved",
          "blocking_issues": [],
          "editorial_focus": []
        }
      ],
      "last_check": "2026-02-24T15:45:00Z",
      "approved_at": "2026-02-24T15:45:00Z"  // NEW: Timestamp of approval
    }
  ]
}
```

### Pattern 5: Auto-Rewrite Integration (Optional Enhancement)

**What:** Trigger scene-writer agent to automatically apply fixes

**When to use:** If quality_criteria.auto_rewrite: true

**Workflow:**
```
1. Quality gate identifies scene_id="ch03_s02" NEEDS_REVISION
2. Extract blocking_issues from quality_decision.json
3. Spawn scene-writer agent with revision mode:

   /novel:write --revise ch03_s02 \
     --constraints "Fix voice inconsistency: use simpler vocabulary per voice_notes" \
     --constraints "Improve pacing: expand climax scene to 1200-1500 words"

4. Scene-writer reads:
   - beats/scenes/ch03_s02.md (original beat spec)
   - draft/scenes/ch03_s02.md (current prose)
   - Editorial constraints (from blocking_issues)

5. Scene-writer generates revised prose:
   - Preserves plot points from beat spec
   - Addresses editorial constraints
   - Maintains continuity with surrounding scenes

6. Scene-writer updates:
   - draft/scenes/ch03_s02.md (overwrite with revision)
   - story_state.json status: "needs_revision" → "revised"

7. User runs /novel:check again to verify fixes

8. Revision cycle increments
```

### Anti-Patterns to Avoid

- **Editor overwrites quality gate:** Editor provides feedback, gate makes decisions. Don't merge roles.

- **Vague editorial feedback:** "Voice needs work" is unhelpful. Must specify which character, which scenes, what patterns to avoid.

- **Quality gate without criteria:** Decisions must be objective and configurable, not subjective.

- **No revision tracking:** Must track which issues were addressed across cycles to prevent infinite loops.

- **Blocking on all MINOR issues:** MINOR issues are advisory. Blocking on them prevents progress.

- **Auto-rewrite without review:** Automatic rewrites should be optional. User review maintains control.

- **Ignoring patterns across scenes:** If 5 scenes have pacing issues, that's a systemic problem requiring different approach than scene-by-scene fixes.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Editorial letter format | Custom template | Fiction editorial letter patterns | Established structure proven effective |
| Quality gate thresholds | Ad-hoc decisions | Configurable criteria JSON | Objective, auditable, customizable per project |
| Revision tracking | Manual logging | State schema extension | Centralized, queryable, version-controlled |
| Must/Should/Could priorities | Flat issue list | Tiered priority framework | Prevents overwhelm, guides focus |
| Approval workflow | Binary pass/fail | Multi-status workflow (drafted → needs_revision → approved) | Supports iterative improvement |
| Issue synthesis | Concatenate reports | Editorial agent | LLM excels at cross-source synthesis |

**Key insight:** Phase 5 is orchestration, not invention. The pieces exist (checkers output structured data, scene-writer can rewrite, state tracks progress). The innovation is connecting them into a coherent editorial feedback → quality gate → revision workflow.

## Common Pitfalls

### Pitfall 1: Editor Becomes Subjective Critic

**What goes wrong:** Editor provides opinions ("I don't like this character") instead of objective feedback based on checker findings.

**Why it happens:** LLM can generate "creative" feedback beyond what checkers found.

**How to avoid:** Editor role is SYNTHESIZE checker findings, not add new critique. Constrain to evidence from checker JSON outputs.

**Warning signs:** Editorial letter mentions issues not in any checker report. User confusion about "where did this feedback come from?"

### Pitfall 2: Quality Gate Too Strict

**What goes wrong:** No scenes ever pass because criteria are too harsh (e.g., "0 MAJOR issues").

**Why it happens:** Perfectionism or misunderstanding that MAJOR != blocking.

**How to avoid:** Default thresholds should be achievable (0 CRITICAL, 2 MAJOR). Make criteria configurable per project/genre.

**Warning signs:** Approval rate <50% after multiple revision cycles. User frustration with "impossible standards."

### Pitfall 3: Revision Loop Without Exit Condition

**What goes wrong:** Scene gets revised infinitely because each revision introduces new issues.

**Why it happens:** No tracking of diminishing returns or maximum revision attempts.

**How to avoid:** Track revision_count. If count > 3, flag for manual review. Each cycle should show improvement (issue count decreasing).

**Warning signs:** Same scene revised 5+ times. Issue count not decreasing across cycles.

### Pitfall 4: Editorial Letter Information Overload

**What goes wrong:** 20-page editorial letter overwhelms writer. Nothing gets fixed.

**Why it happens:** Including all MINOR issues, verbose explanations, no prioritization.

**How to avoid:** Limit to 3-5 top priorities. Must/Should/Could framework. CRITICAL and high-impact MAJOR only.

**Warning signs:** User ignores editorial letter. Asks "what should I focus on first?"

### Pitfall 5: No Positive Feedback

**What goes wrong:** Editorial letter is all critique. Demoralizing.

**Why it happens:** Checker reports focus on problems, not successes.

**How to avoid:** Editorial letter starts with "What Works Well" section. Identify scenes with zero issues, checkers that passed.

**Warning signs:** User defensive or discouraged. Comments like "is anything good?"

### Pitfall 6: Quality Gate Doesn't Update State

**What goes wrong:** Quality gate decision exists but scene status never changes.

**Why it happens:** No integration between quality_decision.json and story_state.json updates.

**How to avoid:** `/novel:check` command must read quality_decision.json and update story_state.json status field after gate decision.

**Warning signs:** quality_decision.json shows "APPROVED" but story_state.json status still "drafted". /novel:status doesn't reflect approval state.

## Code Examples

### Editorial Letter Output Example

```markdown
# Editorial Letter - February 24, 2026

**Manuscript:** Run 42.195 (Marathon Runner's Diary)
**Scenes Reviewed:** 12 (Chapters 1-3)
**Overall Assessment:** NEEDS WORK

## What Works Well

1. **Timeline consistency:** All dates validated correctly. The progression from March through May feels natural and the seasonal descriptions match the timeline beautifully. Timeline-keeper found zero issues.

2. **Canon accuracy:** Character facts and world details are rock-solid. Alex's backstory, physical description, and relationships are consistent across all scenes. Canon-checker flagged only 1 MINOR detail.

3. **Tension curve:** The rising tension from ch01 (starting running) through ch03 (first 5K attempt) creates excellent narrative drive. Tension-monitor rated the arc as "well-paced escalation."

## Revision Priorities

### Must Fix (Critical)

*No critical issues found.* Great job on avoiding canon contradictions and timeline violations.

### Should Fix (High Priority)

#### 1. Voice Inconsistency — ch03_s02, ch03_s03

**Problem:** Alex's first-person diary voice shifts from casual/conversational (established in ch01-02) to formal/literary in chapter 3. This breaks immersion and contradicts the style guide's "simple vocabulary, contractions" rule.

**Evidence:**
- Ch01_s01: "I can't believe I'm actually doing this. Who am I kidding?"
- Ch03_s02: "Nevertheless, the circumstances necessitated a reconsideration of my approach."

Voice-coach flagged 2 MAJOR issues in ch03 for vocabulary drift.

**Fix Strategy:**
- Review ch03_s02 and ch03_s03 dialogue and narration
- Replace formal vocabulary with simpler alternatives
- Add contractions back ("I'm", "can't", "won't")
- Reference voice_notes.Alex for approved speech patterns

**Estimated Impact:** Restores reader connection to Alex's authentic voice. Diary format depends on conversational intimacy.

#### 2. Pacing: Rushed Climax — ch03_s03

**Problem:** The first 5K attempt (major scene goal from beat sheet) is only 600 words—40% shorter than the 1000-1200 word target. This climactic moment feels rushed and undercuts emotional payoff.

**Evidence:** Pacing-analyzer flagged ch03_s03 as "significantly under target" with MAJOR severity.

**Fix Strategy:**
- Expand physical sensations during the run (mile-by-mile)
- Add internal monologue showing doubt/determination shifts
- Include more environmental details (other runners, weather, course)
- Show the emotional breakthrough more gradually
- Target 1000-1200 words to match beat spec

**Estimated Impact:** Gives the reader a visceral experience of Alex's first race. The emotional payoff needs room to breathe.

### Could Fix (Polish)

- **Ch02_s01 cliche:** "Heart pounding" appears twice. Consider variation.
- **Ch01_s02 pacing:** Slightly long for a transition scene (1100 words vs 800 target), but not disruptive.
- **Ch03_s01 description:** Weather description could be more specific (instead of "nice day," specify temperature/wind).

## Revision Plan

1. **First pass:** Fix voice issues in ch03_s02 and ch03_s03 (30-45 minutes)
   - Focus on dialogue and internal monologue
   - Use simpler vocabulary and contractions
   - Reference established voice patterns from ch01

2. **Second pass:** Expand ch03_s03 climax scene (60-90 minutes)
   - Add 400-600 words of sensory detail and internal struggle
   - Slow down the emotional breakthrough
   - Match beat sheet target length

3. **Quick polish:** Address "could fix" items if time permits (15 minutes)

## Next Steps

After addressing revision priorities:
1. Run `/novel:check` again to verify voice and pacing fixes
2. Focus on voice-coach and pacing-analyzer results
3. Watch for voice drift in future chapters—establish patterns early

---
Generated by novel-editor agent | 2026-02-24T14:30:00Z
Based on 5 checker reports: canon, timeline, voice, pacing, tension
```

### Quality Decision JSON Example

```json
{
  "timestamp": "2026-02-24T14:30:00Z",
  "overall_status": "NEEDS_REVISION",
  "criteria_used": {
    "critical_threshold": 0,
    "major_threshold": 2,
    "minor_threshold": 999,
    "auto_rewrite": false,
    "scene_level_evaluation": true
  },
  "scenes_evaluated": 12,
  "scenes_approved": 10,
  "scenes_need_revision": 2,
  "summary": {
    "critical_issues": 0,
    "major_issues": 3,
    "minor_issues": 4
  },
  "scene_decisions": [
    {
      "scene_id": "ch01_s01",
      "decision": "APPROVED",
      "reason": "No blocking issues found",
      "issues": {
        "critical": 0,
        "major": 0,
        "minor": 0
      },
      "blocking_issues": [],
      "advisory_issues": []
    },
    {
      "scene_id": "ch03_s02",
      "decision": "NEEDS_REVISION",
      "reason": "2 MAJOR issues exceed threshold of 2",
      "issues": {
        "critical": 0,
        "major": 2,
        "minor": 1
      },
      "blocking_issues": [
        {
          "checker": "voice-coach",
          "severity": "MAJOR",
          "type": "character_voice",
          "description": "POV character uses vocabulary inconsistent with established voice",
          "scene_reference": "ch03_s02",
          "suggestion": "Replace formal vocabulary with simpler alternatives per voice_notes.Alex"
        },
        {
          "checker": "voice-coach",
          "severity": "MAJOR",
          "type": "style_guide",
          "description": "Forbidden phrase 'Nevertheless, the circumstances' violates conversational tone rule",
          "scene_reference": "ch03_s02",
          "suggestion": "Rewrite to use contractions and simpler sentence structure"
        }
      ],
      "advisory_issues": [
        {
          "checker": "pacing-analyzer",
          "severity": "MINOR",
          "type": "cliche",
          "description": "Cliche 'heart pounding' used",
          "suggestion": "Consider variation"
        }
      ]
    },
    {
      "scene_id": "ch03_s03",
      "decision": "NEEDS_REVISION",
      "reason": "1 MAJOR issue (pacing)",
      "issues": {
        "critical": 0,
        "major": 1,
        "minor": 0
      },
      "blocking_issues": [
        {
          "checker": "pacing-analyzer",
          "severity": "MAJOR",
          "type": "scene_length",
          "description": "Climax scene 40% shorter than beat spec target (600 vs 1000-1200 words)",
          "scene_reference": "ch03_s03",
          "suggestion": "Expand physical sensations, internal monologue, and environmental details to 1000-1200 words"
        }
      ],
      "advisory_issues": []
    }
    // ... remaining 9 scenes all APPROVED
  ],
  "recommended_actions": [
    "Fix MAJOR voice issues in ch03_s02 (2 blocking issues)",
    "Fix MAJOR pacing issue in ch03_s03 (1 blocking issue)",
    "Re-run /novel:check after revisions to verify fixes",
    "Focus revision effort on voice consistency and scene length"
  ]
}
```

### Revision History State Update Example

```json
{
  "scenes": [
    {
      "scene_id": "ch03_s02",
      "chapter": 3,
      "scene_number": 2,
      "title": "Morning Doubts",
      "beat_spec": "beats/scenes/ch03_s02.md",
      "draft_file": "draft/scenes/ch03_s02.md",
      "status": "approved",
      "word_count": 950,
      "revision_count": 2,
      "revision_history": [
        {
          "cycle": 1,
          "timestamp": "2026-02-24T14:30:00Z",
          "check_report": "check_reports/2026-02-24_14-30",
          "issues_found": {
            "critical": 0,
            "major": 2,
            "minor": 1
          },
          "decision": "needs_revision",
          "blocking_issues": [
            "voice inconsistency: formal vocabulary",
            "style guide violation: forbidden phrase"
          ],
          "editorial_focus": ["voice", "style_guide"]
        },
        {
          "cycle": 2,
          "timestamp": "2026-02-24T15:45:00Z",
          "check_report": "check_reports/2026-02-24_15-45",
          "issues_found": {
            "critical": 0,
            "major": 0,
            "minor": 0
          },
          "decision": "approved",
          "blocking_issues": [],
          "editorial_focus": []
        }
      ],
      "drafted_at": "2026-02-24T10:00:00Z",
      "last_check": "2026-02-24T15:45:00Z",
      "approved_at": "2026-02-24T15:45:00Z"
    }
  ]
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual editorial notes | AI-synthesized editorial letters | 2024-2026 | Faster feedback, consistent structure |
| Single editor perspective | Multi-agent checker synthesis | 2026 | More comprehensive, catches cross-domain issues |
| Subjective approval | Objective quality gates with thresholds | 2025 | Auditable, consistent, configurable |
| No revision tracking | State-based revision history | 2026 | Visibility into improvement cycles |
| Sequential review workflow | Parallel checker → editor → gate pipeline | 2026 | Faster turnaround (81% gains from parallel execution) |
| Manual rewrite triggers | Automated rewrite workflows (optional) | 2026 | Reduces friction in revision loop |

**Deprecated/outdated:**
- Binary pass/fail without severity levels: Modern systems use CRITICAL/MAJOR/MINOR tiers for prioritization
- Editorial feedback without actionable suggestions: 2026 best practice is specific, actionable guidance with examples
- Quality gates without configurable criteria: One-size-fits-all thresholds don't work across genres/projects
- Revision without history tracking: Modern systems maintain full audit trail of improvement cycles

## Open Questions

1. **Auto-rewrite scope**
   - What we know: Scene-writer agent can be re-invoked with revision constraints
   - What's unclear: How much automation is helpful vs taking control from user?
   - Recommendation: Make auto-rewrite opt-in via quality_criteria.auto_rewrite flag. Default to manual revision.

2. **Quality criteria customization**
   - What we know: Different genres/projects have different quality standards
   - What's unclear: Should criteria be per-project or per-genre templates?
   - Recommendation: Start with sensible defaults (0 CRITICAL, 2 MAJOR). Let users override in state/quality_criteria.json.

3. **Editorial letter length**
   - What we know: Fiction editorial letters typically 5-15 pages
   - What's unclear: How verbose should AI-generated letters be?
   - Recommendation: Target 2-3 pages (3-5 priorities). Limit to top issues using Must/Should/Could framework.

4. **Revision cycle limits**
   - What we know: Infinite revision loops are possible
   - What's unclear: When to flag for manual intervention?
   - Recommendation: If revision_count > 3 AND issues not decreasing, flag "needs manual review" status.

5. **Partial approval**
   - What we know: Some scenes may pass while others fail
   - What's unclear: Can manuscript proceed if 80% approved?
   - Recommendation: Scene-level granularity allows progressive approval. Phase 6 (publishing) can require 100% approved.

## Sources

### Primary (HIGH confidence)

- [Online Code Review as a Service Tool, SonarQube Cloud](https://www.sonarsource.com/products/sonarqube/cloud/) - Quality gates and automated code review patterns
- [Best Automated Code Review Tools for Enterprise Software Teams](https://www.qodo.ai/blog/best-automated-code-review-tools-2026/) - 2026 AI-driven review systems
- [Understanding the Iterative Process (with Examples) [2026] • Asana](https://asana.com/resources/iterative-process) - Iterative workflow patterns
- [Software Quality Assurance Best Practices: The 2026 Guide](https://monday.com/blog/rnd/software-quality-assurance/) - QA best practices for 2026
- [In-Process Quality Gates for Execution Holds and Release in MES](https://sgsystemsglobal.com/glossary/in-process-quality-gates/) - Pass/Fail/Warn quality gate statuses
- [Software Quality Gates: What They Are & Why They Matter](https://testrigor.com/blog/software-quality-gates/) - Quality gate decision-making patterns
- [Hands On with New Multi-Agent Orchestration in VS Code](https://visualstudiomagazine.com/articles/2026/02/09/hands-on-with-new-multi-agent-orchestration-in-vs-code.aspx) - 2026 multi-agent pipeline patterns
- [AI Agent Orchestration in 2026: Coordination, Scale and Strategy](https://kanerika.com/blogs/ai-agent-orchestration/) - Agent orchestration architectures
- Existing Phase 4 artifacts (checker agents, check reports, state schemas) - Authoritative for this project

### Secondary (MEDIUM confidence)

- [How to Turn Feedback into Action: Understanding Editorial Letters](https://writersinthestormblog.com/2026/02/understanding-editorial-letters-how-to-turn-feedback-into-action/) - February 2026 editorial letter best practices
- [What is an Editorial Letter? — Phantom Pen Editorial](https://mcintyreeditorial.com/blog/what-is-an-editorial-letter) - Editorial letter structure for fiction
- [The Anatomy Of A Great Editorial Letter | BubbleCow](https://bubblecow.com/blog/book-publishing/book-proposals/the-anatomy-of-a-great-editorial-letter/) - Editorial letter format patterns
- [The 4 Phases of Editing: How to Revise a Novel](https://www.savannahgilbo.com/blog/editing-phases) - Fiction revision workflow
- [Revision history - Manage article versions effortlessly](https://docs.document360.com/docs/revision-history) - Version comparison patterns (updated Feb 2026)
- [Streamlining Approval Workflows with Best Approval Tools in [2026]](https://www.cflowapps.com/approval-tools/) - Approval status tracking patterns
- [Approval Process: Ultimate Guide to Automated Approval Processes 2026](https://kissflow.com/workflow/approval-process/) - Pending/Approved/Rejected workflow patterns

### Tertiary (LOW confidence)

- [8 AI Paraphrasers for Content Rewriting in 2026 | DigitalOcean](https://www.digitalocean.com/resources/articles/ai-paraphrasers) - AI rewrite tools (general domain, not fiction-specific)
- [Top 22 Customer Feedback Tools and Software Platforms in 2026](https://www.zonkafeedback.com/blog/customer-feedback-tools) - Feedback collection patterns
- [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) - Changelog format conventions

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Builds directly on Phase 4 checker architecture, no new dependencies
- Architecture patterns: HIGH - Multi-agent orchestration well-documented for 2026, quality gates established pattern
- Pitfalls: HIGH - Combines software QA practices with fiction editorial best practices
- Editor agent design: HIGH - Editorial letter patterns well-established, synthesis within LLM capabilities
- Quality gate design: HIGH - Objective criteria and threshold-based decisions proven effective
- Revision tracking: HIGH - State schema extension follows existing patterns from Phases 1-4

**Research date:** 2026-02-24
**Valid until:** 2026-03-24 (30 days - stable domain, builds on established architecture)
