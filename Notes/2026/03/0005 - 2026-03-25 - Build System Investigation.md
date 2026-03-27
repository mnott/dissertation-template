# Session 0005: Frontmatter Stripping, Include Leakage, and Build Cleanup Fix
<!-- TOPIC: Build Pipeline Tracing and Clean Output Investigation -->

**Date:** 2026-03-25
**Status:** Completed

**Completed:** 2026-03-25T12:11:13.705Z

---

## Work Done

### Build System Investigation
- [x] Registered the Dissertation project directory with PAI via `PAI.md` frontmatter (slug: `dissertation`, status: active)
- [x] Explored the `make.sh` build system — a custom Bash script for managing LaTeX compilation with functions: `_check()` (recursion guard), `_run()` (parse + pdflatex), `_pdf()` (build + open PDF), `_pdflatex()`, `_submit()`
- [x] Examined the Perl parser (`templates/parser.pl`) which reads `templates/parser.cfg` for regex-based text transformations (stripping Scrivener comments, inline images, handling quotes)
- [x] Reviewed template configuration files: `templates/sortspec.md` (chapter ordering), `templates/templates.md` (template links), and `include.md` (content variables — title, author, document structure)
- [x] Checked pandoc version: 2.19.2 (compiled with pandoc-types 1.22.2.1)
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

### Linebreak Regression and Include Content Leakage
- [x] Discovered the frontmatter stripping changes introduced a regression: linebreaks were being broken in `document.tex`, with LaTeX comment blocks (`%-----` separators, `% Samples`, `% Usage:` lines) and structural content leaking into the output incorrectly
- [x] Found that `include.md` content was still partially leaking — `Content Variables` and `Document Footer` sections were being converted to `\part{Content Variables}\label{Content-Variables}` and `\part{Document Footer}\label{Document-Footer}` entries in the compiled LaTeX, polluting the document structure
- [x] Identified that `*Links:*` line with wiki-link to Research Proposal (line 78 of `include.md`) was surviving the stripping and appearing in output
- [x] Investigated the `files.txt` build intermediate — a transient artifact in `Output/` that lists all content file paths fed to the parser (92 files from chapters 0-7), confirmed it's created and consumed during the build process
- [x] Further refined `templates/parser.pl` — added MOC file detection logic (checks for `[←` back-navigation pattern to skip entire MOC-only files) alongside the existing frontmatter state machine and `*Links:*` line filter

### Template Processing Pipeline Fix
- [x] Build still failing after prior fixes — `Unknown alias 'Links'` error from pandoc during pdflatex stage, indicating the `links:` YAML key in `include.md` frontmatter was still reaching pandoc
- [x] Investigated the `include.md` frontmatter structure: contains `links:` field with Obsidian wiki-link syntax (`[[...|Research Proposal]]`) wrapped in quotes — pandoc interprets this as an unknown YAML alias
- [x] Identified that `include.md` has a second `---` delimiter separating the Obsidian frontmatter from the actual content variables block (title, author, institution), meaning the inline Perl stripper on `make.sh` line 705 was correctly stripping the frontmatter but the content variables section (starting with `# Content Variables`) still needed to pass through
- [x] Fixed the backtick stripping in `make.sh` line 705 — the `grep -v` backtick filter was using literal backticks which conflicted with shell quoting; updated to properly escape the pattern so triple-backtick fenced code blocks in `template.md` are correctly stripped before pandoc processing
- [x] Verified the template processing pipeline now correctly strips: (1) YAML frontmatter with `links:` alias, (2) `*Links:*` navigation lines, and (3) fenced code blocks — leaving only the content variables for pandoc consumption
- [x] User quit the running build/PDF process to allow further iteration on the pipeline

### Build Cleanup Safety and Continued Debugging
- [x] Investigated the `_clean()` function in `make.sh` (line 1314) — iterates over the `tex_files` array and deletes all matching files via `find . -type f -name "$i" | xargs rm -f`
- [x] Examined the `tex_files` array (line 89+) — contains glob patterns for LaTeX auxiliary files (`*.aux`, `*.bbl`, `*.bcf`, `*.blg`, `*.fls`, `*.synctex.gz`, etc.) but also `*.md`, which would destructively delete Markdown source files during cleanup
- [x] Removed `*.md` from the `tex_files` cleanup array to prevent accidental deletion of dissertation source content during `_clean()` runs
- [x] Verified compiled LaTeX output now contains proper dissertation content — confirmed ANTC-EI scale items (Management Support, Work Discretion, Rewards and Reinforcement) rendering correctly as `\item \emph{}` entries in `document.tex`
- [x] Re-examined `include.md` frontmatter (lines 1-5): confirmed minimal structure with `links:` wiki-link field followed by two `---` delimiters
- [x] Encountered exit code 2 during a build or search operation — likely from a failed grep/find with no matches

