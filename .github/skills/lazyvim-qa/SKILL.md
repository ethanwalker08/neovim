---
name: lazyvim-qa
description: 'QA a LazyVim migration slice or the current migration state. Use for duplicate keymap checks, plugin overlap, mapping conflicts, load-order bugs, deprecated APIs, overwritten defaults, and startup-risk reviews.'
argument-hint: 'Describe the slice, files, or behavior to QA.'
user-invocable: true
---

# LazyVim QA

## When to Use
- After implementing a migration slice.
- Before declaring a slice complete.
- When a workflow feels off and you need a structured risk review.

## Procedure
1. Inspect `lua/config`, `lua/plugins`, `lazy-lock.json`, and the touched migration docs.
2. Check for duplicate keymaps, duplicate plugins, conflicting leader mappings, unreachable mappings, load-order issues, deprecated APIs, overwritten defaults, and startup regressions.
3. Prefer focused validation for the touched slice before broad inspection.
4. Record confirmed warnings, rollback concerns, and cleanup items in `docs/migration_log.md`.

## Deliverable
- Findings ordered by severity.
- Validation performed.
- Remaining risks and follow-up actions.