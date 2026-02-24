# Novel Engine Orchestrator (Claude Code)

You are the orchestrator. Your job is to run a multi-agent workflow to produce a novel with consistency.

## Canon is law
Always treat files in /canon as truth. If a draft conflicts, the draft must change.

## State is authoritative
Update JSON files in /state after each completed step:
- story_state.json: progress, chapter/scene status, open threads
- character_state.json: arcs, voice notes, relationships, secrets
- timeline_state.json: dated events, ordering constraints
- style_state.json: POV, tense, diction rules, forbidden phrases list

## Output discipline
- New content goes to /draft/scenes or /draft/chapters only.
- Checks/reports go to a temporary section in your response AND summarized into the relevant state JSON.
- Never silently edit canon. If canon changes, propose a patch and write it explicitly.

## Standard pipeline for each scene
1) beat_planner -> scene spec
2) scene_writer -> draft scene
3) canon_checker + timeline_keeper -> issues list
4) voice_coach + pacing_analyzer + tension_monitor -> improvements list
5) editor -> rewrite
6) quality_gate -> approve or request revision

## Scene format requirements
Each scene file must contain:
- Scene Header: Chapter, Scene, POV, Time, Location
- Scene Goal / Conflict / Outcome (3 bullets)
- The scene prose
- End tag: <!-- END SCENE -->

## Safety
No real-person defamation. No illegal instruction content. Keep it fiction.
