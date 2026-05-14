# LazyVim Architecture Reference

Last updated: 2026-05-13

This document is the local reference for how LazyVim is structured, what it provides by default, how the current workspace differs from upstream starter behavior, and where future migration work should be implemented. It is intended for AI agents working in this repository, not as a generic end-user tutorial.

## Scope and Sources

- Local sources inspected:
  - `init.lua`
  - `lazyvim.json`
  - `lua/config/*`
  - `lua/plugins/*`
  - `lazy-lock.json`
  - `nvim.bak/*`
- Upstream sources consulted:
  - LazyVim docs at `lazyvim.org`
  - LazyVim upstream source for `lua/lazyvim/config/options.lua`
  - LazyVim upstream source for `lua/lazyvim/config/keymaps.lua`
  - LazyVim upstream source for `lua/lazyvim/config/autocmds.lua`
  - LazyVim extras docs for representative extras such as Telescope, Neo-tree, Avante, TypeScript, and DAP core

## Current Workspace Baseline

This repository is close to the LazyVim starter shape, but it is not a pristine starter anymore.

- `lazyvim.json` currently enables `ai.copilot`, `coding.luasnip`, `editor.telescope`, `formatting.prettier`, `lang.json`, `lang.markdown`, `lang.toml`, `linting.eslint`, `util.dot`, and `vscode` extras.
- `lua/plugins/colorscheme.lua` adds `olimorris/onedarkpro.nvim` and overrides LazyVim's colorscheme choice.
- `lua/plugins/completion.lua` overrides `blink.cmp` for the migrated manual popup, completion keys, and Copilot-free completion source list.
- `lua/plugins/copilot.lua` re-owns the old `copilot.lua` suggestion workflow, including `.env` attachment filtering and Blink menu hide hooks.
- `lua/plugins/formatting.lua` keeps repo-local `conform.nvim` defaults and extends LazyVim's `formatting.prettier` extra so `svelte` also formats with Prettier.
- `lua/plugins/terminal.lua` overrides `snacks.nvim` terminal behavior and adds migration-specific terminal keymaps.
- `lua/plugins/mason.lua` restores the migrated Mason UI dimensions, border, and icon choices.
- `lua/plugins/mini.lua` adds `mini.hipatterns` for hex-color highlighting.
- `lua/plugins/picker.lua` overrides Telescope and Noice key ownership so search workflows stay under `<leader>s*` while bare `<leader>f` remains Format.
- `lua/plugins/lsp.lua` overrides `nvim-lspconfig` key ownership for migrated leader-based LSP navigation and diagnostic float styling while leaving ESLint formatting available for LazyVim's documented fix-on-save recipe.
- `lua/config/options.lua` sets `vim.g.lazyvim_prettier_needs_config = true`, so the Prettier extra only runs when a project-local Prettier config exists.
- `lua/plugins/key-hints.lua` disables `nvim-mini/mini.clue` and extends LazyVim's default `which-key.nvim` spec with migration-aware group labels.
- `lua/config/keymaps.lua` and `lua/config/options.lua` already contain migration overrides, so they should not be treated as upstream defaults.
- `lua/plugins/example.lua` has been removed from the active workspace.

Practical consequence: when deciding whether a behavior is "already provided by LazyVim," check the upstream LazyVim defaults first, then compare them to the current repo override layer.

## Startup Architecture

LazyVim is a Neovim distribution built on top of `lazy.nvim`. The user config stays small and composes the distro through import order rather than by copying setup code.

### Load order

