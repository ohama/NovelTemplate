# novel-engine vs claude_src 비교

*원본 참조 구현과 새 Novel Engine의 차이점*

---

## 개요

| 항목 | novel-engine/ | claude_src/ |
|------|---------------|-------------|
| 목적 | 참조용 템플릿 | 배포 가능한 완성품 |
| 명령어 | 수동 실행 가이드 | `/novel:*` 슬래시 명령어 |
| 상태 관리 | 수동 JSON 편집 | JSON Schema + 자동화 |
| 일기체 지원 | 없음 | 완전 지원 |
| 버전 관리 | 없음 | 스냅샷/diff/롤백 |
| 출력 | Markdown만 | Markdown + EPUB |

---

## 디렉토리 구조 비교

### novel-engine/ (원본)

```
novel-engine/
├── CLAUDE.md          ← 오케스트레이터 지시문 (수동)
├── README.md
├── canon/             ← 설정 파일 (직접 편집)
│   ├── premise.md
│   ├── characters.md
│   ├── world.md
│   ├── timeline.md
│   ├── style_guide.md
│   └── constraints.md
├── state/             ← JSON 상태 (수동 관리)
│   ├── story_state.json
│   ├── character_state.json
│   ├── timeline_state.json
│   └── style_state.json
├── beats/             ← 플롯 구조 (수동 생성)
│   ├── outline.md
│   ├── act_structure.md
│   └── beat_plan.md
├── draft/             ← 원고
│   ├── scenes/
│   └── chapters/
├── agents/            ← 에이전트 역할 정의 (10개)
└── commands/          ← 실행 가이드 (번호순)
    ├── 00_init.md
    ├── 10_outline.md
    ├── 20_beats.md
    ├── 30_scene_draft.md
    ├── 40_checks.md
    ├── 50_rewrite.md
    └── 60_publish.md
```

### claude_src/ (새 구현)

```
claude_src/
├── commands/novel/    ← 슬래시 명령어 (자동화)
│   ├── init.md           /novel:init
│   ├── start.md          /novel:start     ← 빠른 시작
│   ├── status.md         /novel:status
│   ├── outline.md        /novel:outline
│   ├── write.md          /novel:write
│   ├── check.md          /novel:check
│   └── publish.md        /novel:publish
└── novel/
    ├── agents/        ← 에이전트 정의 (13개)
    │   ├── plot-planner.md
    │   ├── beat-planner.md
    │   ├── diary-planner.md      ← 신규
    │   ├── scene-writer.md
    │   ├── canon-checker.md
    │   ├── timeline-keeper.md
    │   ├── voice-coach.md
    │   ├── pacing-analyzer.md
    │   ├── tension-monitor.md
    │   ├── plot-coherence-checker.md  ← 신규
    │   ├── story-quality-agent.md     ← 신규
    │   ├── novel-editor.md
    │   └── novel-quality-gate.md
    ├── skills/        ← 유틸리티 스킬 (신규)
    │   ├── state-manager.md
    │   ├── git-integration.md
    │   ├── version-manager.md
    │   └── epub-generator.md
    ├── schemas/       ← JSON Schema (신규)
    │   ├── story_state.schema.json
    │   ├── story_state.default.json
    │   └── ...
    ├── templates/     ← 캐논 템플릿 + 디렉토리 구조
    │   ├── premise.md
    │   ├── characters.md
    │   ├── epub/          ← EPUB 템플릿 (신규)
    │   └── directories/   ← 디렉토리 README (신규)
    └── utils/
        └── state-manager.md
```

---

## 명령어 비교

### novel-engine (수동)

```
사용자가 직접 읽고 실행:

1. commands/00_init.md 읽기
2. 지시대로 canon/ 파일 작성
3. commands/10_outline.md 읽기
4. Claude에게 "outline 만들어줘" 요청
5. 결과를 수동으로 beats/에 저장
... 반복 ...
```

