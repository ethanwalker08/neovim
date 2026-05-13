---
name: lazyvim-migration-architect
description: 'Plan a single LazyVim migration slice. Use for architecture review, classifying old nvim.bak workflows, identifying the owning implementation surface, and deciding whether LazyVim already covers the behavior.'
argument-hint: 'Describe the single workflow slice, old behavior, and target files or docs.'
user-invocable: true
---

# LazyVim Migration Architecture

## When to Use
- Planning a migration slice before any edits.
- Deciding whether a workflow should be kept exactly, adapted, discarded, or left to LazyVim defaults.
- Figuring out where the behavior belongs in `lua/config` or `lua/plugins`.

## Procedure
1. Read `docs/migration_inventory.md`, `docs/lazyvim_architecture.md`, `docs/workflow_acceptance.md`, and `docs/migration_log.md`.
2. Inspect the matching behavior in `nvim.bak`, `lua/config`, `lua/plugins`, and `lazy-lock.json`.
3. Classify the workflow with one of the repo migration labels.
4. Identify one falsifiable local hypothesis about the owning code path.
5. Recommend the smallest implementation surface and the cheapest validation check.

## Deliverable
- Workflow classification.
- Target file locations.
- LazyVim-native implementation direction.
- Main compatibility risks.