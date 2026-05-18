# AGENTS.md Revision Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `AGENTS.md` to preserve the expanded OTB style guidance while adding an object-oriented default for reusable library APIs and explicit naming rules for methods, class member variables, local variables, and globals.

**Architecture:** This change modifies a single documentation file at the repository root. The update should keep the file compact while expanding the `Naming And Organization` section to cover API shape and naming conventions, and leaving the user-edited `Code Style` section intact.

**Tech Stack:** Markdown, repository documentation

---

### Task 1: Revise The Root AGENTS.md File

**Files:**
- Modify: `AGENTS.md`
- Reference: `docs/superpowers/specs/2026-05-18-agents-md-revision-design.md`

- [ ] **Step 1: Update `AGENTS.md` to add the approved API design and naming guidance**

```md
# AGENTS.md

## Project Overview

This repository is a library. Favor reusable APIs, clear module boundaries, and maintainable public-facing behavior over application-specific shortcuts.

## Language Baseline

- Use AutoHotkey v2 syntax and APIs only.
- Do not introduce AutoHotkey v1.x syntax.
- Do not use command-style legacy statements.
- Do not add compatibility shims or mixed v1/v2 examples unless the project explicitly adds that requirement later.

## Code Style

- Use One True Brace (OTB) style.
  - Top level blocks (classes, methods, functions, etc) should put the opening brace `{` on the following line
  - Control flow blocks (if, for, while, etc) should put the opening brace `{` on the same line
  - Control flow blocks should always wrap their expression in braces, i.e. `if (<expression) { ...`, `for (a, b in c) { ...`
- Keep formatting and indentation consistent within each file.
- Prefer straightforward, readable code over dense shorthand.
- Keep functions and classes focused on a clear responsibility.

## Naming And Organization

- Use clear, descriptive names for files, functions, classes, variables, and parameters.
- Default reusable library APIs to classes with related methods rather than collections of standalone helper functions.
- Prefer grouped interfaces such as `String.join()` and `String.array()` over separate top-level helpers such as `StringJoin()` and `StringArray()` when designing reusable library features.
- Use `camelCase` for methods and class member variables.
- Use `snake_case` for local variables and global variables.
- Group related functionality together instead of scattering small pieces across many files.
- Keep public library entry points easy to find.

## Comments And Documentation

- Use comments to explain intent when the code is not self-evident.
- Avoid redundant comments that restate the code.
- Document public behavior and usage expectations where appropriate.

## Change Expectations

- Preserve AHKv2 consistency across the codebase.
- Follow the documented style rules when adding or editing code.
- Avoid introducing patterns that make the library harder to understand, use, or maintain.
```

- [ ] **Step 2: Review the file for alignment with the approved revision design**

Check that the file clearly does all of the following:

- Preserves the expanded OTB bullets exactly.
- States that reusable library APIs should default to classes and related methods.
- Makes that guidance a preference rather than a blanket ban on functions.
- Defines `camelCase` for methods and class member variables.
- Defines `snake_case` for local and global variables.

Expected result: all five checks pass and the file remains concise.

- [ ] **Step 3: Verify repository state**

Run: `git status --short`
Expected: `AGENTS.md` shows as modified and the new spec and plan files remain present; no unintended files are changed by this task.

- [ ] **Step 4: Commit**

```bash
git add AGENTS.md docs/superpowers/specs/2026-05-18-agents-md-revision-design.md docs/superpowers/plans/2026-05-18-agents-md-revision.md
git commit -m "docs: refine AGENTS guidance"
```

Expected: a new commit records the revised spec, plan, and updated `AGENTS.md` file.
