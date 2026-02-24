# Novel Engine

## What This Is

Claude Code에서 소설을 작성하기 위한 멀티 에이전트 엔진. 일기체, 장회소설, 단편, 연재물 등 다양한 형식을 지원하며, 캐릭터/세계관 일관성을 유지하고 버전 관리를 제공한다. `/novel:*` 명령어로 Claude Code 세션 내에서 사용한다.

## Core Value

**일관성 있는 소설 작성** — 캐릭터, 세계관, 타임라인이 흐트러지지 않고 유지되면서 자연스러운 이야기가 전개되는 것이 핵심. 특히 일기체 소설에서 날짜/계절/감정 아크가 자연스럽게 흘러가야 한다.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] 다양한 소설 형식 지원 (일기체, 장회소설, 단편, 연재물)
- [ ] 캐논 시스템 (캐릭터, 세계관, 타임라인, 스타일 가이드)
- [ ] 상태 관리 (JSON 기반 진행 상황 추적)
- [ ] 일기체 특화 기능 (날짜/시간 추적, 계절/날씨 변화, 감정 아크, 성장 마일스톤)
- [ ] 멀티 에이전트 파이프라인 (기획 → 집필 → 검수 → 퇴고)
- [ ] Claude Code 스킬 통합 (`/novel:init`, `/novel:write`, `/novel:check`, `/novel:status`)
- [ ] 버전 관리 (초고/퇴고 이력)
- [ ] Markdown 출력
- [ ] EPUB 내보내기

### Out of Scope

- 웹 인터페이스 — Claude Code 내부에서만 사용
- 실시간 협업 — 단일 사용자 워크플로우
- AI 이미지 생성 — 텍스트 소설에 집중

## Context

### 기존 novel-engine 분석

`novel-engine/` 디렉토리에 참조용 구조가 있음:
- `canon/` — 진실의 원천 (premise, world, characters, style_guide, timeline, constraints)
- `state/` — JSON 상태 파일 (story, character, timeline, style)
- `beats/` — 플롯 설계 (outline, act_structure, beat_plan)
- `draft/` — 원고 (chapters, scenes)
- `agents/` — 10개 전문 에이전트 (plot_planner, scene_writer, canon_checker 등)
- `commands/` — 워크플로우 단계 (init → outline → beats → draft → checks → rewrite → publish)

### 개선 방향

1. **일기체 지원 강화** — 기존은 장/씬 구조만 지원. 날짜별 일기 형식 추가 필요
2. **Claude Code 스킬 통합** — 현재는 수동 실행. `/novel:*` 명령어로 자동화
3. **버전 관리** — 초고/퇴고 이력 추적 기능 추가

### 예시 프로젝트

제주 중학생이 만원 버스 대신 걷기를 시작해 1년 만에 마라톤 풀코스를 완주하는 이야기. 일기체 소설로, 매주 2회 일기를 쓰며 계절 변화와 감정 성장을 담는다.

## Constraints

- **Tech Stack**: Claude Code 스킬 시스템 (`.claude/skills/` 또는 `.claude/commands/`)
- **개발 위치**: `claude_src/` 디렉토리
- **상태 관리**: JSON 파일 기반 (DB 없음)
- **출력 형식**: Markdown (1차), EPUB 변환 (2차)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| 기존 novel-engine 참고하되 새로 설계 | 일기체/명령어/버전관리 등 구조적 변경 필요 | — Pending |
| JSON 기반 상태 관리 | 파일 기반으로 단순하고 git 추적 가능 | — Pending |
| Claude Code 스킬로 구현 | 사용자가 `/novel:*` 명령어로 쉽게 사용 | — Pending |

---
*Last updated: 2026-02-24 after initialization*