1. `init.lua` sets `vim.g.ai_cmp = false` before LazyVim parses extras so Copilot uses suggestion mode instead of a Blink AI source.
2. `init.lua` loads `config.lazy`.
3. `lua/config/lazy.lua` bootstraps `lazy.nvim` if needed and calls `require("lazy").setup(...)`.
4. The setup spec imports `LazyVim/LazyVim` first through `import = "lazyvim.plugins"`.
5. User plugin overrides are imported afterward through `import = "plugins"`.
6. During LazyVim init, upstream `lazyvim.config.options` loads first and then user `lua/config/options.lua` loads after it, which is the point where final user option overrides should happen.
7. After `require("lazy").setup(...)`, `lua/config/lazy.lua` explicitly requires `config.autocmds` and `config.keymaps` so local migration behavior is active during normal startup.

### Why the order matters

- `lua/config/options.lua` is the correct place for core editor options because LazyVim loads it after upstream defaults during init.
- `lua/config/keymaps.lua` is the correct place for global editor keymaps because `config.lazy` loads it after plugin setup and it can remove or replace defaults.
- `lua/plugins/*.lua` is the correct place for plugin spec changes because those files participate in lazy.nvim's merge rules.
- Do not manually `require("config.options")` from `lua/config/lazy.lua`; doing so caches the module before LazyVim applies its own defaults and prevents later user overrides such as `relativenumber = false` from sticking.
- LazyVim expects the import order `lazyvim.plugins` first, extras second if used, user `plugins` last. Do not invert that order.

## Configuration Surfaces

LazyVim uses a strict separation of concerns. Future migration work should follow it.

### `lua/config/options.lua`

Use this for editor options and LazyVim global switches that must exist before plugins initialize.

Representative upstream defaults:

- `vim.g.mapleader = " "`
- `vim.g.maplocalleader = "\\"`
- `vim.g.autoformat = true`
- `vim.g.snacks_animate = true`
- `vim.g.lazyvim_picker = "auto"`
- `vim.g.lazyvim_cmp = "auto"`
- `vim.g.ai_cmp = true`
- `vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }`
- `opt.autowrite = true`
- `opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"`
- `opt.number = true`
- `opt.relativenumber = true`
- `opt.signcolumn = "yes"`
- `opt.cursorline = true`
- `opt.termguicolors = true`
- `opt.splitbelow = true`
- `opt.splitright = true`
- `opt.wrap = false`
- `opt.timeoutlen = vim.g.vscode and 1000 or 300`

Customization guidance:

- Set global LazyVim switches here when the upstream docs explicitly call for `vim.g.*` toggles.
- If an extra reads a global during spec resolution, set that global in `init.lua` before `require("config.lazy")` so the extra sees the intended value during startup.
- If LazyVim or an extra also reestablishes a runtime default for that same global during init, reassert the final runtime value here as well. `vim.g.ai_cmp = false` is one of those cases in this repo.
- Do not put plugin `setup()` calls here.
- When a plugin exposes an option through a documented global, prefer that over reimplementing its full plugin spec.

Current migration note: `lua/config/options.lua` sets `vim.g.lazyvim_prettier_needs_config = true` so the LazyVim `formatting.prettier` extra keeps the old "only format when the project opted into Prettier" behavior.

### `lua/config/keymaps.lua`

Use this for global keymaps that should always exist regardless of whether a specific plugin spec owns the mapping.

Representative upstream defaults:

- Better wrapped-line movement on `j`, `k`, `<Down>`, `<Up>`
- Window navigation on `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`
- Window resize on `<C-Up>`, `<C-Down>`, `<C-Left>`, `<C-Right>`
- Buffer navigation on `<S-h>`, `<S-l>`, `[b`, `]b`
- Save on `<C-s>` in normal, insert, visual, and select modes
- Formatting on `<leader>cf`
- Line diagnostics on `<leader>cd`
- Diagnostic jumps on `[d`, `]d`, `[e`, `]e`, `[w`, `]w`
- Lazy UI on `<leader>l`
- Quickfix and location list toggles on `<leader>xq` and `<leader>xl`
- Quit all on `<leader>qq`
- LazyGit on `<leader>gg` and `<leader>gG` when `lazygit` is installed
- Floating terminal workflows on `<leader>ft`, `<leader>fT`, and `<C-/>`
- Toggle family under `<leader>u*` backed by `snacks.nvim`

