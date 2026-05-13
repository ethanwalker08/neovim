---
name: LazyVim Migration Docs
description: "Use when editing migration reference files such as migration_inventory, migration_log, workflow_acceptance, or lazyvim_architecture. Covers required fields, classification language, and acceptance tracking for the LazyVim migration."
applyTo:
  - "docs/migration_inventory.md"
  - "docs/migration_log.md"
  - "docs/workflow_acceptance.md"
  - "docs/lazyvim_architecture.md"
---
# LazyVim Migration Docs

## Inventory Updates
- Record the workflow classification explicitly.
- Capture the old source, the reasoning, the LazyVim-native equivalent, and key risks.
- Update decisions when new evidence changes the migration path.

## Log Updates
- Record the migration slice, date, files changed, validation performed, and remaining risks.
- Note rollback concerns and any follow-up cleanup required.

## Acceptance Updates
- Only mark checklist items complete when the behavior is actually implemented and validated.
- Keep acceptance items behavior-focused, not implementation-focused.

## Architecture Notes
- Document plugin ownership and file placement decisions.
- Prefer concise explanations of why LazyVim-native choices replaced old implementations.