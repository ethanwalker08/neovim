# Neovim Configuration — Copilot Instructions

## Architecture

This is a personal Neovim configuration using **`vim.pack`** (Neovim's built-in package manager, not lazy.nvim) to manage plugins.

### Entry point & load order

`init.lua` bootstraps everything in this order:
1. `require("custom.plugins").setup()` — installs/configures all plugins via `vim.pack.add()`
2. `require("custom.keymaps").setup()` — registers global keymaps
3. `require("custom.terminal").setup()` — floating terminal
4. `require("custom.lsp").setup()` — Mason, LSP configs, and blink.cmp

### Module layout

All config lives under `lua/custom/`:
- `plugins.lua` — single source of plugin declarations + inline setup for simpler plugins (mini.nvim modules, snacks.nvim, conform.nvim)
- `keymaps.lua` — **all global keymaps** are declared in one `KEYMAPS` table; `M.apply_maps()` applies them. Buffer-local LSP keymaps live in `lsp.lua`
- `lsp.lua` — Mason auto-enable, per-LSP `vim.lsp.config()` calls, blink.cmp setup, diagnostic config
- `terminal.lua` — custom floating terminal toggled with `<leader>t` (state managed in a module-local table)
- `configs/` — one file per complex plugin: `copilot-setup.lua`, `file-tree.lua`, `statusline.lua`, `telescope-config.lua`, `treesitter-config.lua`

## Key conventions

### Adding/removing plugins

Add a plugin by appending its URL string (or table with `src`/`branch`/`build`/`version` keys) to the `vim.pack.add({...})` call in `plugins.lua`. Remove a plugin by deleting its entry.

For plugins that need more than a few lines of config, create a dedicated file in `lua/custom/configs/` and `require()` it from `plugins.lua`.

### Keymaps

All global keymaps go in the `KEYMAPS` table in `keymaps.lua` with fields:
```lua
{ type = "map", scope = "global", mode = "n", lhs = "<leader>x", rhs = ..., desc = "..." }
```
Buffer-local keymaps (e.g. LSP) are set directly with `vim.keymap.set` inside `lsp_on_attach` in `lsp.lua`.

Arrow keys are disabled in all modes. Macro recording (`q`) is disabled — map `<leader>q` for quit-like actions instead.

### Module pattern

Every module uses the same shape:
```lua
local M = {}
function M.setup() ... end
return M
```

### LSP configuration

LSPs are registered with `vim.lsp.config("server_name", { settings = ... })` and auto-enabled via `mason-lspconfig`. Adding a new LSP: install it with Mason, then add a `vim.lsp.config("name", {})` call in `lsp.lua`.

### Formatting

`conform.nvim` handles formatting (`<leader>f`). Formatters are configured by filetype in `plugins.lua` inside the `require("conform").setup()` call.

### Linting (luacheck)

`luacheck` is configured in `.luacheckrc`. The `vim` global is whitelisted. Run it with:
```
luacheck lua/
```
The `augroup` global (used in `lsp.lua` and `terminal.lua`) is declared in `.luarc.json` for the Lua LS but **not** in `.luacheckrc` — add it there if luacheck reports it as undefined.

### Globals

`vim` and `Snacks` are treated as implicit globals throughout. `augroup` is used in `lsp.lua` and `terminal.lua` without being explicitly created in those files — it is expected to be set up at the call site or globally before those modules load.
