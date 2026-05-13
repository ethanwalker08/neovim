---
name: lazyvim-workflow-auditor
description: 'Audit one workflow aspect changed by comparing nvim.bak with the current LazyVim config. Use for finding behavior mismatches, muscle-memory risks, and missing aliases or adaptations.'
argument-hint: 'Describe the workflow aspect, behavior, or file area to audit.'
user-invocable: true
---

# LazyVim Workflow Auditor

## When to Use
- Reviewing whether a workflow still behaves like the old config.
- Comparing keymaps, terminal flows, search, git, LSP, or completion behavior.

## Procedure
1. Compare the relevant source in `nvim.bak` with the current LazyVim config.
2. Identify the old behavior, the current behavior, and any mismatch.
3. Estimate muscle-memory impact.
4. Recommend whether LazyVim defaults should win, an alias is enough, or the workflow needs adaptation.
5. Update `docs/migration_inventory.md` if the audit changes the migration record.

## Deliverable
- Old behavior.
- Current behavior.
- Impact on workflow.
- Recommended next action.