Current migration note: `lua/config/keymaps.lua` intentionally takes user ownership of bare `<leader>w` for immediate buffer writes with `nowait = true`. This preserves the old save habit and means LazyVim's window-prefix discoverability under `<leader>w` should not be relied on unless that workflow is explicitly remapped later.

Current migration note: `lua/config/keymaps.lua` clears LazyVim's global `<leader>f*` file/find namespace so bare `<leader>f` can run `LazyVim.format({ force = true })` immediately. Because the Telescope extra can add plugin-owned `<leader>f*` keys later, `lua/plugins/picker.lua` also disables those plugin keys and provides accepted search aliases under `<leader>s*`, `<leader>/`, `<leader><space>`, and `<leader>,`.

Current migration note: `lua/plugins/key-hints.lua` is the allowlist for top-level leader groups and accepted immediate bindings during migration. If a top-level leader binding is outside those listed groups and immediate bindings, remove it from the active config for now instead of adding a standalone which-key entry to keep it. `lua/config/keymaps.lua` currently prunes unlisted top-level defaults such as `<leader><space>`, `<leader>,`, `<leader>/`, `<leader>.`, `<leader>:`, `<leader>?`, `<leader>S`, `<leader>b*`, and `<leader>n`, while keeping accepted immediate bindings on `<leader>e`, `<leader>E`, `<leader>f`, and `<leader>w`.

Customization guidance:

- Use `vim.keymap.del` to remove a LazyVim global default before redefining it.
- Keep general editor behavior here even if the action eventually calls a plugin helper.
- Do not use `LazyVim.safe_keymap_set` in user config; upstream explicitly warns against that. Use `vim.keymap.set`.

### `lua/config/autocmds.lua`

Use this for editor-wide autocommands and for removing LazyVim default augroups when necessary.

Representative upstream default augroups:

- `lazyvim_checktime`: reload changed files on `FocusGained`, `TermClose`, and `TermLeave`
- `lazyvim_highlight_yank`: highlight yanked text
- `lazyvim_resize_splits`: rebalance windows after `VimResized`
- `lazyvim_last_loc`: restore cursor to last known location on reopen
- `lazyvim_close_with_q`: make special utility buffers closable with `q`
- `lazyvim_man_unlisted`: keep `man` buffers out of the buffer list
- `lazyvim_wrap_spell`: enable local wrap and spell in text-oriented filetypes
- `lazyvim_json_conceal`: force `conceallevel = 0` for JSON-like buffers
- `lazyvim_auto_create_dir`: create missing parent directories on save

Customization guidance:

- Remove a default augroup by name if the default conflicts with a migration requirement.
- Add repo-specific autocmds here only when the behavior is not really a plugin option.
- Avoid reviving old `nvim.bak` autocmds without checking whether LazyVim already covers the workflow.

### `lua/plugins/*.lua`

Use this for all plugin additions, overrides, opt merges, optional dependencies, and plugin-specific keymaps.

This is the most important migration rule in the repo:

- general editor behavior goes in `lua/config`
- plugin ownership goes in `lua/plugins`

## Plugin Management Model

LazyVim's own docs direct plugin customizations to `lua/plugins/*.lua` and expect specs to merge with LazyVim's defaults. You rarely replace a full plugin spec. You usually merge into one.

### Merge behavior that matters in this repo

When you add a plugin spec for a plugin already owned by LazyVim:

- `opts` is merged with the parent spec
- `keys` is extended unless you replace it with a function that returns a whole new set
- `dependencies` is extended
- `cmd`, `event`, and `ft` are extended
- most other scalar properties override the prior value

Guidance from the LazyVim plugin docs:

