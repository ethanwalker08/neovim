# LazyVim Migration Workspace

This repository is a workflow-preservation migration from `nvim.bak/` to LazyVim.

Use the `LazyVim Migration` agent, prompts, and skills for migration work instead of treating this like a generic Neovim repo.

## Defaults

- Handle exactly one migration slice per session.
- Preserve workflows and muscle memory before implementation details.
- Prefer LazyVim defaults unless a real workflow gap exists.
- Reimplement behavior with LazyVim-native extension points instead of porting old plugin code.

## Required Reading For Migration Work

- `docs/migration_inventory.md`
- `docs/lazyvim_architecture.md`
- `docs/workflow_acceptance.md`
- `docs/migration_log.md`

## Required Inspection Before Edits

- `lua/config`
- `lua/plugins`
- `lazy-lock.json`
- `nvim.bak`

## File Placement

- Put keymaps, options, and autocmds in `lua/config`.
- Put plugin overrides and opts merges in `lua/plugins`.
- Do not place plugin-specific setup in `lua/config`.
- Do not place general editor behavior in plugin specs.

## Deliverables

- Keep code changes scoped to the current slice.
- Update migration docs when decisions, risks, or acceptance state change.
- Validate the touched slice before moving on.

See the migration instruction files under `.github/instructions/` for the detailed operating manual.
