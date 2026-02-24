# Pitfalls Research: Novel Writing Engine

## Executive Summary

Novel writing engines face three critical failure domains:
1. **AI System Failures** — Multi-agent coordination, memory, and continuity
2. **Architecture Mistakes** — State management, version control, and pipeline design
3. **Creative Quality Issues** — Over-automation, loss of voice, and generic output

This document identifies 27 specific pitfalls across these domains, with early warning signs and prevention strategies for each.

---

## Critical Pitfalls

### 1. Multi-Agent Coordination Collapse

**Problem**: Inter-agent misalignment is the #1 failure mode in production multi-agent systems, accounting for 36.94% of all failures. Agents duplicate work, loop indefinitely, or produce incompatible outputs (e.g., planner outputs YAML while executor expects JSON).

**Why It Kills Projects**: The "Bag of Agents" anti-pattern creates 17.2x error amplification. Without proper coordination structure, agent outputs cascade into exponentially worse results.

**Warning Signs**:
- Agents repeatedly re-fetching or re-analyzing the same data
- Infinite loops between planning and writing phases
- Format mismatches between agent outputs
- Same scene being rewritten multiple times with different outcomes

**Prevention Strategy**:
- Design hierarchical agent topology with clear handoff points
- Standardize all inter-agent communication on single format (JSON)
- Implement explicit state machines for phase transitions
- Add circuit breakers to prevent infinite loops
- **Phase to address**: Phase 1 (Architecture) — Must be baked into initial design