- Prefer an `opts` table for simple option changes, because it merges with LazyVim's default options.
- Use `opts = function(_, opts) ... end` when you need to mutate an existing list or derive values from existing defaults.
- Prefer `keys = { ... }` for plugin-owned keymaps; disable a plugin key with `{ lhs, false }` and include the exact same mode when the original key is not normal-mode only.
- For LSP keymaps, use the `nvim-lspconfig` server config key list, normally `opts.servers["*"].keys`, because LazyVim documents LSP maps as server configuration rather than ordinary global maps.
- If a plugin declares `opts_extend` for a list-like option such as `which-key.nvim`'s `spec`, append local entries instead of assigning the whole list. Use which-key's `hidden` or a later replacement entry for stale groups instead of replacing LazyVim's whole spec.

### Standard customization patterns

Add a plugin:

```lua
return {
  { "someone/new-plugin.nvim" },
}
```

Disable a plugin:

```lua
return {
  { "folke/trouble.nvim", enabled = false },
}
```

Merge plugin options:

```lua
return {
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = { position = "float" },
      },
    },
  },
}
```

Disable or replace plugin keymaps:

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>/", false },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    },
  },
}
```

LSP keymaps belong in the LSP server spec layer:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "K", vim.lsp.buf.hover, desc = "Hover" },
            { "gd", false },
          },
        },
      },
    },
  },
}
```

## Default Plugin Stack in This Workspace

The current `lazy-lock.json` shows the plugin set actually installed in this repository. Since `lazyvim.json` has no extras enabled, this list is a practical baseline for the current migration target plus a small number of local additions.

### Locked plugins and their roles

| Plugin | Role | Notes for migration work |
| --- | --- | --- |
| `LazyVim` | Distro layer | Owns defaults, plugin imports, helpers, and conventions. |
| `lazy.nvim` | Plugin manager | Owns spec loading, lazy loading, lockfile, and merge behavior. |
| `blink.cmp` | Completion engine | Current default completion backend in LazyVim. |
| `bufferline.nvim` | Buffer/tab UI | Present in the lockfile; treat as part of the active UI stack. |
| `catppuccin` | Optional theme integration | Present for integrations and theme compatibility, even if unused. |
| `conform.nvim` | Formatting | Owns formatting policy and format execution. |
| `flash.nvim` | Motion/navigation | LazyVim default enhanced jump/navigation layer. |
| `friendly-snippets` | Snippet collection | Feeds snippet-capable completion and snippet systems. |
| `gitsigns.nvim` | Git signs and blame features | Default git gutter integration. |
| `grug-far.nvim` | Search/replace UI | Search and refactor support. |
| `lazydev.nvim` | Lua development support | Improves LuaLS behavior for Neovim config development. |
| `lualine.nvim` | Statusline | Default statusline layer. |
| `mason-lspconfig.nvim` | Mason/LSP bridge | Ensures Mason-installed servers connect to lspconfig. |
| `mason.nvim` | Tool and LSP installer | Handles installable external tools and servers. |
| `mini.ai` | Textobject enhancements | Default editing utility. |
| `mini.icons` | Icons | Filetype and UI icon source. |
| `mini.pairs` | Auto-pairs | Default pairs behavior. |
| `noice.nvim` | Command-line and message UI | Part of LazyVim's UI stack. |
| `nui.nvim` | UI dependency | Required by several UI plugins. |
| `nvim-lint` | Lint orchestration | Parallel to `conform.nvim` for linting. |
| `nvim-lspconfig` | LSP client setup | Main LSP integration point. |
| `nvim-treesitter` | Parsing and syntax | Syntax tree foundation for highlighting and textobjects. |
| `nvim-treesitter-textobjects` | Treesitter textobjects | Extends motions and objects. |
| `nvim-ts-autotag` | HTML/JSX tag management | Auto close/rename tag helper. |
| `onedarkpro.nvim` | Theme plugin | Local repo addition, not an upstream LazyVim default. |
| `persistence.nvim` | Session persistence | LazyVim session management support. |
| `plenary.nvim` | Utility dependency | Common dependency for multiple plugins. |
| `snacks.nvim` | Core utility/UI layer | Explorer, picker, terminal, git, dashboard, toggles, and more. |
| `todo-comments.nvim` | Structured comment markers | Highlights TODO/FIX/WARN-style annotations. |
| `tokyonight.nvim` | Upstream default theme | Default LazyVim colorscheme unless overridden. |
| `trouble.nvim` | Diagnostics/issues UI | Core diagnostics and list interface. |
| `ts-comments.nvim` | Treesitter-aware comments | Language-aware comment strings. |
| `which-key.nvim` | Key-hint UI | Active key discovery layer with local migration-aware group labels. |

