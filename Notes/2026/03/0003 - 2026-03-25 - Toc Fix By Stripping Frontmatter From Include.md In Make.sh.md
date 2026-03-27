# Session 0003: Obsidian YAML Frontmatter and Wiki-Link Stripping in Parser
<!-- TOPIC: Table of Contents Fix via include.md Frontmatter Stripping in Build Script -->

**Date:** 2026-03-25
**Status:** Completed

**Completed:** 2026-03-25T11:54:42.926Z

---

## Work Done

### Build System Investigation (Prior Work)
- [x] Registered the Dissertation project directory with PAI via `PAI.md` frontmatter (slug: `dissertation`, status: active)
- [x] Created initial `TODO.md` with empty open items template
- [x] Reviewed existing project contents: `2026/` directory, `Notes.md`, `Deriving Second Formula Term.md`
- [x] Explored the `make.sh` build system — a custom Bash script for managing LaTeX compilation with functions: `_check()` (recursion guard), `_run()` (parse + pdflatex), `_pdf()` (build + open PDF), `_pdflatex()`, `_submit()`
- [x] Examined the Perl parser (`templates/parser.pl`) which reads `templates/parser.cfg` for regex-based text transformations (stripping Scrivener comments, inline images, handling quotes)
- [x] Reviewed template configuration files: `templates/sortspec.md` (chapter ordering), `templates/templates.md` (template links), and `include.md` (content variables — title, author, document structure)
- [x] Checked pandoc version: 2.19.2 (compiled with pandoc-types 1.22.2.1)
- [x] Attempted a build run via `make.sh` — script executed, showing configuration variables (DEST=Output, FILE=document, PARSER=parser.pl, BIBFILE=Bibliography.bib)
- [x] Inspected `Output/` directory contents — found compiled artifacts: `document.tex`, `document.md`, `document.bbl`, `document.synctex(busy)`, plus auxiliary LaTeX files

### Obsidian Metadata Stripping
- [x] Identified that Obsidian YAML frontmatter (`related:` fields with wiki-links like `[[...|display text]]`) was leaking into compiled output, producing garbage lines like `◁ 1 - Jennings, 1990` in the PDF
- [x] Discovered the content files (e.g., `Chapter 0 - Abstract.md`, `Chapter 1 - Problem Statement.md`) each contain YAML frontmatter blocks with `related:` arrays of Obsidian wiki-links pointing to MOC (Map of Content) structures
- [x] Updated `templates/parser.pl` to strip Obsidian-specific content: added a frontmatter state machine (`$in_frontmatter` / `$frontmatter_seen` flags) that skips everything between the first `---` pair, and a regex to skip standalone `*Links:*`-style lines
- [x] Verified the fix works — MOC-only files (containing just frontmatter and no body text) produce empty output, while content files correctly output only the prose with LaTeX citations intact (e.g., `\citeauthor{Jennings-1990aa}`)

## Key Decisions

- The build pipeline follows: Scrivener/Obsidian → Perl parser (regex transforms via `parser.cfg`) → Pandoc (Markdown → LaTeX via `template.tex`) → pdflatex (with `-shell-escape`)
- The `include.md` file serves as both content configuration (title, author, institution) and chapter ordering via `sortspec.md`
- Frontmatter stripping is handled in `parser.pl` rather than `parser.cfg` because it requires stateful multi-line logic (tracking `---` delimiters), not simple regex substitution
- The parser uses a two-flag approach (`$in_frontmatter` + `$frontmatter_seen`) to handle only the first `---` block — subsequent `---` lines (e.g., horizontal rules in Markdown) pass through unaffected


### AI Summary (11:55:26)

