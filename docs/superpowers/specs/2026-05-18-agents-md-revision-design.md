# AGENTS.md Revision Design

## Goal

Revise the root-level `AGENTS.md` file to incorporate more specific project guidance around API design and naming conventions while preserving the existing compact format.

## Current Context

- The current `AGENTS.md` already defines the repository as a library.
- The current file already requires AutoHotkey v2 and disallows AutoHotkey v1.x patterns.
- The `Code Style` section already includes a more detailed One True Brace (OTB) description added manually by the user.
- The user wants that manual OTB detail preserved.

## Requested Additions

### 1. Reusable API Design Preference

The file should state that reusable library APIs should default to an object-oriented design. This should be phrased as a default preference rather than an absolute rule.

The guidance should make clear that:

- Classes with related methods are preferred for reusable library features.
- Standalone functions are still acceptable when the user explicitly asks for a function or when a function is the clearer fit.
- The purpose is to keep related behavior grouped behind a clear interface.

The file should include a concise example concept showing the intended shape:

- Prefer a class such as `String` with methods like `String.join()` and `String.array()`
- Instead of a surface made up primarily of separate top-level helpers like `StringJoin()` and `StringArray()`

### 2. Naming Conventions

The file should define variable and member naming expectations clearly:

- Use `camelCase` for methods.
- Use `camelCase` for class member variables.
- Use `snake_case` for local variables.
- Use `snake_case` for global variables.

These rules should live in the `Naming And Organization` section alongside the API-shape guidance.

## Section-Level Design

### Code Style

Keep the expanded OTB guidance exactly as the user revised it. Do not collapse it back into a shorter summary.

### Naming And Organization

Expand this section to include:

- The reusable API design preference for classes and methods.
- The naming convention rules for methods, member variables, local variables, and globals.
- Existing guidance around descriptive names and grouping related functionality.

## Tone

The revised file should remain concise and directive. The new content should add clarity without turning `AGENTS.md` into a long handbook.

## Success Criteria

- The file preserves the user-added OTB details.
- The file states that reusable library APIs should default to OOP-style classes and methods.
- The file makes clear that this is a default preference, not a blanket ban on functions.
- The file explicitly defines `camelCase` for methods and class member variables.
- The file explicitly defines `snake_case` for local and global variables.
