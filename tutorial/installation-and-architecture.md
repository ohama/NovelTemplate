# Novel Engine 설치 및 아키텍처 가이드

*Novel Engine의 내부 동작을 이해하고 싶은 분들을 위한 기술 문서*

---

## 설치 방법

### 전제 조건

- Claude Code가 설치되어 있어야 합니다

### 설치 구조

Novel Engine의 소스 코드는 `claude_src/`에 있으며, 새 프로젝트에 `.claude/`로 복사하여 사용합니다.

```
claude_src/                    복사 후 (.claude/)
├── commands/                  ├── commands/
│   └── novel/                 │   └── novel/
│       ├── init.md            │       ├── init.md      ← Claude Code가 인식
│       ├── start.md           │       ├── start.md
│       ├── status.md          │       ├── status.md
│       ├── outline.md         │       ├── outline.md
│       ├── write.md           │       ├── write.md
│       ├── check.md           │       ├── check.md
│       └── publish.md         │       └── publish.md
└── novel/                     └── novel/
    ├── agents/                    ├── agents/          ← 에이전트 13개
    ├── skills/                    ├── skills/          ← 스킬 3개
    ├── schemas/                   ├── schemas/         ← JSON 스키마 (5쌍)
    ├── templates/                 ├── templates/       ← 템플릿
    └── utils/                     └── utils/           ← 유틸리티
```

### 설치 명령어

**방법 1: 스크립트 사용 (권장)**

```bash
bash tutorial/install.sh ~/my-novel-project
```

**방법 2: 직접 복사**

```bash
# 새 프로젝트에 설치
cp -r claude_src/* ~/my-novel-project/.claude/

# 또는 현재 디렉토리에 설치
cp -r claude_src/* .claude/
```

### 설치 확인

```bash
# 파일 확인
ls .claude/commands/novel/
# 출력: check.md  init.md  outline.md  publish.md  start.md  status.md  write.md

ls .claude/novel/
# 출력: agents  schemas  skills  templates  utils
```

Claude Code에서 `/novel:init`을 입력하면 명령어가 인식되면 설치 완료입니다.

---

## 아키텍처 개요

### 레이어 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Commands (명령어 레이어)                  │
│         사용자가 /novel:xxx로 호출하는 진입점               │
│                                                             │
│ init start status outline write check publish │
└──────────────────────────┬──────────────────────────────────┘
                           │ 호출
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Agents (에이전트 레이어)                  │
│              특정 작업을 수행하는 전문 에이전트              │
│                                                             │
│  plot-planner   beat-planner   scene-writer   canon-checker │
│  diary-planner  voice-coach    pacing-analyzer  ...         │
└──────────────────────────┬──────────────────────────────────┘
                           │ 사용
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                 Skills & Utils (유틸리티 레이어)             │
│            여러 에이전트가 공유하는 도구들                   │
│                                                             │
│   state-manager.md   git-integration.md   version-manager.md │
│   epub-generator.md                                          │
└──────────────────────────┬──────────────────────────────────┘
                           │ 참조
                           ▼
┌─────────────────────────────────────────────────────────────┐
│            Schemas & Templates (데이터 레이어)               │
│           JSON 스키마, 기본값, 문서 템플릿                  │
│                                                             │
│   story_state.schema.json   premise.md   characters.md      │
│   character_state.schema.json   world.md   style_guide.md   │
└─────────────────────────────────────────────────────────────┘
```

### 데이터 흐름

```
사용자 입력
    │
    ▼
┌──────────┐     ┌──────────┐     ┌──────────┐
│  canon/  │ ──▶ │  beats/  │ ──▶ │  draft/  │
│ (설정)   │     │ (구조)   │     │ (원고)   │
└──────────┘     └──────────┘     └──────────┘
    │                │                │
    └───────┬────────┴───────┬────────┘
            ▼                ▼
       ┌──────────┐    ┌──────────────┐
       │  state/  │    │ check_reports│
       │ (상태)   │    │  (검사결과)  │
       └──────────┘    └──────────────┘