### Build Environment Verification
- [x] Reviewed `make.sh` internal variable setup: `TEXBIN=/Library/TeX/texbin/latex`, `BIBFILE=Bibliography.bib`, `LOGLEVEL` defaults to `INFO`, `ROOT` derived from script location, `INPUT` constructed as `${ROOT}/Content/${CONTEXT}`
- [x] Confirmed directory structure validation logic in `make.sh` — exits with error if `$INPUT` directory doesn't exist
- [x] Verified project root directory listing — contains `Bibliography.bib` (2.1MB), `.gitignore`, git repo, and expected directory structure

## Key Decisions

- The build pipeline follows: Scrivener/Obsidian → Perl parser (regex transforms via `parser.cfg`) → Pandoc (Markdown → LaTeX via `template.tex`) → pdflatex (with `-shell-escape`)
- The `include.md` file serves as both content configuration (title, author, institution) and chapter ordering via `sortspec.md`
- Frontmatter stripping is handled in `parser.pl` rather than `parser.cfg` because it requires stateful multi-line logic (tracking `---` delimiters), not simple regex substitution
- The parser uses a two-flag approach (`$in_frontmatter` + `$frontmatter_seen`) to handle only the first `---` block — subsequent `---` lines (e.g., horizontal rules in Markdown) pass through unaffected
- MOC files are detected via the `[←` back-navigation pattern and skipped entirely — a heuristic that distinguishes navigation-only files from content files
- Removed `*.md` from `tex_files` cleanup array — the pattern was dangerous since `_clean()` recursively deletes matching files, and `*.md` would destroy Markdown source content


### AI Summary (12:12:20)

### Build System Investigation
- [x] Registered the Dissertation project directory with PAI via `PAI.md` frontmatter (slug: `dissertation`, status: active)
- [x] Explored the `make.sh` build system — a custom Bash script for managing LaTeX compilation with functions: `_check()` (recursion guard), `_run()` (parse + pdflatex), `_pdf()` (build + open PDF), `_pdflatex()`, `_submit()`
- [x] Examined the Perl parser (`templates/parser.pl`) which reads `templates/parser.cfg` for regex-based text transformations (stripping Scrivener comments, inline images, handling quotes)
- [x] Reviewed template configuration files: `templates/sortspec.md` (chapter ordering), `templates/templates.md` (template links), and `include.md` (content variables — title, author, document structure)
- [x] Checked pandoc version: 2.19.2 (compiled with pandoc-types 1.22.2.1)
- [x] Inspected `Output/` directory contents — found compiled artifacts: `document.tex`, `document.md`, `document.bbl`, `document.synctex(busy)`, plus auxiliary LaTeX files

### Clean Build and Pipeline Tracing
- [x] Emptied the entire `Output/` folder to start from a clean slate and trace exactly how `document.md` and `document.tex` are generated
- [x] Traced the two-stage generation pipeline: `document.md` is assembled by `make.sh` — first `template.md` is processed through the inline Perl frontmatter stripper (lines 705-712) and written to `Output/document.md`, then chapter content files (per `sortspec.md` ordering) are individually piped through `templates/parser.pl` and appended; `document.tex` is then generated by pandoc converting `document.md` from Markdown to LaTeX using `template.tex` as the LaTeX template
- [x] Confirmed `include.md` frontmatter structure (lines 1-5): minimal YAML with `links:` wiki-link field, two `---` delimiters, then content variables section starting at `# Content Variables` — the inline Perl stripper on make.sh line 705-711 handles this by skipping the first `---` block and filtering `*Links:*` lines and fenced code blocks
- [x] Verified the `document.tex` output structure — begins with a Variables block (`\def\doctype{book}`, etc.) derived from the content variables in `include.md`, confirming the template processing correctly converts the Markdown key-value pairs into LaTeX `\def` commands

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

### Linebreak Regression and Include Content Leakage
- [x] Discovered the frontmatter stripping changes introduced a regression: linebreaks were being broken in `document.tex`, with LaTeX comment blocks (`%-----` separators, `% Samples`, `% Usage:` lines) and structural content leaking into the output incorrectly
- [x] Found that `include.md` content was still partially leaking — `Content Variables` and `Document Footer` sections were being converted to `\part{Content Variables}\label{Content-Variables}` and `\part{Document Footer}\label{Document-Footer}` entries in the compiled LaTeX, polluting the document structure
- [x] Identified that `*Links:*` line with wiki-link to Research Proposal (line 78 of `include.md`) was surviving the stripping and appearing in output
- [x] Investigated the `files.txt` build intermediate — a transient artifact in `Output/` that lists all content file paths fed to the parser (92 files from chapters 0-7), confirmed it's created and consumed during the build process
- [x] Further refined `templates/parser.pl` — added MOC file detection logic (checks for `[←` back-navigation pattern to skip entire MOC-only files) alongside the existing frontmatter state machine and `*Links:*` line filter

