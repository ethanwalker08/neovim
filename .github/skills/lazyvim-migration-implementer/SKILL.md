---
name: lazyvim-migration-implementer
description: 'Implement one LazyVim migration slice. Use for scoped code changes that preserve muscle memory, follow LazyVim file placement rules, update migration docs, and validate the touched behavior.'
argument-hint: 'Describe the single migration slice to implement and the workflow to preserve.'
user-invocable: true
---

# LazyVim Migration Implementation

## When to Use
- The migration path is clear and the next step is code changes.
- Only one workflow slice needs to be implemented.

## Procedure
1. Read the migration docs before editing.
2. Inspect the owning code path in the current config and the matching source in `nvim.bak`.
3. State one local hypothesis and one focused validation check before the first edit.
4. Make the smallest change in the correct location:
   - `lua/config` for keymaps, options, autocmds
   - `lua/plugins` for plugin overrides and opts merges
5. Validate immediately after the first substantive edit.
6. Update `docs/migration_log.md` and `docs/workflow_acceptance.md` when the slice state changes.

## Guardrails
- Do not migrate multiple categories.
- Do not port old modules wholesale.
- Do not modify unrelated files.
- Prefer LazyVim-native extension points over plugin-specific rewrites.