```

---

## 명령어별 동작 원리

### `/novel:start` — 빠른 시작 (권장)

**파일 위치:** `.claude/commands/novel/start.md`

**실행 흐름:**

```
/novel:start + 스토리 브리프
    │
    ├─▶ [1] Parse Story Brief
    │       ├── 제목, 장르, 형식 추출
    │       ├── 주인공 정보 추출
    │       ├── 설정 (장소, 기간) 추출
    │       └── 스타일 요청 추출
    │
    ├─▶ [2] Confirm Key Details
    │       └── 누락된 정보 질문 (주인공 이름 등)
    │
    ├─▶ [3] Create Project (like /novel:init)
    │       ├── 디렉토리 생성
    │       └── 상태 파일 초기화
    │
    ├─▶ [4] Auto-Generate Canon Files
    │       ├── premise.md (브리프에서 생성)
    │       ├── characters.md (주인공 + 조연 생성)
    │       ├── timeline.md (기간/이정표 생성)
    │       ├── style_guide.md (스타일 요청 반영)
    │       ├── world.md (배경 생성)
    │       └── constraints.md (제약 조건 생성)
    │
    ├─▶ [5] Generate Outline (like /novel:outline)
    │       ├── plot-planner 호출
    │       ├── beat-planner 호출
    │       └── diary-planner 호출 (일기체인 경우)
    │
    └─▶ [6] Offer First Scene
            └── "바로 첫 씬을 작성할까요?"
```

**사용 예:**
```
/novel:start

