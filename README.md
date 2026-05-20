# Personal LazyVim Neovim Config

This repository is my active Neovim setup, built on top of [LazyVim](https://github.com/LazyVim/LazyVim) and `lazy.nvim`.

## What This Repo Contains

- A LazyVim-based Neovim config with local overrides for theme, completion, Copilot, formatting, keymaps, terminal workflows, LSP navigation, and key hints.
- `leader` set to `<Space>`.
- `which-key.nvim` as the active key-hint system.
- LazyVim's `vscode` extra already enabled, allowing usage of this config from within VSCode using the [vscode-neovim extension](https://github.com/vscode-neovim/vscode-neovim)

## Quick Start

Clone or link this repository to `~/.config/nvim`(Unix/WSL/Mac/Linux), or `%userprofile%\AppData\Local\nvim`(Windows) then start Neovim:

```
git clone <repo> [replace/with/config/location] # Be sure to replace path with the appropriate config location
nvim
```

On first launch, `lazy.nvim` bootstraps itself automatically and installs plugins from the pinned lockfile.

Useful built-in management commands:

- `:Lazy` for plugin state, updates, and profiling
- `:Mason` for external tool management
- `:checkhealth` for environment diagnostics

## Optional External Tools

Some workflows depend on external CLIs/Tooling:

- `lazygit` for `<leader>lg`
- `copilot` CLI for `<leader>cc`
- a Nerd Font for icons and UI glyphs

## Repository Layout

- `init.lua`: early globals that must exist before LazyVim resolves extras
- `lazyvim.json`: enabled LazyVim extras
- `lua/config/`: global options, keymaps, and autocmds
- `lua/plugins/`: plugin additions and plugin-specific overrides
- `docs/`: migration architecture, inventory, acceptance criteria, and session log

## Current Workflow Highlights

### Key Hints

Press `<Space>` in normal mode to open which-key hints for the active leader groups.

### File and Session Basics

- `<leader>w`: write the current buffer
- `<leader>qq`: quit Neovim
- `<leader>qb`: delete the current buffer
- `<leader>e`: toggle the explorer
- `<leader>f`: format the current buffer

### Search and Picker Workflows

- `<leader>sf`: search files
- `<leader>sg`: live grep
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
- Blink completion uses a manual popup: `<C-Space>` toggles the menu

## Customizing This Config

This repo no longer uses the backup layout from `nvim.bak/` such as `vim.pack` or `lua/custom/*`.

- Put general editor behavior in `lua/config/options.lua`, `lua/config/keymaps.lua`, and `lua/config/autocmds.lua`.
- Put plugin ownership and plugin overrides in `lua/plugins/*.lua`.
- Enable or disable LazyVim extras in `lazyvim.json`.

## Formatting, Copilot, and Theme Notes

- Prettier follows LazyVim's extra plus a repo-local config gate, so JS and TS formatting only takes the Prettier path when the project opts into Prettier.
- `copilot.lua` suggestions are enabled, but `.env` and `.env.*` buffers are intentionally blocked from being read by copilot.
- The active colorscheme is a One Dark variant implemented through `onedarkpro.nvim`.

## License

MIT. See `LICENSE`.