**00_init.md 내용 (9줄):**
```markdown
# Init
1) Fill canon/premise.md, canon/style_guide.md, canon/constraints.md
2) Create initial characters/world/timeline skeletons
3) Ensure state/*.json matches canon

Deliverable:
- canon files populated
- state JSONs initialized
```

### claude_src (자동화)

```
슬래시 명령어로 실행:

/novel:start             ← 브리프 → 프로젝트+캐논+아웃라인 원스텝 (권장)
/novel:init              ← 디렉토리 생성, 템플릿 복사, git 초기화
(사용자가 canon/ 편집)
/novel:outline           ← 에이전트 자동 호출, 상태 업데이트
/novel:write             ← 씬 자동 작성, 커밋
/novel:check             ← 7개 체커 병렬 실행
/novel:publish           ← EPUB 생성
```

**init.md 내용 (700+ 줄):**
- Pre-flight validation (권한, 디스크 공간)
- 디렉토리 구조 자동 생성
- JSON Schema 기반 상태 파일 초기화
- 캐논 템플릿 복사
- Git 자동 초기화
- Interactive 모드 지원
- 상세한 에러 메시지

---

## 에이전트 비교

### novel-engine 에이전트 (간단)

**scene_writer.md (12줄):**
```markdown
Role: Scene Writer
Goal: write one scene based strictly on Scene Spec.

Rules:
- Follow canon/style_guide.md
- No retroactive changes. Write new scene only.
- Show > tell. Avoid exposition dumps.
- End with <!-- END SCENE -->

Output:
- draft/scenes/chXX_sYY.md
```

### claude_src 에이전트 (상세)

**scene-writer.md (800+ 줄):**
```markdown
---
allowed-tools: [Read, Write, Bash, Glob, Grep]
description: Write one scene based on beat sheet specification
---

<role>
You are the **Scene Writer Agent**...
</role>

<inputs>
## Required Inputs
1. Beat sheet for current scene
2. Previous scene content (for continuity)
3. Canon files (characters, style_guide)
4. State files (story_state, character_state)
</inputs>

<execution>
## Step 1: Load Context
...
## Step 2: Analyze Beat Sheet
...
## Step 3: Write Prose
### For Diary Format:
- Use first-person retrospective voice
- Include date, day of week, weather
- Track emotional state
### For Chapter Format:
- Follow POV rules
- Scene header format
...
## Step 4: Update State
...
</execution>

<examples>
## Example: Diary Entry
...
## Example: Chapter Scene
...
</examples>
```

---

## 상태 관리 비교

### novel-engine (수동)

```json
// state/story_state.json (수동 편집 필요)
{
  "project": {
    "title": "Untitled Novel",
    "version": "0.1"
  },
  "progress": {
    "outline": "not_started",
    "beat_plan": "not_started",
    "draft": "not_started"
  },
  "current": {
    "chapter": 1,
    "scene": 1
  },
  "scene_index": []
}
```

- 스키마 없음 → 오타/구조 오류 가능
- 수동 업데이트 → 상태 불일치 위험
- 버전 정보 없음 → 마이그레이션 불가

### claude_src (자동화)

```json
// schemas/story_state.schema.json (JSON Schema Draft 2020-12)
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["schema_version", "project", "progress"],
  "properties": {
    "schema_version": {"type": "string"},
    "project": {
      "type": "object",
      "properties": {
        "title": {"type": "string"},
        "format": {"enum": ["chapter", "diary", "short", "serial"]},
        "git_integration": {...}
      }
    },
    "versions": {
      "type": "object",
      "properties": {
        "snapshots": {"type": "array"},
        "last_snapshot": {"type": "string"}
      }
    }
  }
}
```

- JSON Schema로 구조 검증
- `schema_version`으로 마이그레이션 지원
- state-manager 스킬로 자동 업데이트

---

## 주요 신규 기능

### 1. 일기체 지원

