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

## Commits

- Make commits as atomic as practical.
- Avoid mixing unrelated changes in the same commit.
- Write short but specific commit messages that describe the change clearly.
- If additional context is needed, put it in the commit description or body.