### Default plugin ownership by responsibility

Use this to choose the correct implementation surface before editing:

- Editor core and defaults: `LazyVim`
- Plugin loading and merges: `lazy.nvim`
- Picker, explorer, terminal, dashboard, toggles, lazygit: `snacks.nvim`
- Formatting: `conform.nvim`
- Linting: `nvim-lint`
- Diagnostics lists: `trouble.nvim`
- Completion: `blink.cmp`
- LSP client orchestration: `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim`
- Syntax and textobjects: `nvim-treesitter`, `nvim-treesitter-textobjects`
- Git gutter and blame: `gitsigns.nvim`
- UI messaging: `noice.nvim`
- Statusline: `lualine.nvim`
- Key discovery: `which-key.nvim` in this repo; `mini.clue` is disabled locally by current preference.

## Extras System

Extras are optional feature packs shipped by LazyVim. They are the preferred way to add bigger language, UI, AI, testing, or debugging slices without hand-assembling plugin graphs.

### How extras are enabled

- Interactive: `:LazyExtras`
- Declarative: add the extra import in a plugin file
- Metadata: `lazyvim.json` records enabled extras for the local config

In this repository, `lazyvim.json` currently enables several extras, so migration work should check the active extras list before assuming the default baseline.

### Extras taxonomy

Upstream extras are organized roughly as:

- `ai/*`
- `coding/*`
- `dap/*`
- `editor/*`
- `formatting/*`
- `lang/*`
- `lsp/*`
- `test/*`
- `ui/*`
- `util/*`
- `vscode`

### Representative extras and what they change

#### `editor.telescope`

- Switches the picker backend toward Telescope.
- Exposes `vim.g.lazyvim_picker = "telescope"` as the documented option switch.
- Adds Telescope-specific key behavior and picker defaults.
- Also adjusts LSP navigation mappings to Telescope-backed implementations.

Use when the workflow specifically depends on Telescope behavior that Snacks picker does not match well enough.

#### `editor.neo-tree`

- Adds `nvim-neo-tree/neo-tree.nvim` as the file explorer.
- Configures filesystem, buffers, and git-status sources.
- Adds explorer-specific mappings and component defaults.

Use when the workflow needs Neo-tree specifically. Do not assume it is present in the default baseline.

#### `lang.typescript`

- Configures TypeScript LSP ownership and related tooling.
- Uses `vim.g.lazyvim_ts_lsp` to choose between `vtsls` and `tsgo`.
- Extends Mason and icon configuration.
- Optionally integrates DAP for JavaScript and TypeScript.

Use when the migration slice is language-specific and upstream already has an extra instead of reviving old hand-written setup.

#### `dap.core`

- Adds the base DAP stack: `nvim-dap`, `nvim-dap-ui`, virtual text, `nvim-nio`, and Mason integration.
- Leaves language-specific debuggers to other extras.

Use when the old workflow needs debugging and the repo has decided that debugging is back in scope.

#### `ai.avante`

- Adds `avante.nvim` with provider defaults and optional integrations.
- Can wire into `blink.cmp` through an optional source.
- Demonstrates how AI extras often compose several plugins rather than a single plugin.

