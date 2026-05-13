---
name: LazyVim Implement Slice
description: "Implement one LazyVim migration slice end to end. Use for scoped code changes, validation, and required migration doc updates."
agent: "LazyVim Migration"
argument-hint: "Describe the single workflow slice to implement and the old behavior to preserve."
---
Implement exactly one LazyVim migration slice from `nvim.bak` into the current config.

Requirements:
- Read the migration docs and inspect current ownership before editing.
- Form one falsifiable local hypothesis before the first edit.
- Make the smallest correct change.
- Run focused validation immediately after the first substantive edit.
- Update the migration docs for decisions, acceptance, and risk state.
- Do not touch unrelated slices.