### Build System Investigation (Prior Work)
- [x] Registered the Dissertation project directory with PAI via `PAI.md` frontmatter (slug: `dissertation`, status: active)
- [x] Created initial `TODO.md` with empty open items template
- [x] Reviewed existing project contents: `2026/` directory, `Notes.md`, `Deriving Second Formula Term.md`
- [x] Explored the `make.sh` build system — a custom Bash script for managing LaTeX compilation with functions: `_check()` (recursion guard), `_run()` (parse + pdflatex), `_pdf()` (build + open PDF), `_pdflatex()`, `_submit()`
- [x] Examined the Perl parser (`templates/parser.pl`) which reads `templates/parser.cfg` for regex-based text transformations (stripping Scrivener comments, inline images, handling quotes)
- [x] Reviewed template configuration files: `templates/sortspec.md` (chapter ordering), `templates/templates.md` (template links), and `include.md` (content variables — title, author, document structure)
- [x] Checked pandoc version: 2.19.2 (compiled with pandoc-types 1.22.2.1)
- [x] Attempted a build run via `make.sh` — script executed, showing configuration variables (DEST=Output, FILE=document, PARSER=parser.pl, BIBFILE=Bibliography.bib)
- [x] Inspected `Output/` directory contents — found compiled artifacts: `document.tex`, `document.md`, `document.bbl`, `document.synctex(busy)`, plus auxiliary LaTeX files

### Obsidian Metadata Stripping in parser.pl
- [x] Identified that Obsidian YAML frontmatter (`related:` fields with wiki-links like `[[...|display text]]`) was leaking into compiled output, producing garbage lines like `◁ 1 - Jennings, 1990` in the PDF
- [x] Discovered the content files (e.g., `Chapter 0 - Abstract.md`, `Chapter 1 - Problem Statement.md`) each contain YAML frontmatter blocks with `related:` arrays of Obsidian wiki-links pointing to MOC (Map of Content) structures
- [x] Updated `templates/parser.pl` to strip Obsidian-specific content: added a frontmatter state machine (`$in_frontmatter` / `$frontmatter_seen` flags) that skips everything between the first `---` pair, and a regex to skip standalone `*Links:*`-style lines
- [x] Verified the fix works — MOC-only files (containing just frontmatter and no body text) produce empty output, while content files correctly output only the prose with LaTeX citations intact (e.g., `\citeauthor{Jennings-1990aa}`)

### Table of Contents Corruption Fix
- [x] Identified that the TOC was broken — chapter entries were mangled, showing raw subsection numbers without proper nesting (e.g., `7.4.4 7.4.3.3 Program Level` on same line, `III Content Variables` appearing in the TOC)
- [x] Diagnosed root cause: `include.md` also has Obsidian YAML frontmatter (`links:` with wiki-link to Research Proposal), but the parser.pl stripping only applied to chapter content files — `include.md` was processed separately in `make.sh` at line ~703 via `cat | grep` pipeline
- [x] Traced the build flow in `make.sh`: `template.md` is processed first (line 703-706) to create the initial `document.md`, then `include.md` chapters are iterated (line 712-719) via `sortspec.md` to append content files
- [x] Fixed `make.sh` line 705 to apply the same frontmatter-stripping logic inline: added a Perl one-liner (`perl -ne 'if ($. == 1 && /^---\s*$/) { $skip=1; next } if ($skip && /^---\s*$/) { $skip=0; next } print unless $skip'`) plus `grep -v '^\*Links:\*'` to the `template.md` processing pipeline
- [x] Verified `include.md` now outputs cleanly — frontmatter block and `links:` line stripped, content starting from `# Content Variables` section onward
- [x] Confirmed chapter include paths resolve correctly: chapters 0-7 (Abstract through Methodology) are found in `Content/Matthias/Research Proposal/`
- [x] Encountered shell quoting issues during debugging — zsh conditional syntax errors with `\!` and `-d` operators in inline bash — resolved by adjusting the test commands

## Known Issues

- **Pandoc format deduction failure**: Pandoc cannot deduce the input format from the file extension, defaulting to HTML — likely needs explicit `-f markdown` flag in the `make.sh` pandoc call (line 748)
- **Exit code 64**: Pandoc invocation may still fail at the Markdown→LaTeX conversion step if the format flag isn't added
- `TODO.md` has no actual tasks populated yet — needs real dissertation work items

---

## Next Steps

- Fix the pandoc invocation in `make.sh` line 748 to specify input format explicitly (`-f markdown`)
- Run a full end-to-end build to verify PDF output is clean after the parser.pl fix
- Populate `TODO.md` with actual dissertation tasks

---

**Tags:** #dissertation #latex #build-system #pandoc #obsidian

---

## Next Steps

Session completed.

---

**Tags:**

---
[[_dissertation-master|← dissertation Master]]