Use as a model for how larger extras are composed and how optional dependencies are gated.

## Keymaps and Autocommands: Customization Rules

### Global keymaps

If a mapping is part of the user's general editing workflow, place it in `lua/config/keymaps.lua`.

Good examples:

- disabling a default map
- defining a save alias
- setting a quit prefix
- global diagnostics shortcuts

### Plugin keymaps

If a mapping only makes sense when a plugin is active, prefer the plugin spec `keys` field in `lua/plugins/*.lua`.

Good examples:

- Telescope picker keymaps
- Neo-tree-specific bindings
- DAP actions
- plugin-owned terminal or AI actions

### LSP keymaps

Do not scatter LSP maps across ad hoc modules. Use the `nvim-lspconfig` spec and attach keys in `servers["*"]` or a server-specific entry.

Current migration note: `lua/plugins/lsp.lua` uses LazyVim's documented `opts.servers["*"].keys` surface to disable LSP defaults such as `K` and `<leader>cc` and add migrated `<leader>gd`, `<leader>gi`, `<leader>gt`, and `<leader>cd` mappings. Neovim core also creates a buffer-local `K` hover mapping on LSP attach, so the same plugin spec deletes that buffer-local key in an `LspAttach` autocmd.

### Removing defaults safely

- Global map: `vim.keymap.del("n", lhs)` in `lua/config/keymaps.lua`
- Plugin map: `{ lhs, false }` in a plugin spec `keys` list with the correct mode
- Default autocmd: `vim.api.nvim_del_augroup_by_name("lazyvim_<name>")`

## Best Practices for Future Migration Work

### Prefer LazyVim-native extension points

Do not port old setup modules wholesale from `nvim.bak`. First ask:

1. Does LazyVim already provide the workflow?
2. If yes, is an alias enough?
3. If not, is there an upstream extra for it?
4. Only if both answers are no should a custom plugin override be added.

### Keep file placement strict

- `lua/config/options.lua`: options and `vim.g.*` switches
- `lua/config/keymaps.lua`: global editor keymaps
- `lua/config/autocmds.lua`: global autocmds
- `lua/plugins/*.lua`: plugin-specific behavior, opts merges, dependencies, extras

### Prefer merges over replacement

If upstream already configures a plugin, extend it with `opts = function(_, opts) ... end` unless a full override is genuinely necessary.

### Treat extras as the first language-integration option

For languages, DAP, AI, and alternate explorers or pickers, search the extras first. That is usually safer than reviving custom legacy wiring.

### Validate against the active backend

Many old `nvim.bak` workflows were built around Telescope, `nvim-tree`, or bespoke terminal helpers. The current LazyVim baseline in this repo uses Snacks heavily. Validate the actual owner before writing code.

### Distinguish upstream defaults from local overrides

This repository already overrides:

- colorscheme selection
- terminal behavior
- some keymaps
- some options

When auditing a missing workflow, do not assume the current repo behavior is LazyVim default behavior.

## Migration Implications for This Repository

Use this document as the architectural source of truth during migration sessions.

- If the workflow is editor-global, start in `lua/config`.
- If the workflow belongs to Snacks, LSP, Conform, Trouble, or another plugin, start in `lua/plugins`.
- If the old behavior relied on a removed plugin such as `nvim-tree`, look for a LazyVim-native equivalent first.
- If a workflow is language-specific, check the upstream extras before creating repo-local plugin specs.
- If a behavior appears missing, verify whether the current repo already overrode the upstream default.

## Short Decision Checklist

Before editing, answer these questions in order:

1. Is the desired behavior already in upstream LazyVim defaults?
2. Is the behavior already changed locally in this repo?
3. Is the correct owner global config or a plugin spec?
4. Is there an existing extra that should own the feature?
5. What is the cheapest validation that proves the chosen owner is correct?

If those five answers are clear, the migration slice is usually scoped correctly.
