# Personal LazyVim Neovim Config

This repository is my active Neovim setup, built on top of [LazyVim](https://github.com/LazyVim/LazyVim) and `lazy.nvim`.

The old standalone config still lives in `nvim.bak/` as a migration reference, but the active configuration is the repo root. Not every old behavior is being carried forward unchanged. The migration docs in `docs/` track what has been preserved, adapted, or intentionally dropped.

## What This Repo Contains

- A LazyVim-based Neovim config with local overrides for theme, completion, Copilot, formatting, keymaps, terminal workflows, LSP navigation, and key hints.
- `leader` set to `<Space>`.
- `which-key.nvim` as the active key-hint system.
- LazyVim's `vscode` extra already enabled, so there is no separate VS Code branch for this setup.
- `nvim.bak/` kept in-tree only as a source of truth during migration.

## Quick Start

Clone or link this repository to `~/.config/nvim`, then start Neovim:

```bash
git clone <repo> ~/.config/nvim
nvim
```

On first launch, `lazy.nvim` bootstraps itself automatically and installs plugins from the pinned lockfile.

Useful built-in management commands:

- `:Lazy` for plugin state, updates, and profiling
- `:Mason` for external tool management
- `:checkhealth` for environment diagnostics

## Optional External Tools

Some migrated workflows depend on external CLIs:

- `lazygit` for `<leader>lg`
- `copilot` CLI for `<leader>cc`
- a Nerd Font for icons and UI glyphs

## Enabled LazyVim Extras

The active extras are declared in `lazyvim.json`. Right now the setup includes:

- Copilot
- LuaSnip
- Yanky
- core DAP support
- Telescope
- Prettier formatting
- JSON, Markdown, and TOML language support
- ESLint integration
- mini.hipatterns
- Octo
- project utilities
- VS Code integration

## Repository Layout

- `init.lua`: early globals that must exist before LazyVim resolves extras
- `lazyvim.json`: enabled LazyVim extras
- `lua/config/`: global options, keymaps, and autocmds
- `lua/plugins/`: plugin additions and plugin-specific overrides
- `docs/`: migration architecture, inventory, acceptance criteria, and session log
- `nvim.bak/`: legacy config kept only for migration reference

## Current Workflow Highlights

### Key Hints

Press `<Space>` in normal mode to open which-key hints for the active leader groups.

### File and Session Basics

- `<leader>w`: write the current buffer
- `<leader>qq`: quit Neovim
- `<leader>qb`: delete the current buffer
- `<leader>e`: toggle the explorer
- `<leader>E`: open the explorer using the current working directory
- `<leader>f`: format the current buffer

### Search and Picker Workflows

- `<leader>sf`: search files
- `<leader>sg`: live grep
- `<leader>sk`: search keymaps
- `<leader>sh`: search help tags
- `<leader>s.`: recent files
- `<leader>s/`: open buffers
- `<leader>/`: fuzzy search the current buffer
- `<leader>sn`: search this Neovim config

### Git and Terminal Workflows

- `<leader>lg`: open LazyGit
- `<leader>t`: toggle a reusable floating shell terminal
- `<leader>cc`: toggle a reusable floating Copilot CLI terminal
- `<Esc>` in terminal mode hides migrated floating terminals

### LSP and Completion Workflows

- `<leader>gd`: picker-based goto definition
- `<leader>gi`: picker-based goto implementation
- `<leader>gt`: picker-based goto type definition
- `<leader>cd`: hover documentation
- `<leader>ca`: code actions
- Blink completion uses a manual popup: `<C-Space>` toggles the menu, `<CR>` accepts, `<C-J>` selects the next item, and `<Tab>` prioritizes Copilot suggestions before completion or snippet flow.

## Customizing This Config

This repo no longer uses the backup layout from `nvim.bak/` such as `vim.pack` or `lua/custom/*`.

- Put general editor behavior in `lua/config/options.lua`, `lua/config/keymaps.lua`, and `lua/config/autocmds.lua`.
- Put plugin ownership and plugin overrides in `lua/plugins/*.lua`.
- Enable or disable LazyVim extras in `lazyvim.json`.
- Use `nvim.bak/` as reference material only, not as an import target for active config code.

## Formatting, Copilot, and Theme Notes

- Prettier follows LazyVim's extra plus a repo-local config gate, so JS and TS formatting only takes the Prettier path when the project opts into Prettier.
- `copilot.lua` suggestions are enabled, but `.env` and `.env.*` buffers are intentionally blocked from attaching.
- Blink's Copilot completion source is disabled. Copilot is used here as inline suggestion support, not as a completion-menu source.
- The active colorscheme is a One Dark variant implemented through `onedarkpro.nvim`.

## Migration Docs

If you are continuing the migration from `nvim.bak/`, start with:

- `docs/lazyvim_architecture.md`
- `docs/migration_inventory.md`
- `docs/workflow_acceptance.md`
- `docs/migration_log.md`

## License

MIT. See `LICENSE`.