**novel-engine:** 지원 안 함

**claude_src:**
- `format: "diary"` 옵션
- diary-planner 에이전트 (날짜별 계획)
- 날짜/요일/계절/날씨 자동 생성
- 1인칭 회고체 톤 유지
- 감정 아크 추적

### 2. 버전 관리

**novel-engine:** 지원 안 함

**claude_src:**
- version-manager 스킬
- 자동 스냅샷 (revision_cycle, pre_publish)
- word-level diff (`git diff --word-diff`)
- 씬 단위 롤백
- 스냅샷 목록/삭제

### 3. EPUB 출판

**novel-engine:** Markdown만 출력

**claude_src:**
- epub-generator 스킬
- Pandoc 통합
- Dublin Core 메타데이터
- 한국어/일본어/중국어 CSS 최적화
- epubcheck 검증 (선택)

### 4. Git 통합

**novel-engine:** 수동

**claude_src:**
- git-integration 스킬
- canon 변경 자동 커밋
- 씬 작성 후 자동 커밋
- 커밋 메시지 표준화

### 5. 품질 검사 병렬화

**novel-engine:** 순차 실행 (수동)

**claude_src:**
- 7개 체커 병렬 실행 (Task 도구)
- 심각도별 분류 (CRITICAL/MAJOR/MINOR)
- 타임스탬프 리포트 저장
- novel-editor + novel-quality-gate 추가
- plot-coherence-checker (복선 추적) 추가
- story-quality-agent (서사 품질) 추가

---

## 명명 규칙 변경

| novel-engine | claude_src | 이유 |
|--------------|------------|------|
| `scene_writer.md` | `scene-writer.md` | kebab-case 표준 |
| `quality_gate.md` | `novel-quality-gate.md` | 네임스페이스 명확화 |
| `editor.md` | `novel-editor.md` | 네임스페이스 명확화 |
| `00_init.md` | `init.md` | 번호 불필요 (순서는 코드로) |

---

## 철학적 차이

### novel-engine

> **"가이드북"** — 사용자가 읽고 이해하고 실행

- CLAUDE.md에 오케스트레이션 규칙 명시
- 사용자가 Claude에게 직접 지시
- 유연하지만 일관성 보장 어려움

### claude_src

> **"자동화된 파이프라인"** — 명령어 하나로 실행

- 명령어가 에이전트를 자동 호출
- 상태 관리 자동화
- 일관성 보장, 사용 편의성 향상

---

## 마이그레이션

novel-engine 프로젝트를 claude_src로 마이그레이션하려면:

```bash
# 1. Novel Engine 설치
cp -r claude_src/* .claude/

# 2. 기존 canon 파일 유지 (구조 동일)
# canon/ 폴더는 그대로 사용 가능

# 3. state 파일 마이그레이션
# story_state.json에 schema_version, format 추가 필요:
{
  "schema_version": "1.2",
  "project": {
    "format": "chapter",    // 추가
    "git_integration": {...} // 추가
  },
  ...
}

# 4. beats/ 폴더 구조 확인
# outline.md, beat_plan.md 형식은 호환됨

# 5. 새 명령어로 계속 진행
/novel:status
/novel:write
```

---

## 요약

| 측면 | novel-engine | claude_src |
|------|--------------|------------|
| 복잡도 | 단순 (참조용) | 완전한 구현 |
| 자동화 | 없음 | 높음 |
| 유연성 | 높음 | 중간 (구조화됨) |
| 학습 곡선 | 낮음 | 낮음 (명령어) |
| 일관성 | 사용자 의존 | 시스템 보장 |
| 확장성 | 수동 | 스킬/에이전트 추가 |

**결론:** claude_src는 novel-engine의 아이디어를 가져와서 **자동화**, **일기체 지원**, **버전 관리**, **EPUB 출력** 등을 추가한 프로덕션 레벨 구현입니다.

---

*Last updated: 2026-02-25*
