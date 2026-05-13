---
name: LazyVim QA Slice
description: "QA one migration slice or the current migration state. Use for duplicate keymap checks, plugin overlap, mapping conflicts, load-order risks, and validation of touched behavior."
agent: "LazyVim Migration"
argument-hint: "Describe the slice, files, or risk area to QA."
---
Perform a focused QA pass for one LazyVim migration slice.

Requirements:
- Inspect the relevant current config surfaces.
- Look for duplicate keymaps, duplicate plugins, mapping conflicts, load-order issues, deprecated APIs, overwritten defaults, and unreachable mappings.
- Prefer findings first.
- Update the migration log if new warnings or rollback concerns are confirmed.