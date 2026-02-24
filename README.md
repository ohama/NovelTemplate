# Novel Engine

AI 기반 소설 집필 파이프라인 for Claude Code

---

## 소개

Novel Engine은 Claude Code에서 동작하는 소설 집필 자동화 시스템입니다. 설정 관리, 구조 설계, 집필, 품질 검사, EPUB 출판까지 전체 워크플로우를 지원합니다.

### 주요 기능

- **6단계 파이프라인**: init → outline → write → check → publish
- **13개 전문 에이전트**: 플롯 설계, 씬 작성, 일관성 검사 등
- **일기체 지원**: 날짜/요일/날씨 자동 생성
- **7개 병렬 체커**: 설정, 시간선, 문체, 페이싱, 긴장감, 복선, 서사 품질
- **버전 관리**: 스냅샷, diff, 롤백
- **EPUB 출판**: Pandoc 기반 전자책 생성

---

## 빠른 시작

### 1. 설치

```bash
# 새 프로젝트에 설치
bash tutorial/install.sh ~/my-novel

# 또는 현재 디렉토리에 설치
bash tutorial/install.sh .
```

### 2. 소설 시작

Claude Code에서:

```
/novel:start

제주에서 사는 중학생이 버스 대신 걷기 시작해서
1년 만에 마라톤 풀코스를 완주하는 이야기.
일기체로, 매주 2번, 대화 많이.
```

시스템이 자동으로 프로젝트 생성, 캐논 작성, 아웃라인 생성까지 수행합니다.

---

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/novel:start` | 빠른 시작 - 브리프로 프로젝트+캐논+아웃라인 생성 |
| `/novel:init` | 프로젝트 초기화 |
| `/novel:status` | 진행 상황 확인 |
| `/novel:outline` | 전체 구조 생성 |
| `/novel:write` | 다음 씬 집필 |
| `/novel:check` | 품질 검사 (7개 체커 병렬 실행) |
| `/novel:publish` | EPUB 파일 생성 |

---

## 프로젝트 구조

설치 후 생성되는 디렉토리:

```
my-novel/
├── canon/              ← 설정 파일 (진실의 원천)
│   ├── premise.md          기획서
│   ├── characters.md       캐릭터 설정
│   ├── world.md            세계관
│   ├── timeline.md         시간선
│   ├── style_guide.md      문체 가이드
│   └── constraints.md      제약 조건
├── state/              ← 상태 파일 (자동 관리)
│   ├── story_state.json
│   ├── character_state.json
│   └── ...
├── beats/              ← 플롯 구조 (자동 생성)
│   ├── outline.md
│   └── scenes/*.md
└── draft/              ← 원고
    ├── scenes/             씬 파일들
    ├── compiled/           완성본 + EPUB
    └── versions/           스냅샷
```

---

## 에이전트

### 구조 설계 (3개)
| 에이전트 | 역할 |
|----------|------|
| plot-planner | 전체 줄거리 설계 |
| beat-planner | 씬별 비트 시트 생성 |
| diary-planner | 일기체 시간 구조 |

### 집필 (1개)
| 에이전트 | 역할 |
|----------|------|
| scene-writer | 비트 시트 기반 산문 작성 |

### 품질 검사 (7개, 병렬 실행)
| 에이전트 | 검사 내용 |
|----------|----------|
| canon-checker | 캐릭터/세계관 설정 일관성 |
| timeline-keeper | 시간선 정합성 |
| voice-coach | POV/시제/문체 일관성 |
| pacing-analyzer | 전개 속도/리듬 |
| tension-monitor | 갈등/긴장감 |
| plot-coherence-checker | 복선/플롯 스레드 추적 |
| story-quality-agent | 서사 품질/독자 경험 |

### 종합 (2개)
| 에이전트 | 역할 |
|----------|------|
| novel-editor | 체커 결과 종합, 편집자 피드백 |
| novel-quality-gate | 심각도 분류, 씬 승인/거부 |

---

## 문서

자세한 사용법은 `tutorial/` 폴더를 참조하세요:

- [파이프라인 가이드](tutorial/pipeline-guide.md) - 초보자용 단계별 안내
- [설치 및 아키텍처](tutorial/installation-and-architecture.md) - 내부 구조 상세
- [비교 문서](tutorial/comparison-novel-engine-vs-claude-src.md) - 원본 vs 새 구현

---

## 요구 사항

- **Claude Code** (필수)
- **Pandoc** (EPUB 출판 시 필요)
  ```bash
  # Ubuntu/Debian
  sudo apt install pandoc

  # macOS
  brew install pandoc
  ```

---

## 디렉토리 설명

```
NovelTemplate/
├── claude_src/         ← Novel Engine 소스 코드
│   ├── commands/novel/     슬래시 명령어 (7개)
│   └── novel/
│       ├── agents/         에이전트 정의 (13개)
│       ├── skills/         유틸리티 스킬 (3개)
│       ├── schemas/        JSON 스키마 (5쌍)
│       ├── templates/      캐논/디렉토리 템플릿
│       └── utils/          유틸리티
├── novel-engine/       ← 원본 참조 구현 (비교용)
└── tutorial/           ← 튜토리얼 문서
```

---

## 라이선스

MIT License

---

*Novel Engine v1.0*