제주 중학생이 버스 대신 걷기 시작해서
1년 만에 마라톤 풀코스를 완주하는 이야기.
일기체로, 매주 2번, 대화 많이.
```

---

### `/novel:init` — 프로젝트 초기화

**파일 위치:** `.claude/commands/novel/init.md`

**실행 흐름:**

```
/novel:init
    │
    ├─▶ [1] Pre-Flight Validation
    │       ├── 이미 초기화되었는지 확인 (canon/, state/ 존재 여부)
    │       ├── 쓰기 권한 확인
    │       └── 디스크 공간 확인
    │
    ├─▶ [2] Create Directory Structure
    │       ├── canon/
    │       ├── state/
    │       ├── beats/
    │       ├── draft/scenes/
    │       ├── draft/compiled/
    │       └── draft/versions/
    │
    ├─▶ [3] Copy State Schemas
    │       ├── schemas/*.default.json → state/*.json
    │       └── (story_state, character_state, timeline_state, style_state)
    │
    ├─▶ [4] Copy Canon Templates
    │       ├── templates/*.md → canon/*.md
    │       └── (premise, characters, world, timeline, style_guide, constraints)
    │
    ├─▶ [5] Interactive Mode (--interactive 옵션 시)
    │       ├── 제목, 장르, 형식 질문
    │       └── 답변을 canon/premise.md에 반영
    │
    ├─▶ [6] Initialize Git
    │       ├── git init (없으면)
    │       ├── .gitignore 생성
    │       └── 초기 커밋
    │
    └─▶ [7] Display Next Steps
            └── "canon/ 파일을 편집하고 /novel:outline 실행"
```

**사용하는 도구:**
- `Read` — 기존 파일 확인
- `Write` — 파일 생성
- `Bash` — 디렉토리 생성, git 명령

---

### `/novel:status` — 진행 상황 확인

**파일 위치:** `.claude/commands/novel/status.md`

**실행 흐름:**

```
/novel:status
    │
    ├─▶ [1] Load State Files
    │       ├── state/story_state.json
    │       ├── state/character_state.json
    │       └── state/timeline_state.json
    │
    ├─▶ [2] Calculate Progress
    │       ├── 총 씬 수
    │       ├── 완료된 씬 수
    │       ├── 진행률 계산
    │       └── 예상 단어 수
    │
    ├─▶ [3] Check Canon Changes (git-integration 스킬 사용)
    │       ├── canon/ 파일 변경 감지
    │       └── 변경 있으면 자동 커밋
    │
    └─▶ [4] Display Report
            ├── 프로젝트 정보
            ├── 진행률 바
            ├── 다음 씬 정보
            └── 권장 다음 단계
```

---

### `/novel:outline` — 구조 생성

**파일 위치:** `.claude/commands/novel/outline.md`

**실행 흐름:**

```
/novel:outline
    │
    ├─▶ [1] Validate Environment
    │       ├── canon/ 존재 확인
    │       ├── premise.md, characters.md 존재 확인
    │       └── 이미 아웃라인이 있는지 확인
    │
    ├─▶ [2] Auto-commit Canon Changes
    │       └── git-integration 스킬로 canon 변경사항 커밋
    │
    ├─▶ [3] Backup Existing Beats (재생성 시)
    │       └── beats/ → beats.backup.[timestamp]/
    │
    ├─▶ [4] Spawn plot-planner Agent
    │       ├── canon/premise.md 읽기
    │       ├── Save the Cat 비트 시트 적용
    │       ├── 3막/5막 구조 결정
    │       └── beats/outline.md 생성
    │           │
    │           ▼
    ├─▶ [5] Spawn beat-planner Agent
    │       ├── beats/outline.md 읽기
    │       ├── 씬별 비트 시트 생성
    │       └── beats/scenes/*.md 생성
    │           │
    │           ▼
    ├─▶ [6] Spawn diary-planner Agent (format == "diary"일 때만)
    │       ├── 날짜별 계획 수립
    │       ├── 계절/날씨 패턴 설정
    │       └── beats/diary_plan.md 생성
    │
    ├─▶ [7] Update State
    │       └── story_state.json에 scene_index 초기화
    │
    └─▶ [8] Commit & Report
            ├── git commit
            └── 생성된 파일 목록 출력
```

**에이전트 호출 순서 (순차적):**

```
plot-planner  ──▶  beat-planner  ──▶  diary-planner
   (필수)            (필수)           (조건부)
```

왜 순차적인가?
- beat-planner는 outline.md가 필요함
- diary-planner는 씬 목록이 필요함

---

### `/novel:write` — 씬 집필

**파일 위치:** `.claude/commands/novel/write.md`

**실행 흐름:**

```
/novel:write
    │
    ├─▶ [1] Validate Environment
    │       ├── beats/ 존재 확인
    │       ├── scene_index에 씬이 있는지 확인
    │       └── 다음 씬 결정 (status == "pending" 중 첫 번째)
    │
    ├─▶ [2] Load Context
    │       ├── 현재 씬의 비트 시트 (beats/scenes/chXX_sYY.md)
    │       ├── 이전 씬 내용 (연속성 유지)
    │       ├── canon/ 파일들 (설정 참조)
    │       └── style_state.json (문체 가이드)
    │
    ├─▶ [3] Spawn scene-writer Agent
    │       ├── 비트 시트 지시사항 따르기
    │       ├── 이전 씬과 연결
    │       ├── 캐릭터 목소리 유지
    │       ├── 일기체면 날짜/날씨 포함
    │       └── draft/scenes/chXX_sYY.md 생성
    │
    ├─▶ [4] Update State
    │       ├── scene_index에서 해당 씬 status → "drafted"
    │       ├── word_count 업데이트
    │       └── last_written 타임스탬프
    │
    ├─▶ [5] Git Commit
    │       └── "Draft scene chXX_sYY: [씬 제목]"
    │
    └─▶ [6] Display Next Step
            └── "다음 씬 작성하려면 /novel:write"
```

**scene-writer 에이전트 동작:**

```
┌─────────────────────────────────────────────────────────┐
│                    scene-writer                          │
│                                                         │
│   입력:                                                 │
│   ├── 비트 시트 (이 씬에서 무슨 일이 일어나야 하는지)  │
│   ├── 이전 씬 (연속성)                                 │
│   ├── canon/characters.md (캐릭터 설정)                │
│   └── canon/style_guide.md (문체)                       │
│                                                         │
│   처리:                                                 │
│   ├── 비트 시트 → 산문으로 변환                        │
│   ├── 캐릭터 목소리 반영                               │
│   ├── 일기체면 날짜/시간/날씨 추가                     │
│   └── 목표 단어 수 맞추기                              │
│                                                         │
│   출력:                                                 │
│   └── draft/scenes/chXX_sYY.md                         │
└─────────────────────────────────────────────────────────┘
```

---

### `/novel:check` — 품질 검사

**파일 위치:** `.claude/commands/novel/check.md`

**실행 흐름:**

```
/novel:check
    │
    ├─▶ [1] Validate Prerequisites
    │       ├── scene_index에 drafted 씬 있는지 확인
    │       └── canon 파일 존재 확인
    │
    ├─▶ [2] Spawn 7 Checker Agents (병렬)
    │       │
    │       ├──▶ canon-checker
    │       │     └── 캐릭터/세계관 설정 일치 검사
    │       │
    │       ├──▶ timeline-keeper
    │       │     └── 시간선 정합성 검사
    │       │
    │       ├──▶ voice-coach
    │       │     └── POV/시제/문체 일관성 검사
    │       │
    │       ├──▶ pacing-analyzer
    │       │     └── 전개 속도/리듬 분석
    │       │
    │       ├──▶ tension-monitor
    │       │     └── 갈등/긴장감 분석
    │       │
    │       ├──▶ plot-coherence-checker
    │       │     └── 복선/플롯 스레드 추적
    │       │
    │       └──▶ story-quality-agent
    │             └── 서사 품질/독자 경험 분석
    │
    ├─▶ [3] Collect Results (각 에이전트가 JSON 반환)
    │       ├── canon_check.json
    │       ├── timeline_check.json
    │       ├── voice_check.json
    │       ├── pacing_check.json
    │       ├── tension_check.json
    │       ├── plot_coherence_check.json
    │       └── story_quality_check.json
    │
    ├─▶ [4] Spawn novel-editor Agent
    │       └── 체커 결과를 종합하여 편집자 피드백 생성
    │
    ├─▶ [5] Spawn novel-quality-gate Agent
    │       ├── 심각도별 분류 (CRITICAL/MAJOR/MINOR)
    │       ├── 씬별 승인/거부 결정
    │       └── 기준: CRITICAL 0개, MAJOR 2개 이하
    │
    ├─▶ [6] Save Reports
    │       └── check_reports/YYYY-MM-DD_HH-MM/
    │           ├── summary.md
    │           └── *.json
    │
    └─▶ [7] Display Summary
            ├── 심각도별 이슈 수
            ├── 승인/거부된 씬 목록
            └── 우선 수정 항목
```

**병렬 실행의 이유:**

```
순차 실행: 5분 × 7개 = 35분
병렬 실행: 5분 × 1번 = 5분  ← 7배 빠름

각 체커는 독립적으로 동작하고 서로 의존성이 없음
```

**체커 에이전트별 역할:**

| 에이전트 | 입력 | 검사 내용 | 출력 예시 |
|----------|------|----------|----------|
| canon-checker | characters.md, world.md + scenes | 캐릭터 외모, 세계관 규칙 | "ch03_s02: 눈 색상 불일치" |
| timeline-keeper | timeline.md + scenes | 날짜, 시간 순서, 요일 | "화요일인데 목요일이라고 씀" |
| voice-coach | style_guide.md + scenes | POV, 시제, 어투 | "A의 말투가 갑자기 달라짐" |
| pacing-analyzer | scenes | 씬 길이, 사건 밀도 | "5장이 너무 급함" |
| tension-monitor | scenes | 갈등, stakes | "중반부 긴장감 부족" |
| plot-coherence-checker | plot_threads.json + scenes | 복선 심기/회수, 플롯 스레드 | "4장 복선 미회수" |
| story-quality-agent | scenes + canon | 서사 품질, 독자 경험 | "주인공이 너무 수동적" |

---

### `/novel:publish` — EPUB 출판

**파일 위치:** `.claude/commands/novel/publish.md`

**실행 흐름:**

```
/novel:publish
    │
    ├─▶ [1] Validate Environment
    │       ├── Pandoc 설치 확인 (pandoc --version)
    │       └── 프로젝트 초기화 확인
    │
    ├─▶ [2] Validate Scenes
    │       ├── scene_index에서 승인된 씬 필터링
    │       │   (status == "approved" 또는 --include-draft)
    │       └── 최소 1개 씬 필요
    │
    ├─▶ [3] Validate Metadata
    │       ├── draft/compiled/metadata.yaml 확인
    │       └── 없으면 templates/epub/metadata.yaml 복사 후 자동 채우기
    │
    ├─▶ [4] Create Pre-Publish Snapshot (version-manager 스킬)
    │       ├── draft/versions/YYYY-MM-DD_HH-MM-SS/ 생성
    │       ├── 현재 scenes 복사
    │       └── manifest.json 생성
    │
    ├─▶ [5] Copy EPUB CSS
    │       └── templates/epub/epub.css → draft/compiled/epub.css
    │
    ├─▶ [6] Compile Scene List (epub-generator 스킬)
    │       ├── scene_index 순서대로 정렬
    │       ├── 각 씬 파일 존재 확인
    │       └── 파일 경로 목록 생성
    │
    ├─▶ [7] Generate EPUB (Pandoc 실행)
    │       │
    │       │  pandoc \
    │       │    --from markdown \
    │       │    --to epub \
    │       │    --metadata-file draft/compiled/metadata.yaml \
    │       │    --css draft/compiled/epub.css \
    │       │    --toc \
    │       │    --toc-depth=2 \
    │       │    --epub-chapter-level=1 \
    │       │    -o draft/compiled/[title].epub \
    │       │    [scene files...]
    │       │
    │       └── (선택) epubcheck 검증
    │
    ├─▶ [8] Update State
    │       └── story_state.json에 publish_history 추가
    │
    └─▶ [9] Display Success Report
            ├── EPUB 파일 경로
            ├── 포함된 씬 수
            ├── 단어 수
            └── 스냅샷 ID
```

---

## 에이전트 상세

### 에이전트란?

에이전트는 **특정 작업에 특화된 AI 역할**입니다. 각 에이전트는:
- 명확한 입력/출력 정의
- 특정 도메인 지식
- 일관된 행동 패턴

을 가집니다.

### 에이전트 목록

| 에이전트 | 역할 | 호출 위치 |
|----------|------|----------|
| plot-planner | 전체 줄거리 설계 | /novel:outline |
| beat-planner | 씬별 비트 시트 생성 | /novel:outline |
| diary-planner | 일기체 시간 구조 | /novel:outline |
| scene-writer | 산문 작성 | /novel:write |
| canon-checker | 설정 일관성 검사 | /novel:check |
| timeline-keeper | 시간선 검사 | /novel:check |
| voice-coach | 문체 검사 | /novel:check |
| pacing-analyzer | 전개 속도 분석 | /novel:check |
| tension-monitor | 긴장감 분석 | /novel:check |
| plot-coherence-checker | 복선/플롯 스레드 추적 | /novel:check |
| story-quality-agent | 서사 품질 분석 | /novel:check |
| novel-editor | 편집자 피드백 | /novel:check |
| novel-quality-gate | 승인/거부 결정 | /novel:check |

### 에이전트 파일 구조

```markdown
---
allowed-tools: [Read, Write, Glob, Grep]
description: 에이전트 설명
---

<role>
역할 정의
</role>

<inputs>
입력 정의
</inputs>

<outputs>
출력 정의
</outputs>

<execution>
실행 단계
</execution>

<examples>
예시
</examples>
```

---

## 스킬 상세

### 스킬이란?

스킬은 **여러 에이전트가 공유하는 유틸리티**입니다.

### 스킬 목록

| 스킬 | 역할 | 사용처 |
|------|------|--------|
| state-manager | JSON 상태 파일 읽기/쓰기 | 모든 명령어 |
| git-integration | git 커밋/체크 | init, status, outline, write |
| version-manager | 스냅샷 생성/복원 | check, publish |
| epub-generator | EPUB 생성 | publish |

### state-manager 스킬

모든 상태 파일 조작의 단일 진입점:

```
┌─────────────────────────────────────────┐
│            state-manager                 │
│                                         │
│  read_state(file) → JSON 객체           │
│  write_state(file, data) → 파일 저장    │
│  update_scene(scene_id, changes)        │
│  add_to_history(event)                  │
│                                         │
└─────────────────────────────────────────┘
```

---

## 데이터 스키마

### story_state.json 구조

```json
{
  "schema_version": "1.2",
  "title": "소설 제목",
  "format": "diary",
  "created_at": "2024-03-01T00:00:00Z",
  "progress": {
    "total_scenes": 50,
    "drafted_scenes": 12,
    "approved_scenes": 8
  },
  "scene_index": [
    {
      "scene_id": "ch01_s01",
      "chapter": 1,
      "scene": 1,
      "title": "버스 대신 걷기",
      "status": "approved",
      "word_count": 1200,
      "file_path": "draft/scenes/ch01_s01.md"
    }
  ],
  "versions": {
    "snapshots": [...],
    "last_snapshot": "snap_2024-03-15_10-30-00"
  },
  "revision_history": [...]
}
```

---

## 트러블슈팅

### 명령어가 인식되지 않음

```bash
# 파일 존재 확인
ls -la .claude/commands/novel/

# 파일이 없다면 재설치
bash tutorial/install.sh

# 또는 수동 복사
cp -r claude_src/* .claude/
```

### Pandoc 설치 안됨

```bash
# Ubuntu/Debian
sudo apt install pandoc

# macOS
brew install pandoc

# Windows
winget install pandoc
```

### 권한 오류

```bash
# 현재 디렉토리 쓰기 권한 확인
touch test.txt && rm test.txt

# 권한 부여
chmod -R u+w .
```

---

## GitHub Pages 배포

소설 프로젝트를 웹에서 읽을 수 있도록 GitHub Pages로 배포할 수 있습니다.

### 설치 시 포함되는 파일

```
my-novel/
├── book.toml                    ← mdBook 설정
├── src/
│   ├── SUMMARY.md              ← 목차 (씬 목록)
│   └── README.md               ← 소설 소개 (링크)
└── .github/workflows/
    └── mdbook.yml              ← 자동 배포 워크플로우
```

### 설정 방법

**1. book.toml 수정:**

```toml
[book]
title = "내 소설 제목"
authors = ["작가 이름"]
```

**2. src/SUMMARY.md에 씬 추가:**

```markdown
# Summary

[소개](README.md)

# 본문

- [1장 1절](../draft/scenes/ch01_s01.md)
- [1장 2절](../draft/scenes/ch01_s02.md)
```

**3. GitHub Pages 활성화:**

1. GitHub 저장소 Settings → Pages
2. Source → `GitHub Actions` 선택

**4. Push → 자동 배포:**

```bash
git push
# → https://username.github.io/my-novel/
```

---

## 확장하기

### 새 에이전트 추가

1. `.claude/novel/agents/new-agent.md` 생성
2. 기존 에이전트 구조 참고
3. 해당 명령어에서 Task 도구로 호출

### 새 명령어 추가

1. `.claude/commands/novel/new-command.md` 생성
2. `/novel:new-command`로 호출

소스 저장소에도 반영하려면:
```bash
# 소스에 추가
cp .claude/commands/novel/new-command.md claude_src/commands/novel/
```

---

*Novel Engine v1.0 Installation & Architecture Guide*
*Last updated: 2026-02-25*
