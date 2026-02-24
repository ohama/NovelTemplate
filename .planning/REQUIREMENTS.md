# Requirements: Novel Engine

**Defined:** 2026-02-24
**Core Value:** 일관성 있는 소설 작성 — 캐릭터, 세계관, 타임라인이 유지되면서 자연스러운 이야기 전개

## v1 Requirements

### Foundation

- [x] **FOUND-01**: 디렉토리 구조 초기화 (canon/, state/, beats/, draft/)
- [x] **FOUND-02**: JSON 상태 관리 (story_state, character_state, timeline_state, style_state)
- [x] **FOUND-03**: Git 통합 (씬 완성 시 자동 커밋)
- [x] **FOUND-04**: /novel:init 명령어 (프로젝트 초기화 스킬)

### Canon System

- [x] **CANON-01**: premise.md 템플릿 및 초기화 (장르, 로그라인, 테마, 결말 유형)
- [x] **CANON-02**: characters.md 템플릿 및 초기화 (캐릭터 프로필, 관계)
- [x] **CANON-03**: world.md 템플릿 및 초기화 (세계관, 배경 설정)
- [x] **CANON-04**: style_guide.md 템플릿 및 초기화 (시점, 시제, 문체, 금지어)
- [x] **CANON-05**: timeline.md 템플릿 및 초기화 (시간순 제약)
- [x] **CANON-06**: constraints.md 템플릿 및 초기화 (스토리 경계)

### Planning Agents

- [x] **AGENT-01**: novel-plot-planner 에이전트 (캐논에서 아웃라인 생성)
- [x] **AGENT-02**: novel-beat-planner 에이전트 (아웃라인에서 씬 스펙 생성)
- [x] **AGENT-03**: novel-diary-planner 에이전트 (일기체 특화 기획 — 날짜/계절)

### Drafting Agents

- [x] **AGENT-04**: novel-scene-writer 에이전트 (스펙에서 산문 작성)
- [ ] **AGENT-05**: novel-editor 에이전트 (이슈 기반 리라이트)
- [ ] **AGENT-06**: novel-quality-gate 에이전트 (승인/반려 결정)

### Checking Agents

- [ ] **AGENT-07**: novel-canon-checker 에이전트 (캐논 모순 감지)
- [ ] **AGENT-08**: novel-timeline-keeper 에이전트 (시간순 검증)
- [ ] **AGENT-09**: novel-voice-coach 에이전트 (캐릭터 목소리 일관성)
- [ ] **AGENT-10**: novel-pacing-analyzer 에이전트 (리듬과 흐름 분석)
- [ ] **AGENT-11**: novel-tension-monitor 에이전트 (갈등과 긴장감 모니터링)

### Commands

- [x] **CMD-01**: /novel:init 스킬 (프로젝트 초기화)
- [x] **CMD-02**: /novel:write 스킬 (다음 씬/일기 작성)
- [ ] **CMD-03**: /novel:check 스킬 (일관성 검사)
- [x] **CMD-04**: /novel:status 스킬 (진행 상황 확인)
- [x] **CMD-05**: /novel:outline 스킬 (아웃라인 생성)
- [ ] **CMD-06**: /novel:publish 스킬 (챕터 컴파일)

### Diary Format Support

- [x] **DIARY-01**: 일기 날짜/시간 추적 (ISO 8601 형식)
- [x] **DIARY-02**: 계절/날씨 변화 추적 (자연 묘사 가이드)
- [x] **DIARY-03**: 감정 아크 추적 (일기별 감정 상태)
- [x] **DIARY-04**: 성장 마일스톤 추적 (달리기 기록, 체력 변화 등)

### Version Management

- [ ] **VER-01**: 초고/퇴고 스냅샷 저장 (draft/versions/)
- [ ] **VER-02**: 버전 비교 기능 (diff 지원)
- [ ] **VER-03**: 버전 복원 기능 (rollback)

### Output

- [x] **OUT-01**: Markdown 출력 (씬별, 챕터별)
- [ ] **OUT-02**: EPUB 내보내기 (Pandoc 통합)

## v2 Requirements

### Advanced Features

- **ADV-01**: 복수 POV 추적 (여러 화자 관리)
- **ADV-02**: 서브플롯 관리 (메인 플롯과 별도 추적)
- **ADV-03**: 복선/회수 추적 (foreshadowing/payoff)
- **ADV-04**: 씬 재배열 도구 (드래그 앤 드롭 없이 CLI로)

### Export Formats

- **EXP-01**: PDF 내보내기
- **EXP-02**: 웹소설 플랫폼 형식 (HTML with chapters)

## Out of Scope

| Feature | Reason |
|---------|--------|
| GUI/시각적 도구 | CLI 전용 도구, 코크보드/드래그앤드롭 불필요 |
| 다중 사용자 협업 | 단일 사용자 워크플로우에 집중 |
| 이미지/마인드맵 | 텍스트 소설에 집중 |
| AI 전체 자동 집필 | "전체 책 쓰기" 버튼 의도적 제외 — 협업 도구 |
| 독점 파일 형식 | Markdown + JSON만 사용 |
| 웹 인터페이스 | Claude Code 내부에서만 사용 |

