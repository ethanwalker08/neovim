---
name: lazyvim-qa
description: 'QA a LazyVim migration step or the current migration state. Use for duplicate keymap checks, plugin overlap, mapping conflicts, load-order bugs, deprecated APIs, overwritten defaults, and startup-risk reviews.'
argument-hint: 'Describe the steps taken, files changed, or behavior to test.'
user-invocable: true
---

# LazyVim QA

## When to Use
- After implementing a migration step.
- Before declaring a step complete.
- When a workflow feels off and you need a structured risk review.

## Procedure
1. Read the migration docs before testing.
2. State one local hypothesis and one focused validation check before testing.
3. Perform the check with a headless `nvim` command or a normal session.
4. Update `docs/migration_log.md` and `docs/workflow_acceptance.md` when finished.

## Deliverable
- Findings ordered by severity.
- Validation performed.
- Remaining risks and follow-up actions.