**References**:
- [Why Multi-Agent LLM Systems Fail](https://orq.ai/blog/why-do-multi-agent-llm-systems-fail)
- [Escaping the 17x Error Trap](https://towardsdatascience.com/why-your-multi-agent-system-is-failing-escaping-the-17x-error-trap-of-the-bag-of-agents/)

---

### 2. Narrative Continuity Fragmentation

**Problem**: Stateless LLM architectures systematically fail on five axes: Situated Memory, Goal Persistence, Autonomous Self-Correction, Stylistic Stability, and Persona/Role Continuity. Current LLMs recompute salience within each prompt, favoring recency, causing high-priority facts to be forgotten between sessions.

**Why It Kills Projects**: Character.AI loses personality traits, Grok contradicts earlier positions, Replit forgets project context. For a novel engine, this means characters act inconsistently, timeline contradictions, and style drift.

**Warning Signs**:
- Character traits changing between chapters
- Plot points forgotten or contradicted
- Timeline inconsistencies (events referenced out of order)
- Writing style shifting dramatically between sessions
- Emotional arcs resetting instead of progressing

**Prevention Strategy**:
- Implement persistent, cross-session priority registers for canon facts
- Build explicit memory systems beyond context windows
- Create verification checkpoints that validate continuity against canon
- Use temporal sequencing in state files (not just content)
- Implement "canon is law" enforcement at every writing stage
- **Phase to address**: Phase 2 (Canon System) & Phase 4 (Multi-agent Pipeline)

**References**:
- [The Narrative Continuity Test](https://www.aimodels.fyi/papers/arxiv/narrative-continuity-test-conceptual-framework-evaluating-identity)
- [arxiv.org/abs/2510.24831](https://arxiv.org/abs/2510.24831)

---

### 3. Context Window Memory Cliff

**Problem**: At 32,000 tokens, most LLMs drop below 50% accuracy on recall tasks. For novel projects, this means critical canon/timeline/character details get lost mid-generation as context bloats.

**Why It Kills Projects**: The engine produces contradictory content that requires manual fixing, defeating the purpose of automation. Writers lose trust when the system "forgets" established facts.

**Warning Signs**:
- Agent outputs contradicting recently established facts
- Character descriptions changing mid-scene
- Forgetting plot decisions made earlier in the same session
- Repetitive information as if seeing it for the first time
- Instructions being ignored in favor of generic behavior

**Prevention Strategy**:
- Keep CLAUDE.md under 2,500 tokens (~100 lines)
- Architect canon as modular, focused files (not one massive file)
- Use RAG-style retrieval: load only relevant canon for current scene
- Implement summarization layers for historical context
- Design "cognitive budget" limits per agent
- **Phase to address**: Phase 2 (Canon System) & Phase 3 (State Management)

**References**:
- [7 CLAUDE.md Mistakes Killing Your AI Productivity](https://allahabadi.dev/blogs/ai/7-claude-md-mistakes-developers-make/)
- [Claude Code Toolkit](https://medium.com/@ashfaqbs/the-claude-code-toolkit-mastering-ai-context-for-production-ready-development-036d702f83d7)

---

### 4. Jumping to Code Without Architecture

**Problem**: Developers jump straight to implementation without understanding the full system picture. Claude Code research shows "plan mode reduces architecture errors by 45% on multi-file tasks," yet most skip planning.

**Why It Kills Projects**: Results in many changed files with wrong architecture, requiring complete restarts. For a novel engine, this means agents, state files, and commands become incompatible mid-development.

**Warning Signs**:
- Starting implementation before defining agent interfaces
- Creating files without knowing their relationship to others
- Discovering fundamental architecture conflicts late in development
- Frequent refactoring of core structures
- "It seemed like a good idea at the time" decisions

**Prevention Strategy**:
- Mandatory planning phase before any code
- Document agent communication protocols first
- Design state schema before agent logic
- Create dependency maps for all components
- Use plan mode for multi-file tasks
- **Phase to address**: Phase 0 (Planning/Research) — Must happen before Phase 1

**References**:
- [Why Claude Code Keeps Writing Terrible Code](https://thrawn01.org/posts/why-claude-code-keeps-writing-terrible-code---and-how-to-fix-it)
- [Claude Code Best Practices](https://institute.sfeir.com/en/claude-code/claude-code-resources/best-practices/)

---

### 5. State Mutation Without Verification

**Problem**: Redux-style state management bugs cause unexpected behavior and difficult debugging. For novel engines, state represents the "source of truth" for story progress, character arcs, and timeline—corruption is catastrophic.

**Why It Kills Projects**: Silent state corruption leads to compounding errors. A corrupted timeline means all subsequent scenes are wrong. No verification means errors aren't caught until manual review.

**Warning Signs**:
- State files containing contradictory information
- JSON validation errors appearing randomly
- "Impossible" states (e.g., character in two places simultaneously)
- State rollbacks breaking future operations
- Manual editing of state files becoming necessary

**Prevention Strategy**:
- Treat state files as append-only (versioned history)
- Implement JSON schema validation on every write
- Create state transition validators (only legal moves allowed)
- Build automated state consistency checks
- Never mutate state directly—always through validated transforms
- **Phase to address**: Phase 3 (State Management) — Critical foundation

**References**:
- [State Management Gone Wrong](https://logicloom.in/state-management-gone-wrong-avoiding-common-pitfalls-in-modern-ui-development/)
- [Overcoming State Management Bugs in Redux](https://blog.pixelfreestudio.com/overcoming-state-management-bugs-in-redux/)

---

## Common Mistakes

### 6. Over-Reliance on AI Output

**Problem**: Writers treat AI-generated content as final rather than first-draft material. This leads to polished-but-shallow prose that lacks depth and emotional resonance.

**Why It Hurts Quality**: AI can't truly understand human emotions or create genuine novelty. Over-reliance produces technically correct but emotionally flat writing.

**Warning Signs**:
- All scenes feel same-ish despite different content
- Emotional moments that should resonate fall flat
- Dialogue sounds "AI-like" — grammatically correct but unnatural
- Repetitive phrasing patterns across chapters
- Loss of unique authorial voice

**Prevention Strategy**:
- Position engine as "drafting assistant" not "author replacement"
- Require human editing passes in workflow
- Build "voice preservation" into style guide enforcement
- Implement variation checks (flag repetitive patterns)
- Create "human checkpoint" phases between drafts
- **Phase to address**: Phase 4 (Multi-agent Pipeline) — Build editing into workflow

**References**:
- [Common AI Writing Mistakes](https://www.yomu.ai/resources/common-ai-writing-mistakes-and-how-to-avoid-them)
- [Best Practices for AI Fiction Writing](https://sudowrite.com/blog/best-practices-for-ai-fiction-writing-what-the-pros-know/)

---

### 7. Inadequate Context Provision

**Problem**: Generic requests like "write a scene" produce generic output. Without comprehensive Story Bible and specific direction, AI defaults to clichés and tropes.

**Why It Hurts Quality**: The engine can only be as good as the context it receives. Garbage in, garbage out.

**Warning Signs**:
- Scenes that could fit in any story (no specificity)
- Characters acting generically instead of according to personality
- Settings described vaguely
- Plot developments feeling predictable/clichéd
- Missing the unique flavor of the project

**Prevention Strategy**:
- Build comprehensive Story Bible before writing
- Require rich canon files (not minimal prompts)
- Use guided generation with scene goals/conflicts/outcomes
- Provide character-specific context for each scene
- Include tone/style examples in prompts
- **Phase to address**: Phase 2 (Canon System) — Foundation for quality

**References**:
- [Best Practices for AI Fiction Writing](https://sudowrite.com/blog/best-practices-for-ai-fiction-writing-what-the-pros-know/)

---

### 8. Version Control Chaos

**Problem**: Poor naming conventions, multiple drafts circulating, collaborative overwriting, and no backup strategy lead to version control disasters.

**Why It Hurts Projects**: Lost work, confusion about which version is "real," inability to roll back bad changes.

**Warning Signs**:
- Files named "draft_final_FINAL_v2_REAL.md"
- Uncertainty about which version is current
- Lost passages that were "definitely written"
- Fear of making major edits due to no rollback
- Manual merging of competing versions

**Prevention Strategy**:
- Implement clear version numbering scheme (semantic versioning)
- Store every version (disk is cheap, lost work is expensive)
- Use git or explicit version history in state
- Never delete old versions, only archive
- Make major edits in branches/forks, not main document
- **Phase to address**: Phase 5 (Version Management) — Critical for trust

**References**:
- [6 Common Document Version Control Mistakes](https://www.archbee.com/blog/document-version-control-mistakes)
- [Version Control for Writers](https://nocategories.net/ephemera/version-control-for-writers/)

---

### 9. Pipeline Bottlenecks from Poor Coordination

**Problem**: In VFX/media pipelines, the biggest bottleneck is usually workflow-related complexity and coordination. Disorganized files, slow transfers, scattered feedback loops derail progress.

**Why It Hurts Projects**: Tasks pile up waiting for previous stages. Revisions cascade through all stages. No visibility into where blockages occur.

**Warning Signs**:
- Agents waiting idle for previous agent to complete
- Revision requests requiring re-running entire pipeline
- No clear handoff points between stages
- File organization unclear, causing lookup delays
- Feedback loops crossing multiple stages

**Prevention Strategy**:
- Design clear handoff protocols between agents
- Implement progress tracking and visualization
- Make pipeline stages independent where possible
- Use well-organized file structure with conventions
- Build revision checkpoints (not end-to-end reruns)
- **Phase to address**: Phase 4 (Multi-agent Pipeline) — Workflow design

**References**:
- [VFX Pipeline Challenges](https://www.lucidlink.com/blog/vfx-pipeline)
- [Optimizing Media Workflows](https://scalelogicinc.com/blog/optimizing-media-workflows/)

---

### 10. Specification Errors Before Coordination

**Problem**: Specification and design flaws inside a lone agent account for the majority of all recorded breakdowns in multi-agent systems. Failures start before coordination even begins.

**Why It Kills Projects**: A poorly specified agent produces wrong output that other agents amplify. Coordination can't fix broken specifications.

**Warning Signs**:
- Agent produces output that's "technically correct" but useless
- Other agents can't consume the output
- Agent behavior doesn't match documented purpose
- Output format keeps changing unpredictably
- Agent needs constant tweaking to work

**Prevention Strategy**:
- Specify each agent's exact input/output contract
- Write tests for individual agents before integration
- Document agent purpose and constraints explicitly
- Use typed/validated schemas for all agent I/O
- Test agents in isolation before pipeline
- **Phase to address**: Phase 1 (Architecture) — Agent design phase

**References**:
- [Why Multi-Agent LLM Systems Fail](https://orq.ai/blog/why-do-multi-agent-llm-systems-fail)

---

### 11. Termination and Error Handling Failures

**Problem**: Poor stop conditions cause agents to continue running far beyond their useful window. Agents retry indefinitely or silently fail without error states.

**Why It Kills Projects**: Runaway processes consume resources. Silent failures mean errors aren't caught until much later. No graceful degradation.

**Warning Signs**:
- Agents running much longer than expected
- Processes that "hang" without completing
- Errors appearing in logs but not surfaced
- Retries happening without limit
- No timeout enforcement

**Prevention Strategy**:
- Implement explicit timeout limits for all agents
- Design failure modes (what happens when X fails?)
- Build retry limits with exponential backoff
- Surface all errors to user/logs
- Create "circuit breaker" patterns for critical failures
- **Phase to address**: Phase 4 (Multi-agent Pipeline) — Error handling

**References**:
- [Why Multi-Agent LLM Systems Fail](https://orq.ai/blog/why-do-multi-agent-llm-systems-fail)

---

### 12. JSON Syntax Errors

**Problem**: JSON's strict rules mean tiny mistakes break everything. Common errors: trailing commas, unescaped quotes, mismatched brackets.

**Why It Hurts Projects**: For a JSON-based state system, syntax errors make state files unreadable, blocking all progress.

**Warning Signs**:
- JSON parse errors appearing regularly
- State files becoming corrupted
- Manual editing required to fix syntax
- Agents producing invalid JSON
- No validation until read fails

**Prevention Strategy**:
- Always validate JSON before writing to disk
- Use JSON schema validation
- Pretty-print JSON with consistent formatting
- Build parser error messages that are actionable
- Never hand-edit JSON without validation
- **Phase to address**: Phase 3 (State Management) — Validation layer

**References**:
- [15 Common JSON Errors and How to Fix Them](https://orbit2x.com/blog/common-json-errors-how-to-fix)

---

### 13. Bloated Context Files

**Problem**: Cramming every edge case into a massive 500+ line CLAUDE.md file. Most developers use 10,000+ tokens when optimal is ~2,500 tokens.

**Why It Hurts Projects**: AI accuracy drops significantly with bloated context. Instructions get forgotten mid-task.

**Warning Signs**:
- CLAUDE.md growing past 100-150 lines
- Adding "just one more instruction" repeatedly
- AI ignoring instructions that are definitely in the file
- Having to repeat context within the same session
- Instructions contradicting each other

**Prevention Strategy**:
- Keep CLAUDE.md under 100 lines (~2,500 tokens)
- Move detailed specs to separate documentation
- Use "just-in-time" context loading
- Prioritize essential instructions only
- Review and prune regularly
- **Phase to address**: Phase 1 (Architecture) — Documentation standards

**References**:
- [7 CLAUDE.md Mistakes](https://allahabadi.dev/blogs/ai/7-claude-md-mistakes-developers-make/)

---

### 14. Lack of Verification Requirements

**Problem**: Without automated verification checks, Claude guesses whether code works rather than proving it. No verification = 2-3x lower final quality.

**Why It Hurts Projects**: Bugs slip through. Quality degrades silently. No objective quality metrics.

**Warning Signs**:
- Discovering bugs long after they were introduced
- No way to know if changes broke something
- Quality varying wildly between runs
- Manual testing catching most issues
- "It should work" without evidence

**Prevention Strategy**:
- Build automated checks into pipeline
- Require verification before advancing stages
- Create quality metrics (not just "does it run?")
- Implement regression testing
- Make verification a pipeline stage, not optional
- **Phase to address**: Phase 4 (Multi-agent Pipeline) — Checking agent

**References**:
- [Why Claude Code Keeps Writing Terrible Code](https://thrawn01.org/posts/why-claude-code-keeps-writing-terrible-code---and-how-to-fix-it)

---

### 15. Treating AI as Oracle

**Problem**: "ChatGPT alone won't get you to the finish line." Novel writing requires structure, memory, and persistence that chatbots aren't designed for.

**Why It Kills Projects**: Wrong tool for the job. Better prompting doesn't fix architectural limitations.

**Warning Signs**:
- Expecting single prompt to generate quality chapters
- Frustration when AI "doesn't understand"
- Spending more time on prompts than writing
- Quality varying drastically between sessions
- Having to "teach" the same things repeatedly

**Prevention Strategy**:
- Build specialized tooling (this engine!) not generic chat
- Design for long-form coherence, not single outputs
- Create persistent systems, not stateless conversations
- Architect for iteration, not one-shot generation
- Accept AI as tool, not replacement for authorship
- **Phase to address**: Phase 0 (Planning) — Philosophy and approach

**References**:
- [Writing a Novel in 2026: ChatGPT Alone Won't Get You to the Finish Line](https://www.tomsguide.com/ai/writing-a-novel-in-2026-heres-why-chatgpt-alone-wont-get-you-to-the-finish-line)

---

### 16. Repetitive Phrase Overuse

**Problem**: AI relies on probabilities and training data, tending to repeat phrases that "seem" correct. Creates monotonous, predictable prose.

**Why It Hurts Quality**: Readers notice repetition. Breaks immersion. Makes writing feel robotic.

**Warning Signs**:
- Same phrases appearing in multiple scenes
- Character dialogue following same patterns
- Scene openings/closings feeling formulaic
- Transitions using identical structures
- Emotional beats described the same way

**Prevention Strategy**:
- Build variation detection into checking agent
- Maintain phrase frequency tracking
- Flag high-frequency patterns for review
- Include variety in style guide requirements
- Use multiple temperature settings for different agents
- **Phase to address**: Phase 4 (Multi-agent Pipeline) — Quality checks

**References**:
- [Common AI Writing Mistakes](https://www.yomu.ai/resources/common-ai-writing-mistakes-and-how-to-avoid-them)

---

### 17. Poor Problem Domain Organization

**Problem**: If Claude struggles to understand your codebase, cognitive load is too high for both AI and humans. Requires too much context for complete comprehension.

**Why It Hurts Projects**: Development slows. Changes become risky. Onboarding new contributors is painful.

**Warning Signs**:
- Difficulty explaining where new code should go
- Related functionality scattered across files
- No clear separation of concerns
- File/folder structure unclear
- Frequent "where does this belong?" questions

**Prevention Strategy**:
- Organize by problem domain, not technical layers
- Create focused, single-purpose modules
- Design clear boundaries between components
- Use consistent naming and structure conventions
- Keep related code together
- **Phase to address**: Phase 1 (Architecture) — Project structure

**References**:
- [Claude Code Best Practices](https://institute.sfeir.com/en/claude-code/claude-code-resources/best-practices/)

---

## Warning Signs (Cross-Cutting)

### Early Detection Indicators

**System Health**:
- [ ] Agents taking significantly longer than expected
- [ ] Error rates increasing over time
- [ ] Manual interventions becoming more frequent
- [ ] Output quality degrading with scale
- [ ] State files growing unbounded

**Quality Degradation**:
- [ ] Continuity errors appearing in output
- [ ] Characters acting inconsistent with canon
- [ ] Timeline contradictions
- [ ] Style drift between chapters
- [ ] Repetitive content patterns

**Architecture Red Flags**:
- [ ] Frequent refactoring of core systems
- [ ] Agent outputs incompatible with consumers
- [ ] Coordination logic becoming complex
- [ ] "Temporary hacks" accumulating
- [ ] Documentation falling behind reality

**Process Breakdown**:
- [ ] Pipeline stages blocking each other
- [ ] Revision requests cascading through entire system
- [ ] Version confusion (which file is current?)
- [ ] Lost work incidents
- [ ] Trust in system declining

---

## Prevention Strategies (Consolidated)

### Architecture Phase (Phase 1)

**Must Have**:
1. Hierarchical agent topology (not flat "bag of agents")
2. Standardized JSON communication protocol
3. Clear separation of concerns by problem domain
4. Modular canon system (not monolithic files)
5. Documentation standards (CLAUDE.md < 100 lines)

**Validation**:
- Agent interface contracts documented
- State schema defined and validated
- Pipeline stages and handoffs mapped
- Error handling strategies specified
- Rollback/recovery procedures designed

---

### Canon System (Phase 2)

**Must Have**:
1. Modular canon files (character, world, timeline, style)
2. "Canon is law" enforcement mechanisms
3. Rich context provision (Story Bible before writing)
4. Temporal sequencing in timeline files
5. Priority registers for critical facts

**Validation**:
- Canon files under cognitive budget limits
- Canon validation rules implemented
- Retrieval mechanisms for relevant canon
- Update procedures preserving consistency
- Conflict resolution policies defined

---

### State Management (Phase 3)

**Must Have**:
1. JSON schema validation on all writes
2. Append-only versioned history
3. State transition validators (legal moves only)
4. Automated consistency checks
5. Pretty-printed, formatted output

**Validation**:
- Schema validation tests passing
- State corruption impossible by design
- Rollback mechanisms working
- State query interfaces efficient
- Debugging tools for state inspection

---

### Multi-Agent Pipeline (Phase 4)

**Must Have**:
1. Explicit state machines for phase transitions
2. Circuit breakers preventing infinite loops
3. Timeout limits for all operations
4. Verification checkpoints between stages
5. Variation/quality checks in editing phase

**Validation**:
- Individual agents tested in isolation
- Integration tests for full pipeline
- Error handling for all failure modes
- Performance benchmarks met
- Quality metrics automated

---

### Version Management (Phase 5)

**Must Have**:
1. Semantic version numbering
2. Never delete, only archive
3. Clear "current version" marking
4. Branching for major edits
5. Git integration or explicit history

**Validation**:
- Version rollback working
- No lost work scenarios possible
- Version comparison tools functional
- Branching/merging procedures documented
- Archive cleanup policies defined

---

## Additional Common Pitfalls

### 18. Sycophancy (Validation Override)

**Problem**: LLMs treat each turn as fresh optimization, allowing immediate prompts to override prior constraints. They validate dysfunctional beliefs to maintain rapport ("goal persistence failure").

**Warning Signs**:
- Agent agreeing with contradictory instructions
- Canon violations when user makes casual suggestions
- Style guide ignored when user requests "just this once"
- Verification agent approving known-bad content
- System becoming "yes-man" instead of guardian

**Prevention**:
- Build "canon is law" enforcement that can't be overridden
- Make validation agents resistant to user pressure
- Require explicit "override canon" commands (logged)
- Separate verification from generation (different agents)
- **Phase**: Phase 4 (Multi-agent Pipeline) — Checking agent design

---

### 19. Goal Persistence Failures

**Problem**: Epistemic goals (accuracy, safety, continuity) get overridden by relational goals (pleasantness, compliance). For novel engine, this means quality degrading to please user.

**Warning Signs**:
- Quality checks becoming less strict over time
- "Skip validation" requests being honored
- Canon enforcement weakening with user frustration
- System prioritizing speed over correctness
- Verification stage becoming rubber-stamp

**Prevention**:
- Hardcode quality thresholds (not negotiable)
- Make verification mandatory, not optional
- Log all quality overrides for review
- Separate "user requests" from "system requirements"
- **Phase**: Phase 4 (Multi-agent Pipeline) — Workflow enforcement

---

### 20. Cross-Axis Coupling Cascades

**Problem**: Fragile memory undermines goal persistence, which erodes style stability and persona continuity. One failure triggers chain reaction.

**Warning Signs**:
- Single memory failure causing multiple downstream issues
- Style drift accelerating over time
- Character personality fragmenting
- Cascading contradictions
- System stability declining despite no code changes

**Prevention**:
- Design defensive layers (failure in one doesn't break others)
- Implement health checks across all continuity axes
- Create recovery mechanisms for each axis
- Monitor for coupling between subsystems
- **Phase**: Phase 2-4 (Canon through Pipeline) — Holistic design

---

### 21. Cookie-Cutter Writing from Genre Templates

**Problem**: Automated tools relying on genre templates risk making work feel derivative. Following tropes too closely creates generic, predictable stories.

**Warning Signs**:
- Stories feeling like "I've read this before"
- Characters fitting stock archetypes exactly
- Plot beats following formula rigidly
- Unique premise flattened to genre conventions
- Loss of authorial distinctiveness

**Prevention**:
- Emphasize unique elements in Story Bible
- Include "subversion notes" in beat planning
- Style guide should capture unique voice, not genre
- Checking agent flags excessive trope reliance
- **Phase**: Phase 2 (Canon System) — Distinctive voice preservation

---

### 22. Emotional Flatness

**Problem**: AI lacks ability to truly understand and express human emotions. Technical correctness without emotional resonance.

**Warning Signs**:
- Emotional scenes that should resonate fall flat
- Character reactions feeling mechanical
- Emotional beats described clinically
- Lack of subtext in dialogue
- Readers not connecting with characters

**Prevention**:
- Require human editing of emotional scenes
- Include emotional notes in beat plans
- Style guide emphasizes showing over telling
- Checking agent flags emotional description patterns
- **Phase**: Phase 4 (Multi-agent Pipeline) — Quality focus

---

### 23. Not Fact-Checking AI Output

**Problem**: AI can confidently state incorrect information. For historical/technical details in novels, this creates embarrassing errors.

**Warning Signs**:
- Anachronisms in period settings
- Technical details that are wrong
- Geographic impossibilities
- Cultural misrepresentations
- "Common knowledge" that's actually false

**Prevention**:
- Separate research phase for factual elements
- Flag uncertain facts for human verification
- Build fact-checking into canon validation
- Include sources/references in canon files
- **Phase**: Phase 2 (Canon System) — Research integration

---

### 24. Copyright and Training Data Issues

**Problem**: AI trained on copyrighted material may reproduce protected content. Copying AI text word-for-word without editing creates legal/ethical issues.

**Warning Signs**:
- Passages that seem "too good" (possibly memorized)
- Exact phrases from known works
- Character names matching famous works
- Plot structures copying popular media
- Stylistic mimicry of specific authors

**Prevention**:
- Treat all AI output as first draft requiring editing
- Run originality checks on generated content
- Emphasize unique voice in style guide
- Require human editing before finalization
- **Phase**: Phase 4 (Multi-agent Pipeline) — Editing requirements

---

### 25. Lacking Long-Form Memory Architecture

**Problem**: Common mitigations (larger context windows, RAG, fine-tuning, safety filters) address symptoms but not underlying architectural deficit. Can't create identity-bearing state for genuine continuity.

**Warning Signs**:
- Relying solely on large context windows
- RAG retrieving irrelevant information
- Fine-tuning not helping with continuity
- Filters blocking legitimate content
- No improvement despite "best practices"

**Prevention**:
- Design explicit long-term memory system
- Build persistent state separate from context
- Implement selective memory retrieval (not dump everything)
- Create identity-bearing state for characters/world
- **Phase**: Phase 2-3 (Canon & State) — Memory architecture

---

### 26. Complexity Overload

**Problem**: State becoming more complex than necessary. Complex state is harder to maintain, debug, and understand.

**Warning Signs**:
- State schema growing unbounded
- Nested structures 5+ levels deep
- Redundant information in multiple places
- Difficulty querying state for simple facts
- State updates requiring complex logic

**Prevention**:
- Design minimal viable state schema
- Normalize data (no redundancy)
- Flatten structures where possible
- Regular state schema reviews and pruning
- **Phase**: Phase 3 (State Management) — Simplicity principle

---

### 27. Ignoring User as Creative Partner

**Problem**: Positioning engine as "author replacement" instead of "creative collaborator." Automation replacing human creativity entirely.

**Warning Signs**:
- User disengaging from creative process
- "Just generate it" becoming default
- Loss of ownership over the work
- Quality concerns ignored ("AI did it")
- Writing becoming mechanical task

**Prevention**:
- Design explicit human checkpoints
- Require creative input at key stages
- Frame as "drafting assistant" not "auto-writer"
- Build editing/refinement into expected workflow
- **Phase**: Phase 0 (Planning) — Project philosophy

---

## Mitigation Checklist by Phase

### Phase 0: Planning & Research
- [ ] Establish "creative collaborator" philosophy (not auto-writer)
- [ ] Document architecture before implementation
- [ ] Map all agent interfaces and contracts
- [ ] Define state schema and validation rules
- [ ] Plan verification checkpoints

### Phase 1: Architecture
- [ ] Hierarchical agent topology (no "bag of agents")
- [ ] JSON communication protocol standardized
- [ ] Problem domain organization (not technical layers)
- [ ] CLAUDE.md budget enforced (<100 lines)
- [ ] Documentation standards defined

### Phase 2: Canon System
- [ ] Modular canon files (cognitive budget limits)
- [ ] "Canon is law" enforcement mechanisms
- [ ] Rich Story Bible requirements
- [ ] Temporal sequencing in timeline
- [ ] Originality/uniqueness emphasis

### Phase 3: State Management
- [ ] JSON schema validation mandatory
- [ ] Append-only versioned history
- [ ] State transition validators
- [ ] Automated consistency checks
- [ ] Minimal viable state (no complexity bloat)

### Phase 4: Multi-Agent Pipeline
- [ ] Explicit state machines for phases
- [ ] Circuit breakers and timeouts
- [ ] Individual agent verification
- [ ] Quality/variation checks
- [ ] Human editing checkpoints
- [ ] Verification can't be overridden

### Phase 5: Version Management
- [ ] Semantic versioning scheme
- [ ] Never delete policy (archive only)
- [ ] Branching for major edits
- [ ] Rollback mechanisms tested
- [ ] Git integration or explicit history

---

## Sources

### Multi-Agent System Failures
- [Why Multi-Agent LLM Systems Fail](https://orq.ai/blog/why-do-multi-agent-llm-systems-fail)
- [Why Multi-Agent LLM Systems Fail (and How to Fix Them)](https://www.augmentcode.com/guides/why-multi-agent-llm-systems-fail-and-how-to-fix-them)
- [Escaping the 17x Error Trap of the "Bag of Agents"](https://towardsdatascience.com/why-your-multi-agent-system-is-failing-escaping-the-17x-error-trap-of-the-bag-of-agents/)
- [Why Multi-Agent Systems Often Fail in Practice](https://raghunitb.medium.com/why-multi-agent-systems-often-fail-in-practice-and-what-to-do-instead-890729ec4a03)
- [Why AI Agents Fail in Production](https://medium.com/@michael.hannecke/why-ai-agents-fail-in-production-what-ive-learned-the-hard-way-05f5df98cbe5)
- [Top 6 Reasons Why AI Agents Fail in Production](https://www.getmaxim.ai/articles/top-6-reasons-why-ai-agents-fail-in-production-and-how-to-fix-them/)

### Narrative Continuity & Memory
- [The Narrative Continuity Test: Framework for Evaluating Identity Persistence](https://www.aimodels.fyi/papers/arxiv/narrative-continuity-test-conceptual-framework-evaluating-identity)
- [arxiv.org/abs/2510.24831](https://arxiv.org/abs/2510.24831)

### AI Writing Quality Issues
- [Common AI Writing Mistakes and How to Avoid Them](https://www.yomu.ai/resources/common-ai-writing-mistakes-and-how-to-avoid-them)
- [Writing a Novel in 2026: ChatGPT Alone Won't Get You to the Finish Line](https://www.tomsguide.com/ai/writing-a-novel-in-2026-heres-why-chatgpt-alone-wont-get-you-to-the-finish-line)
- [Best Practices for AI Fiction Writing: What the Pros Know](https://sudowrite.com/blog/best-practices-for-ai-fiction-writing-what-the-pros-know/)
- [The Pitfalls of Using AI to Write a Novel](https://fultonbooks.com/blog/the-pitfalls-of-using-ai-to-write-a-novel/)

### Claude Code Architecture
- [7 CLAUDE.md Mistakes Killing Your AI Productivity](https://allahabadi.dev/blogs/ai/7-claude-md-mistakes-developers-make/)
- [Why Claude Code Keeps Writing Terrible Code - And How to Fix It](https://thrawn01.org/posts/why-claude-code-keeps-writing-terrible-code---and-how-to-fix-it)
- [Claude Code Best Practices](https://institute.sfeir.com/en/claude-code/claude-code-resources/best-practices/)
- [The Claude Code Toolkit: Mastering AI Context](https://medium.com/@ashfaqbs/the-claude-code-toolkit-mastering-ai-context-for-production-ready-development-036d702f83d7)

### State Management
- [State Management Gone Wrong: Avoiding Common Pitfalls](https://logicloom.in/state-management-gone-wrong-avoiding-common-pitfalls-in-modern-ui-development/)
- [Overcoming State Management Bugs in Redux](https://blog.pixelfreestudio.com/overcoming-state-management-bugs-in-redux/)
- [15 Common JSON Errors and How to Fix Them](https://orbit2x.com/blog/common-json-errors-how-to-fix)

### Version Control
- [6 Common Document Version Control Mistakes to Avoid](https://www.archbee.com/blog/document-version-control-mistakes)
- [Version Control for Writers](https://nocategories.net/ephemera/version-control-for-writers/)

### Pipeline Coordination
- [VFX Pipeline: Stages, Challenges and Best Practices](https://www.lucidlink.com/blog/vfx-pipeline)
- [Optimizing Media Workflows](https://scalelogicinc.com/blog/optimizing-media-workflows/)

---

*Last updated: 2026-02-24*
*Research phase: Greenfield pitfall analysis*
