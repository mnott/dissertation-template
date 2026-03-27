# Session 0002: Dissertation Build System Exploration and Pandoc Debugging
<!-- TOPIC: Dissertation LaTeX Build Pipeline Exploration and Troubleshooting -->

**Date:** 2026-03-25
**Status:** Completed

**Completed:** 2026-03-25T11:50:42.887Z

---

## Work Done

- [x] Registered the Dissertation project directory (`/Users/i052341/Daten/Cloud/06 - Studium/DBA/8. Research/Dissertation`) with PAI via `PAI.md` frontmatter (slug: `dissertation`, status: active)
- [x] Created initial `TODO.md` with empty open items template
- [x] Reviewed existing project contents: `2026/` directory, `Notes.md`, `Deriving Second Formula Term.md`
- [x] Explored the `make.sh` build system — a custom Bash script for managing LaTeX compilation with functions: `_check()` (recursion guard), `_run()` (parse + pdflatex), `_pdf()` (build + open PDF), `_pdflatex()`, `_submit()`
- [x] Examined the Perl parser (`templates/parser.pl`) which reads `templates/parser.cfg` for regex-based text transformations (stripping Scrivener comments, inline images, handling quotes)
- [x] Reviewed template configuration files: `templates/sortspec.md` (chapter ordering), `templates/templates.md` (template links), and `include.md` (content variables — title, author, document structure)
- [x] Checked pandoc version: 2.19.2 (compiled with pandoc-types 1.22.2.1)
- [x] Attempted a build run via `make.sh` — script executed, showing configuration variables (DEST=Output, FILE=document, PARSER=parser.pl, BIBFILE=Bibliography.bib)
- [x] Inspected `Output/` directory contents — found compiled artifacts: `document.tex`, `document.md`, `document.bbl`, `document.synctex(busy)`, plus auxiliary LaTeX files
- [ ] Diagnosed pandoc warnings: "Could not deduce format from file extension" (defaulting to HTML) and "Unknown alias `Links`" — exit code 64 indicates a usage error

## Key Decisions

- The build pipeline follows: Scrivener → Perl parser (regex transforms via `parser.cfg`) → Pandoc (Markdown → LaTeX via `template.tex`) → pdflatex (with `-shell-escape`)
- The `include.md` file serves as both content configuration (title, author, institution) and chapter ordering via `sortspec.md`
- The dissertation topic is "Intrapreneurship at SAP: How To Identify the most Promising Team Members and Optimally Support them" — a DBA Research Proposal

## Known Issues

- **Pandoc format deduction failure**: Pandoc cannot deduce the input format from the file extension, defaulting to HTML — likely needs explicit `-f markdown` flag in the `make.sh` pandoc call (line 748)
- **Unknown alias `Links`**: The `*Links:*` Obsidian-style wiki link syntax in template files (e.g., line 78 of output) is not recognized by pandoc — the parser.cfg may need a rule to strip these before pandoc processing
- **Exit code 64**: Pandoc invocation fails completely, meaning the build pipeline is broken at the Markdown→LaTeX conversion step
- `TODO.md` has no actual tasks populated yet — needs real dissertation work items

---

## Next Steps

- Fix the pandoc invocation in `make.sh` line 748 to specify input format explicitly (`-f markdown`)
- Add a parser.cfg rule to strip `*Links:*` Obsidian metadata lines before pandoc processing
- Verify full build pipeline produces a valid PDF after fixes
- Populate `TODO.md` with actual dissertation tasks

---

**Tags:** #dissertation #latex #build-system #pandoc

---

## Next Steps

Session completed.

---

**Tags:**

---
[[_dissertation-master|← dissertation Master]]
