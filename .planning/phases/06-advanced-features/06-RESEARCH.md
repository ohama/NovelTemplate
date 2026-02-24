# Phase 6: Advanced Features - Research

**Researched:** 2026-02-24
**Domain:** Version Management + EPUB Publishing
**Confidence:** HIGH

## Summary

Phase 6 completes the Novel Engine v1.0 with two distinct capabilities: version management for draft snapshots and EPUB export for publishing. Research focused on three key areas:

1. **Version Management** - File-based snapshot storage that integrates with the existing git workflow. Unlike Scrivener's binary snapshots, this approach stores timestamped copies of scene files as plain Markdown, enabling standard diff tools for comparison and simple file operations for rollback. The existing git-integration skill provides the foundation but snapshots operate independently for finer granularity.

2. **EPUB Export** - Pandoc is the established standard for Markdown-to-EPUB conversion, supporting EPUB3 with comprehensive metadata, automatic ToC generation, and chapter organization. The tool is mature, well-documented, and works perfectly with the project's Markdown-only philosophy.

3. **Publishing Workflow** - The `/novel:publish` command orchestrates compilation of approved scenes into a single EPUB file with proper metadata, cover support, and navigation structure.

**Primary recommendation:** Use Pandoc for EPUB generation with YAML metadata block, implement file-based snapshots in `draft/versions/` with ISO timestamps, and leverage standard `diff -u` for version comparison.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Pandoc | 3.x | Markdown to EPUB conversion | Industry standard, comprehensive EPUB3 support, active development |
| diff | GNU coreutils | Unified diff generation | Universal availability, standard output format, well-understood |
| cp/mv | POSIX | File snapshot operations | No dependencies, atomic operations, simple rollback |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| git diff --word-diff | git 2.x | Word-level diff for prose | When line-by-line diff is too coarse for narrative text |
| wdiff | GNU | Word-by-word diff display | Alternative to git --word-diff for non-git contexts |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Pandoc | calibre ebook-convert | Less Markdown-native, heavier dependency |
| File snapshots | Git branches | Branches are heavier, require git knowledge |
| diff -u | Custom diff tool | Unnecessary complexity, reinventing the wheel |

**Installation:**
```bash
# Debian/Ubuntu
sudo apt-get install pandoc

# macOS
brew install pandoc

# Check installation
pandoc --version
```

## Architecture Patterns

### Recommended Project Structure
```
draft/
├── scenes/                 # Current scene files
│   ├── ch01_s01.md
│   ├── ch01_s02.md
│   └── ...
├── versions/               # Version snapshots (NEW)
│   ├── 2026-02-24_14-30/   # Timestamped snapshot
│   │   ├── manifest.json   # Snapshot metadata
│   │   ├── ch01_s01.md     # Scene copies at snapshot time
│   │   └── ...
│   └── 2026-02-24_16-45/   # Another snapshot
│       └── ...
└── compiled/               # EPUB output (NEW)
    ├── novel.epub          # Latest compiled book
    └── metadata.yaml       # EPUB metadata
```

### Pattern 1: Snapshot Manifest Pattern
**What:** Each snapshot includes a manifest.json with metadata about when/why it was taken.
**When to use:** Every automatic snapshot after revision cycles.
**Example:**
```json
{
  "snapshot_id": "snap_2026-02-24_14-30-45",
  "timestamp": "2026-02-24T14:30:45Z",
  "trigger": "revision_cycle",
  "scenes_included": ["ch01_s01", "ch01_s02", "ch02_s01"],
  "story_state_hash": "abc123",
  "notes": "After revision cycle 2 for chapter 1"
}
```

### Pattern 2: YAML Metadata Block for EPUB
**What:** Store all EPUB metadata in a YAML file that Pandoc consumes directly.
**When to use:** For `/novel:publish` command.
**Example:**
```yaml
---
title: "Your Novel Title"
author:
  - name: "Author Name"
    role: author
identifier:
  - scheme: UUID
    text: "urn:uuid:12345-67890-abcdef"
language: ko
rights: "All Rights Reserved"
date: 2026-02-24
cover-image: images/cover.png
description: |
  A compelling story about...
subject:
  - Fiction
  - Literary
---
```