## Traceability

| Requirement | Phase | Plan | Status |
|-------------|-------|------|--------|
| FOUND-01 | Phase 1: Foundation & Canon System | 1.1 Directory Structure & State Initialization | Complete |
| FOUND-02 | Phase 1: Foundation & Canon System | 1.1 Directory Structure & State Initialization | Complete |
| FOUND-03 | Phase 1: Foundation & Canon System | 1.3 /novel:status Command & Git Integration | Complete |
| FOUND-04 | Phase 1: Foundation & Canon System | 1.2 /novel:init Command | Complete |
| CANON-01 | Phase 1: Foundation & Canon System | 1.2 /novel:init Command | Complete |
| CANON-02 | Phase 1: Foundation & Canon System | 1.2 /novel:init Command | Complete |
| CANON-03 | Phase 1: Foundation & Canon System | 1.2 /novel:init Command | Complete |
| CANON-04 | Phase 1: Foundation & Canon System | 1.2 /novel:init Command | Complete |
| CANON-05 | Phase 1: Foundation & Canon System | 1.2 /novel:init Command | Complete |
| CANON-06 | Phase 1: Foundation & Canon System | 1.2 /novel:init Command | Complete |
| AGENT-01 | Phase 2: Planning Pipeline | 2.1 Plot Planner Agent | Complete |
| AGENT-02 | Phase 2: Planning Pipeline | 2.2 Beat Planner Agent | Complete |
| AGENT-03 | Phase 2: Planning Pipeline | 2.3 Diary Planner Agent & /novel:outline Command | Complete |
| AGENT-04 | Phase 3: Drafting Engine | 3.1 Scene Writer Agent | Complete |
| AGENT-05 | Phase 5: Revision Loop | 5.1 Editor Agent | Pending |
| AGENT-06 | Phase 5: Revision Loop | 5.2 Quality Gate Agent | Pending |
| AGENT-07 | Phase 4: Quality Checks | 4.1 Canon & Timeline Checkers | Pending |
| AGENT-08 | Phase 4: Quality Checks | 4.1 Canon & Timeline Checkers | Pending |
| AGENT-09 | Phase 4: Quality Checks | 4.2 Voice & Pacing Analyzers | Pending |
| AGENT-10 | Phase 4: Quality Checks | 4.2 Voice & Pacing Analyzers | Pending |
| AGENT-11 | Phase 4: Quality Checks | 4.3 Tension Monitor & /novel:check Command | Pending |
| CMD-01 | Phase 1: Foundation & Canon System | 1.2 /novel:init Command | Complete |
| CMD-02 | Phase 3: Drafting Engine | 3.2 /novel:write Command | Complete |
| CMD-03 | Phase 4: Quality Checks | 4.3 Tension Monitor & /novel:check Command | Pending |
| CMD-04 | Phase 1: Foundation & Canon System | 1.3 /novel:status Command & Git Integration | Complete |
| CMD-05 | Phase 2: Planning Pipeline | 2.3 Diary Planner Agent & /novel:outline Command | Complete |
| CMD-06 | Phase 6: Advanced Features | 6.3 /novel:publish Command | Pending |
| DIARY-01 | Phase 3: Drafting Engine | 3.1 Scene Writer Agent | Complete |
| DIARY-02 | Phase 3: Drafting Engine | 3.1 Scene Writer Agent | Complete |
| DIARY-03 | Phase 3: Drafting Engine | 3.1 Scene Writer Agent | Complete |
| DIARY-04 | Phase 3: Drafting Engine | 3.1 Scene Writer Agent | Complete |
| VER-01 | Phase 6: Advanced Features | 6.1 Version Management | Pending |
| VER-02 | Phase 6: Advanced Features | 6.1 Version Management | Pending |
| VER-03 | Phase 6: Advanced Features | 6.1 Version Management | Pending |
| OUT-01 | Phase 3: Drafting Engine | 3.1 Scene Writer Agent | Complete |
| OUT-02 | Phase 6: Advanced Features | 6.2 EPUB Export | Pending |

**Coverage:**
- v1 requirements: 35 total
- Mapped to phases: 35 (100%)
- Unmapped: 0
- Phase distribution:
  - Phase 1: 12 requirements (Foundation + Canon)
  - Phase 2: 4 requirements (Planning)
  - Phase 3: 8 requirements (Drafting + Diary + Output)
  - Phase 4: 6 requirements (Quality Checks)
  - Phase 5: 2 requirements (Revision)
  - Phase 6: 5 requirements (Advanced Features)

**Validation:** ✓ All v1 requirements mapped to exactly one phase and plan

---
*Requirements defined: 2026-02-24*
*Last updated: 2026-02-24 after Phase 3 completion*
*Completed: 23/35 requirements (Phase 1: 12, Phase 2: 4, Phase 3: 7)*
