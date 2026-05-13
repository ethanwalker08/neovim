---
name: LazyVim Migration Manual
description: "Use when planning, auditing, or implementing the LazyVim migration from nvim.bak. Covers workflow preservation, one-slice discipline, classification, file placement, validation, and required documentation updates."
---
# LazyVim Migration Operating Manual

Use this instruction for any migration task in this repository.

## Mission
- Preserve existing workflows, muscle memory, and productivity.
- Keep the target configuration simpler and more maintainable than the old setup.
- Respect LazyVim conventions.
- Avoid plugin duplication and speculative compatibility code.

## Core Principles

### Workflow over implementation
- Do not migrate plugin code directly.
- Identify the user-facing workflow first.
- Preserve the workflow with LazyVim-native tools whenever possible.

### LazyVim defaults win unless a workflow gap is proven
- Check whether LazyVim already provides the behavior.
- Reuse defaults and add aliases only when muscle memory needs them.
- Do not recreate functionality that already exists upstream.

### One migration slice at a time
- Allowed slices: global keymaps, terminal workflows, git workflows, search workflows, LSP workflows, completion workflows, UI workflows, plugin-specific behavior.
- Do not modify multiple slices in one session.

### Documentation is project memory
- Treat these files as authoritative:
  - `docs/migration_inventory.md`
  - `docs/lazyvim_architecture.md`
  - `docs/workflow_acceptance.md`
  - `docs/migration_log.md`
- Update them whenever migration decisions, risks, or acceptance state change.

### No speculation
- Never assume plugin APIs, keymaps, LazyVim defaults, load order, or plugin capabilities.
- Inspect the actual code before changing behavior.

## Required Inspection Order
1. Read the migration docs.
2. Inspect `lua/config`, `lua/plugins`, `lazy-lock.json`, and the relevant source files in `nvim.bak`.
3. Identify the owning abstraction for the requested behavior.
4. Form one falsifiable local hypothesis and one cheap validation check before the first edit.

## Migration Classifications
- `keep exactly`: preserve the behavior as-is.
- `adapt to LazyVim`: preserve the workflow, but reimplement it with LazyVim-native tools.
- `already provided by LazyVim`: keep the default behavior and avoid redundant code.
- `discard`: do not migrate it.
- `defer until workflow gap proven`: leave it alone unless a concrete gap appears.

## File Placement Rules
- Use `lua/config` for keymaps, options, and autocmds.
- Use `lua/plugins` for plugin overrides, opts merges, and plugin-specific customizations.
- Do not restore old module layouts from `nvim.bak`.

## Validation Rules
- After the first substantive edit, run the narrowest focused validation available.
- Prefer a slice-specific check, then a narrow test, then a narrow compile or lint check.
- Use diff-only inspection only when no executable validation exists.

## Required Deliverables
- Code changes only for the current slice.
- An explanation of what changed and why those file locations were correct.
- Risk analysis covering compatibility and rollback concerns.
- Documentation updates for the migration state.

## Anti-Patterns
- Porting old plugin modules wholesale.
- Re-adding plugins without proving a workflow gap.
- Blindly overriding LazyVim defaults.
- Making large unvalidated changes.
- Skipping documentation updates.