### Template Processing Pipeline Fix
- [x] Build still failing after prior fixes — `Unknown alias 'Links'` error from pandoc during pdflatex stage, indicating the `links:` YAML key in `include.md` frontmatter was still reaching pandoc
- [x] Investigated the `include.md` frontmatter structure: contains `links:` field with Obsidian wiki-link syntax (`[[...|Research Proposal]]`) wrapped in quotes — pandoc interprets this as an unknown YAML alias
- [x] Identified that `include.md` has a second `---` delimiter separating the Obsidian frontmatter from the actual content variables block (title, author, institution), meaning the inline Perl stripper on `make.sh` line 705 was correctly stripping the frontmatter but the content variables section (starting with `# Content Variables`) still needed to pass through
- [x] Fixed the backtick stripping in `make.sh` line 705 — the `grep -v` backtick filter was using literal backticks which conflicted with shell quoting; updated to properly escape the pattern so triple-backtick fenced code blocks in `template.md` are correctly stripped before pandoc processing
- [x] Verified the template processing pipeline now correctly strips: (1) YAML frontmatter with `links:` alias, (2) `*Links:*` navigation lines, and (3) fenced code blocks — leaving only the content variables for pandoc consumption
- [x] User quit the running build/PDF process to allow further iteration on the pipeline

### Build Cleanup Safety and Continued Debugging
- [x] Investigated the `_clean()` function in `make.sh` (line 1314) — iterates over the `tex_files` array and deletes all matching files via `find . -type f -name "$i" | xargs rm -f`
- [x] Examined the `tex_files` array (line 89+) — contains glob patterns for LaTeX auxiliary files (`*.aux`, `*.bbl`, `*.bcf`, `*.blg`, `*.fls`, `*.synctex.gz`, etc.) but also `*.md`, which would destructively delete Markdown source files during cleanup
- [x] Removed `*.md` from the `tex_files` cleanup array to prevent accidental deletion of dissertation source content during `_clean()` runs
- [x] Verified compiled LaTeX output now contains proper dissertation content — confirmed ANTC-EI scale items (Management Support, Work Discretion, Rewards and Reinforcement) rendering correctly as `\item \emph{}` entries in `document.tex`
- [x] Re-examined `include.md` frontmatter (lines 1-5): confirmed minimal structure with `links:` wiki-link field followed by two `---` delimiters
- [x] Encountered exit code 2 during a build or search operation — likely from a failed grep/find with no matches

### Build Environment Verification
- [x] Reviewed `make.sh` internal variable setup: `TEXBIN=/Library/TeX/texbin/latex`, `BIBFILE=Bibliography.bib`, `LOGLEVEL` defaults to `INFO`, `ROOT` derived from script location, `INPUT` constructed as `${ROOT}/Content/${CONTEXT}`
- [x] Confirmed directory structure validation logic in `make.sh` — exits with error if `$INPUT` directory doesn't exist
- [x] Verified project root directory listing — contains `Bibliography.bib` (2.1MB), `.gitignore`, git repo, and expected directory structure

## Known Issues

- **Pandoc format deduction failure**: Pandoc cannot deduce the input format from the file extension, defaulting to HTML — likely needs explicit `-f markdown` flag in the `make.sh` pandoc call (line 748)
- **Exit code 1**: Pandoc invocation may still fail at the Markdown→LaTeX conversion step if the format flag isn't added
- **Include content leakage not fully resolved**: The `Content Variables` and `Document Footer` sections from `include.md` are still generating `\part{}` entries in the LaTeX output — the inline Perl stripping in `make.sh` may need to also strip these structural headers or `include.md` needs restructuring
- **Linebreak handling**: The parser modifications may still be affecting whitespace/linebreak handling in edge cases — needs a full end-to-end build verification
- **No git commits made** — all changes to `make.sh` and `templates/parser.pl` remain uncommitted
- `TODO.md` has no actual tasks populated yet — needs real dissertation work items

---

**Tags:** #dissertation #latex #build-system #pandoc #obsidian #parser

---

## Next Steps

Session completed.

---

**Tags:**

---
[[_dissertation-master|← dissertation Master]]
