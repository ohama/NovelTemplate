#!/bin/bash
# Novel Engine 설치 스크립트
# 사용법: bash tutorial/install.sh [target_dir]
#
# 예시:
#   bash tutorial/install.sh              # 현재 디렉토리의 .claude/에 설치
#   bash tutorial/install.sh ~/my-novel   # ~/my-novel/.claude/에 설치

set -e

# 타겟 디렉토리 결정
if [ -n "$1" ]; then
    TARGET_DIR="$1"
else
    TARGET_DIR="."
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")/claude_src"

echo "=== Novel Engine 설치 ==="
echo ""
echo "소스: $SOURCE_DIR"
echo "대상: $TARGET_DIR/.claude/"
echo ""

# 소스 확인
if [ ! -d "$SOURCE_DIR/commands/novel" ]; then
    echo "ERROR: 소스 디렉토리를 찾을 수 없습니다: $SOURCE_DIR"
    exit 1
fi

# 타겟 디렉토리 생성
mkdir -p "$TARGET_DIR"

# 설치
echo "[1/2] 파일 복사 중..."

# 기존 novel 파일이 있으면 제거 후 새로 복사
rm -rf "$TARGET_DIR/.claude/commands/novel"
rm -rf "$TARGET_DIR/.claude/novel"

# 새 구조 복사
mkdir -p "$TARGET_DIR/.claude/commands"
cp -r "$SOURCE_DIR/commands/novel" "$TARGET_DIR/.claude/commands/"
cp -r "$SOURCE_DIR/novel" "$TARGET_DIR/.claude/"

echo "[2/2] 설치 확인..."
echo ""
echo "설치된 파일:"
echo "  .claude/commands/novel/  (명령어 7개)"
echo "  .claude/novel/agents/    (에이전트 13개)"
echo "  .claude/novel/skills/    (스킬 3개)"
echo "  .claude/novel/schemas/   (스키마 10개)"
echo "  .claude/novel/templates/ (템플릿)"
echo "  .claude/novel/utils/     (유틸리티)"

echo ""
echo "=== 설치 완료! ==="
echo ""
echo "사용 가능한 명령어:"
echo "  /novel:start    - 빠른 시작 (스토리 브리프로 바로 시작)"
echo "  /novel:init     - 프로젝트 초기화"
echo "  /novel:status   - 진행 상황 확인"
echo "  /novel:outline  - 구조 생성"
echo "  /novel:write    - 씬 집필"
echo "  /novel:check    - 품질 검사"
echo "  /novel:publish  - EPUB 출판"
echo ""
echo "시작하려면 Claude Code에서 /novel:start 를 입력하고 이야기 아이디어를 설명하세요."
