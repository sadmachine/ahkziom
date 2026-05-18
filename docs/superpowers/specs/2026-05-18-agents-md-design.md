# AGENTS.md Design

## Goal

Create a root-level `AGENTS.md` file for this repository that gives contributors and AI agents concise guidance for working in the project.

## Project Context

- Repository name: `ahkxiom`
- Current repository shape is minimal, with only a `README.md` present.
- The requested guidance should emphasize that this repository is a library.
- The requested guidance should explicitly require AutoHotkey v2 syntax and reject AutoHotkey v1.x syntax and compatibility patterns.

## Proposed AGENTS.md Scope

The file should be a compact policy document with practical contributor guidance. It should avoid workflow overhead and focus on the rules most likely to prevent incorrect changes.

## Proposed Sections

### 1. Project Overview

State that this repository is a library rather than an end-user application. Guidance should encourage contributors to keep reusable APIs and module design in mind.

### 2. Language Baseline

State that all code in this repository must use AutoHotkey v2 syntax and APIs. The file should explicitly say not to introduce AutoHotkey v1.x syntax, command-style statements, legacy compatibility shims, or mixed-style examples.

### 3. Code Style

Document the core formatting rules:

- Use One True Brace (OTB) style.
- Use consistent indentation.
- Prefer straightforward, readable code over clever shorthand.
- Keep style guidance minimal and actionable.

### 4. Naming and Organization

Document basic naming expectations for source files and symbols. The guidance should favor clear, descriptive names and keep related functionality grouped together instead of creating fragmented files.

### 5. Comments and Documentation

State that comments should explain intent when it is not obvious from the code. Avoid redundant comments. Public-facing library behavior and usage expectations should be documented where appropriate.

### 6. Change Expectations

State that contributors and AI agents should preserve AHKv2 consistency, follow the documented style rules, and avoid introducing patterns that make the library harder to consume or maintain.

## Tone

The `AGENTS.md` file should be direct, concise, and normative. It should read like project guidance rather than a long-form handbook.

## Non-Goals

- No detailed contributor workflow.
- No branching or commit policy.
- No testing policy beyond what is necessary to preserve consistency.
- No backward-compatibility guidance for AutoHotkey v1.x.

## Success Criteria

- A new contributor can immediately tell that this is an AutoHotkey library.
- A contributor cannot reasonably mistake the codebase for AutoHotkey v1.x.
- OTB brace style is explicitly required.
- The file remains short enough to scan quickly.