### Pattern 3: Chapter Compilation Order
**What:** Compile scenes in scene_index order, grouping by chapter with proper breaks.
**When to use:** Building the final EPUB manuscript.
**Example:**
```bash
# Pandoc expects files in reading order
pandoc metadata.yaml \
  draft/scenes/ch01_s01.md \
  draft/scenes/ch01_s02.md \
  draft/scenes/ch02_s01.md \
  --toc \
  --toc-depth=2 \
  -o novel.epub
```

### Anti-Patterns to Avoid
- **Database for snapshots:** Don't use SQLite or JSON databases for version storage - simple file copies are clearer and more portable
- **Git-only versioning:** Git alone is too coarse for per-revision-cycle snapshots that writers expect
- **Custom diff algorithms:** Don't build word-diff from scratch - use `diff -u` or `git diff --word-diff`
- **In-memory EPUB building:** Always use Pandoc - EPUB spec is complex with many edge cases

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| EPUB generation | Custom XML/ZIP builder | Pandoc | EPUB3 spec is complex (mimetype, META-INF, OPF, NCX) |
| Text diff | Character-by-character comparison | diff -u or git diff | Decades of refinement, handles edge cases |
| EPUB metadata | Manual Dublin Core XML | Pandoc YAML metadata | Automatic validation, proper namespacing |
| Table of Contents | Manual NCX generation | Pandoc --toc | Automatic from heading structure |
| Word-level diff | Custom tokenizer | git diff --word-diff | Handles Unicode, punctuation, edge cases |

**Key insight:** EPUB and diff tools have decades of development addressing edge cases you won't anticipate. The effort to "keep it simple" by hand-rolling creates fragile solutions that fail on real manuscripts.

## Common Pitfalls

### Pitfall 1: EPUB Validation Failures
**What goes wrong:** Generated EPUB fails validation on e-reader platforms (Kindle, Apple Books)
**Why it happens:** Missing required metadata, incorrect mimetype placement, invalid XHTML
**How to avoid:** Always use Pandoc with proper metadata.yaml; validate with epubcheck if needed
**Warning signs:** EPUB opens in some readers but not others; formatting issues on specific platforms

### Pitfall 2: Snapshot Storage Explosion
**What goes wrong:** Versions directory grows huge with full copies of all scenes
**Why it happens:** Naively copying all scenes on every revision cycle
**How to avoid:** Only snapshot scenes that changed; use manifest to track which scenes are in each snapshot
**Warning signs:** draft/versions/ exceeds 10x the size of draft/scenes/

### Pitfall 3: Diff Confusion with Markdown
**What goes wrong:** diff output is hard to read because of Markdown formatting
**Why it happens:** Line-based diff splits sentences across line breaks
**How to avoid:** Use `diff -u --word-diff` or `git diff --word-diff` for prose; consider normalizing line lengths
**Warning signs:** Diff shows entire paragraphs as changed when only a word was edited

### Pitfall 4: Missing EPUB Cover Image
**What goes wrong:** Published EPUB has no cover in e-reader libraries
**Why it happens:** cover-image path wrong or image too large (>1000px)
**How to avoid:** Verify cover-image path in metadata.yaml; resize to <1000px width/height
**Warning signs:** EPUB generates but shows blank cover in reader app

### Pitfall 5: Snapshot ID Collision
**What goes wrong:** Two snapshots created in same second overwrite each other
**Why it happens:** Using second-precision timestamps as directory names
**How to avoid:** Include subsecond precision or sequential counter in snapshot ID
**Warning signs:** Snapshot count doesn't match revision_count in scene_index

### Pitfall 6: Character Encoding in EPUB
**What goes wrong:** Korean/CJK characters display incorrectly in EPUB
**Why it happens:** Missing language declaration or wrong encoding
**How to avoid:** Always specify `language: ko` in metadata; Pandoc handles UTF-8 correctly
**Warning signs:** Characters appear as boxes or question marks in e-reader

## Code Examples

Verified patterns from official sources:

### Create Snapshot Directory
```bash
# Source: Standard POSIX patterns
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
SNAPSHOT_DIR="draft/versions/${TIMESTAMP}"
mkdir -p "${SNAPSHOT_DIR}"
```

