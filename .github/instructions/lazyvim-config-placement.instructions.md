---
name: LazyVim Config Placement
description: "Use when editing LazyVim config files under lua/config or lua/plugins during migration work. Covers where keymaps, options, autocmds, plugin opts merges, and plugin-specific overrides belong."
applyTo:
  - "lua/config/**"
  - "lua/plugins/**"
---
# LazyVim Config Placement

## Placement Rules
- Put keymaps, options, and autocmds in `lua/config`.
- Put plugin opts merges, plugin aliases, and plugin-specific overrides in `lua/plugins`.
- Prefer minimal overrides over full plugin replacement.
- Keep public behavior intact and avoid unrelated refactors.

## Migration-Specific Rules
- Implement exactly one migration slice at a time.
- Preserve workflow intent instead of copying old plugin APIs.
- Check `docs/migration_inventory.md` before deciding to add custom code.
- If the requested behavior is already covered by LazyVim, prefer aliases or documentation over new implementation.