### Generate Snapshot Manifest
```bash
# Source: Novel Engine pattern (adapted from state-manager)
cat > "${SNAPSHOT_DIR}/manifest.json" << EOF
{
  "snapshot_id": "snap_${TIMESTAMP}",
  "timestamp": "$(date -Iseconds)",
  "trigger": "revision_cycle",
  "scenes_included": $(jq -c '[.scene_index[] | select(.status == "drafted" or .status == "approved") | .id]' state/story_state.json),
  "source_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'none')"
}
EOF
```

### Copy Changed Scenes to Snapshot
```bash
# Source: Standard file operations
for scene_id in $(jq -r '.scene_index[] | select(.status == "drafted" or .status == "approved") | .id' state/story_state.json); do
  cp "draft/scenes/${scene_id}.md" "${SNAPSHOT_DIR}/"
done
```

### Generate Unified Diff Between Versions
```bash
# Source: GNU diff manual
# Compare two snapshots
diff -u "draft/versions/old_snapshot/ch01_s01.md" \
       "draft/versions/new_snapshot/ch01_s01.md" \
  > diff_output.txt

# Word-level diff for prose (requires git)
git diff --no-index --word-diff \
  "draft/versions/old_snapshot/ch01_s01.md" \
  "draft/versions/new_snapshot/ch01_s01.md"
```

### Restore Scene from Snapshot
```bash
# Source: Standard file operations
SNAPSHOT_ID="2026-02-24_14-30-45"
SCENE_ID="ch01_s01"

# Verify snapshot exists
if [ -f "draft/versions/${SNAPSHOT_ID}/${SCENE_ID}.md" ]; then
  # Backup current before restore
  cp "draft/scenes/${SCENE_ID}.md" "draft/scenes/${SCENE_ID}.md.bak"
  # Restore from snapshot
  cp "draft/versions/${SNAPSHOT_ID}/${SCENE_ID}.md" "draft/scenes/${SCENE_ID}.md"
  echo "Restored ${SCENE_ID} from snapshot ${SNAPSHOT_ID}"
else
  echo "ERROR: Scene not found in snapshot"
fi
```

### Generate EPUB Metadata YAML
```yaml
# Source: Pandoc EPUB documentation
# File: draft/compiled/metadata.yaml
---
title:
  - type: main
    text: "Your Novel Title"
  - type: subtitle
    text: "A Compelling Subtitle"
creator:
  - role: author
    text: "Author Name"
identifier:
  - scheme: UUID
    text: "urn:uuid:$(uuidgen)"
language: ko
rights: "Copyright 2026 Author Name. All Rights Reserved."
date: 2026-02-24
cover-image: "images/cover.png"
description: |
  A story about perseverance, growth, and the joy of running.
  Set over 42 days of marathon training...
subject:
  - Fiction
  - Literary
  - Sports
publisher: "Self-Published"
css: "epub.css"
---
```

### Compile EPUB with Pandoc
```bash
# Source: Pandoc EPUB documentation
# Collect all approved scenes in order
SCENES=$(jq -r '.scene_index | sort_by(.chapter, .scene) | .[] | select(.status == "approved") | "draft/scenes/\(.id).md"' state/story_state.json | tr '\n' ' ')

# Generate EPUB
pandoc \
  draft/compiled/metadata.yaml \
  ${SCENES} \
  --toc \
  --toc-depth=2 \
  --epub-chapter-level=1 \
  -o draft/compiled/novel.epub

echo "EPUB generated: draft/compiled/novel.epub"
```

### Validate EPUB (Optional)
```bash
# Source: epubcheck tool (optional dependency)
# Only if validation is required
if command -v epubcheck &> /dev/null; then
  epubcheck draft/compiled/novel.epub
fi
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| EPUB2 with NCX | EPUB3 with nav document | 2014 | Better accessibility, HTML5 support |
| Manual OPF editing | Pandoc YAML metadata | 2015+ | Much simpler workflow |
| Line-based diff only | Word-diff for prose | 2010 (git) | Better readability for writers |
| Full manuscript copies | Incremental snapshots | Current | Storage efficiency |

**Deprecated/outdated:**
- **EPUB2**: Still works but EPUB3 is standard; Pandoc defaults to EPUB3
- **Manual NCX generation**: Pandoc handles this automatically
- **toc.ncx file**: EPUB3 uses HTML5 nav element (Pandoc handles both)

## Open Questions

Things that couldn't be fully resolved:

1. **Snapshot Retention Policy**
   - What we know: Snapshots accumulate over time
   - What's unclear: How long to keep old snapshots? How many to retain?
   - Recommendation: Start with keeping all snapshots (disk is cheap), add cleanup command later in v2

2. **Cover Image Source**
   - What we know: EPUB needs cover-image for proper display in e-reader libraries
   - What's unclear: Where does cover image come from in user workflow?
   - Recommendation: Make cover-image optional in metadata.yaml; use placeholder or skip if not provided

3. **Multi-POV Chapter Organization**
   - What we know: Pandoc uses H1 (#) for chapter breaks
   - What's unclear: How to handle POV character names in chapter titles for multi-POV novels?
   - Recommendation: Let scene frontmatter POV field drive chapter subtitle if needed

4. **Pandoc Installation Verification**
   - What we know: Pandoc must be installed for /novel:publish to work
   - What's unclear: How to handle when Pandoc is not installed?
   - Recommendation: Check for Pandoc at command start; provide clear installation instructions if missing

## Sources

### Primary (HIGH confidence)
- [Pandoc EPUB Documentation](https://pandoc.org/epub.html) - Official EPUB generation guide
- [Pandoc User's Guide](https://pandoc.org/MANUAL.html) - Comprehensive reference for all options
- [Pandoc EPUB Metadata](https://pandoc.org/demo/example33/11.1-epub-metadata.html) - Dublin Core and YAML syntax
- [GNU diff manual](https://www.gnu.org/software/diffutils/manual/html_node/diff-Options.html) - Diff command options

### Secondary (MEDIUM confidence)
- [EPUB 3.3 W3C Specification](https://www.w3.org/TR/epub-33/) - Official EPUB3 standard
- [Pandoc Book Template](https://github.com/wikiti/pandoc-book-template) - Community best practices
- [Scrivener Snapshots](https://www.literatureandlatte.com/blog/use-snapshots-in-scrivener-to-save-versions-of-your-projects) - Writer-focused snapshot UX

### Tertiary (LOW confidence)
- Web searches for current practices in 2026 - General ecosystem awareness

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Pandoc is unambiguously the standard; diff is universal
- Architecture: HIGH - File-based snapshots follow project's Markdown-only philosophy
- Pitfalls: MEDIUM - Based on common issues reported in forums and documentation
- Code examples: HIGH - Derived from official documentation and POSIX standards

**Research date:** 2026-02-24
**Valid until:** 2026-04-24 (60 days - stable tools, slow-moving ecosystem)

---

## Integration with Existing System

### State Schema Updates Needed
The `story_state.schema.json` may need extension for version tracking:

```json
{
  "versions": {
    "type": "object",
    "properties": {
      "snapshots": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "snapshot_id": { "type": "string" },
            "timestamp": { "type": "string", "format": "date-time" },
            "trigger": { "type": "string", "enum": ["manual", "revision_cycle", "pre_publish"] },
            "scenes_count": { "type": "integer" }
          }
        }
      },
      "last_snapshot": { "type": "string" },
      "last_publish": { "type": "string", "format": "date-time" }
    }
  }
}
```

### Git Integration Extension
The existing `git-integration.md` skill handles scene commits. Version snapshots operate independently:
- Git commits: Track the current state (what's "live")
- Snapshots: Preserve historical states for comparison/rollback

Both can coexist - snapshots are taken BEFORE git commits in revision cycles.

### Command Relationships
```
/novel:write  --> scene drafted
/novel:check  --> runs checkers, triggers revision loop
              --> AUTO: create snapshot after each revision cycle
/novel:publish --> compile approved scenes to EPUB
              --> AUTO: create pre-publish snapshot
```

### New Directory Structure
```
draft/
├── scenes/           # (existing)
├── versions/         # NEW: snapshot storage
│   └── [timestamp]/
│       ├── manifest.json
│       └── *.md
└── compiled/         # NEW: EPUB output
    ├── metadata.yaml
    ├── epub.css      # Optional styling
    └── novel.epub
```
