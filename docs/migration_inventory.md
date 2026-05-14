# LazyVim Migration Inventory

Last updated: 2026-05-13

This document is the authoritative migration reference for moving behavior from `nvim.bak` into the current LazyVim-based config. Future AI-assisted migration work should update this file whenever a decision changes, a new customization is discovered, or a migration risk becomes clearer.

## Baseline

- Source of truth for old behavior: `nvim.bak/`
- Source of truth for current target: LazyVim starter in the workspace root
- Migration rule: prefer existing LazyVim defaults unless the old config captures a deliberate workflow advantage
- Migration rule: avoid porting plugin-specific bindings when the underlying plugin no longer exists in LazyVim but use a LazyVim equivalent workflow always
- Migration rule: any inventory item classified as `discard` is out of scope for migration and must be ignored entirely unless it is later explicitly reclassified
- Migration rule: `lua/plugins/key-hints.lua` is the current allowlist for leader binding groups; active top-level leader bindings outside those listed groups should be removed until the user explicitly re-adds them for a migrated workflow or changes this policy. Do not add which-key entries just to justify keeping an otherwise unlisted binding.

## Workflow Findings and Migration Specs

### Classification Legend

- `adapt to LazyVim`: preserve behavior and mapping as-is unless implementation details must change
- `adapt to LazyVim`: preserve intent, but reimplement with LazyVim defaults, APIs, or plugins
- `discard`: do not migrate unless a later workflow gap proves it is needed
- `already provided by LazyVim`: keep the LazyVim default and avoid redundant custom code

Items marked `discard` are intentionally excluded from implementation, acceptance tracking, and validation work until the classification changes.

### Editor Guardrail Keymaps

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Disable normal-mode `q` macro recording | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | This is a deliberate workflow guardrail and matches the repo convention to avoid accidental macro recording. | Plain `vim.keymap.set` override in `lua/config/keymaps.lua` | Removes macro recording unless another mapping is added intentionally. |
| Disable arrow keys in all intended non-terminal modes | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | This is a stable editing habit preference, not a plugin detail. The legacy mapping covered normal, insert, visual, select, operator-pending, and command-line modes, but not terminal mode. | Plain `vim.keymap.set` overrides in `lua/config/keymaps.lua` | Terminal-mode arrows should stay available so terminal applications keep their expected controls. |

### File, Buffer, and Quit Keymaps

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `<leader>w` save buffer | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | The old config used this as the primary write habit, and it is plugin-independent. | Plain `vim.keymap.set` override in `lua/config/keymaps.lua` with `nowait = true` so bare `<leader>w` writes immediately. | This intentionally takes precedence over LazyVim's `<leader>w` window prefix; use core `<C-w>` window commands or future accepted aliases for window actions. |
| Two-step quit prefix: `<leader>q`, `<leader>qq`, `<leader>qb` | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | The intent is safety against accidental quitting. LazyVim already has quit, session, and buffer-delete flows, but the old two-step quit mnemonic is custom. | Keep `<leader>q` prefix-only, replace `<leader>qq` with quit-all ownership in `lua/config/keymaps.lua`, and add `<leader>qb` through `Snacks.bufdelete()`. | `<leader>q` remains a live LazyVim session prefix, so session mappings such as `<leader>qs` stay available while the destructive quit action still requires a second key. |
| `<C-Right>` / `<C-Left>` buffer cycling | discard | `nvim.bak/lua/custom/keymaps.lua` | The current LazyVim target is not carrying forward custom buffer-cycling aliases. Keep the config aligned with defaults unless a concrete workflow gap shows up. | None | Drops the legacy Ctrl-based muscle memory until explicitly reintroduced. |

### Explorer, Diagnostics, Git, and Format Keymaps

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `<leader>e` file explorer toggle | already provided by LazyVim | `nvim.bak/lua/custom/keymaps.lua` | Explorer toggle is a standard LazyVim behavior. The old implementation is tied to `nvim-tree`, which is not part of the new baseline. | Direct `Snacks.explorer({ cwd = LazyVim.root() })` mapping in `lua/config/keymaps.lua` because the original LazyVim `<leader>e` remapped through the now-cleared `<leader>fe` file prefix. | Old `nvim-tree` API calls are not portable; the cwd variant remains available on `<leader>E`. |
| `<leader>xx` diagnostics/issues picker for current file | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | The old mapping used Telescope diagnostics. LazyVim already ships Trouble and Snacks-based diagnostics workflows; keep the intent and modify implementation from custom config to use Trouble. | Keep LazyVim's `<leader>xx` workspace diagnostics and accept `<leader>xX` as current-buffer Trouble diagnostics via `filter.buf=0`. | The muscle-memory key changes from `<leader>xx` to `<leader>xX` for file-local diagnostics, but the scope is explicit and avoids ambiguity. |
| `<leader>lg` open LazyGit | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | The behavior still matters, but LazyVim usually standardizes this under its own git prefix. Preserve the old mnemonic while using LazyVim's Snacks integration. | `Snacks.lazygit({ cwd = LazyVim.root.git() })` on `<leader>lg`, with `<leader>gg` and `<leader>gG` removed. | Requires `lazygit` on PATH; the mapping notifies and returns if the binary is missing. |
| `<leader>f` format buffer | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | In the old config this was a top-level formatting shortcut. In LazyVim, formatting usually lives under code actions and file prefixes are heavily used. | `LazyVim.format({ force = true })` on bare `<leader>f` in normal and visual modes. | The old LazyVim `<leader>f*` file/find namespace is intentionally cleared so bare `<leader>f` can be immediate with `nowait = true`; file search remains covered by the search/picker slice. |

### Search and Picker Keymaps

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Search suite under `<leader>s*`, `<leader>/`, and `<leader>sn` | mostly already provided by LazyVim | `nvim.bak/lua/custom/keymaps.lua` | The old search surface is conceptually aligned with LazyVim: help, keymaps, files, grep, diagnostics, recent files, current buffer, and config search. Most of this should stay on LazyVim defaults. | LazyVim picker mappings backed by the active Telescope extra, with migration aliases in `lua/plugins/picker.lua` | Telescope's `<leader>f*` file-prefix mappings conflict with the accepted bare `<leader>f` Format action, so they are disabled and old search habits are reachable under `<leader>s*`, `<leader>/`, `<leader><space>`, and `<leader>,`. |

### Escape Key Behavior

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Normal-mode `<Esc>` closes file tree if visible | discard | `nvim.bak/lua/custom/keymaps.lua` | The implementation suppresses normal Escape behavior when the tree is not open. LazyVim should keep `Esc` as a universal back-out key. | Rely on LazyVim default `Esc` behavior; close explorer via explorer-specific mappings | High risk of surprising normal-mode behavior and regressions. |
| Terminal-mode `<Esc>` closes floating terminal | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua`, `nvim.bak/lua/custom/terminal.lua` | This is part of the original fast-exit terminal workflow and is safe to preserve for floating terminals. | `snacks.nvim` terminal key override in a plugin opts merge | Replaces LazyVim's default terminal-mode double-escape behavior inside Snacks terminals. |

### Terminal Entry Points

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Single reusable floating shell terminal on `<leader>t` | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua`, `nvim.bak/lua/custom/keymaps.lua` | The workflow is intentional, but the old implementation reimplemented float lifecycle management that `snacks.nvim` already provides. | `snacks.terminal` with a dedicated shell identity and a custom keymap in `lua/plugins/terminal.lua` | The shell session keeps the cwd from the first launch until that terminal job exits, which matches the original single-session behavior closely. |
| Dedicated floating `copilot` CLI terminal on `<leader>cc` | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua`, `nvim.bak/lua/custom/keymaps.lua` | This is a specialized workflow worth preserving, and it can reuse the same `snacks.terminal` abstraction as the shell workflow. | Dedicated `snacks.terminal` instance keyed by command and terminal kind | Depends on the `copilot` CLI binary being available; the mapping should warn and do nothing when it is missing. |

### Terminal Lifecycle and Reuse

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Close other floating terminals when opening one | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua` | The behavior prevents stacked floating windows and reflects a real workflow preference. | Hide other active `snacks.terminal` windows before toggling the requested terminal | Hidden terminals remain reusable in the background, so this preserves reuse without stacked floats. |
| Reuse existing terminal buffer and running job | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua` | Reusing the same shell session is useful and avoids losing shell state. The intent survives through Snacks terminal identity and buffer reuse. | Persistent `snacks.terminal` instances keyed by terminal kind | Reuse depends on the terminal buffer remaining valid; after a clean process exit, the next toggle creates a fresh terminal. |
| Auto-close floating terminal on `BufLeave` | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua` | This is opinionated and can be hostile to multi-window or split-based workflows which LazyVim implements so remove all LazyVim split-based or multi-window behaviors by removing relevant plugins and mappings to disable this functionality. | None | If correctly removing multi-window functionality and mappings from LazyVim there should be no issues. |

### Terminal Window Presentation

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Terminal local options: disable number, relativenumber, signcolumn | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua` | These visual constraints are part of the old floating-terminal workflow and map cleanly onto Snacks window-local options. | `snacks.nvim` terminal window-local opts merge | Low risk; only affects Snacks terminal windows. |
| Floating terminal highlight group customization | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua`, `nvim.bak/lua/custom/configs/colorscheme.lua` | Visual consistency matters, and the highlight names and active float plugin differ in LazyVim so modify the custom setup to work within LazyVim floats and existing highlight groups. | Theme-specific float highlight overrides | Old groups reference custom terminal highlight names that do not exist yet. |

### Git Entry Points

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Open LazyGit from the editor | already provided by LazyVim | `nvim.bak/lua/custom/keymaps.lua`, `nvim.bak/lua/custom/plugins.lua` | LazyVim already ships the necessary stack for this workflow. Preserve the capability and keep the original key habit by remapping access to `<leader>lg` and disabling the default `<leader>gg` / `<leader>gG` variants. | `snacks.nvim` lazygit integration with a keymap override in `lua/config/keymaps.lua` | Only key choice differs materially. |

### Git Signs, Status, and Explorer State

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Gitsigns signs for add/change/changedelete | discard | `nvim.bak/lua/custom/configs/gitsigns.lua` | It will be easier and more robust to use the default LazyVim gitsigns setup LazyVim already provides. | `gitsigns.nvim` opts override in a plugin spec | Sign characters may need retesting with Nerd Font and terminal font rendering. |
| Enable `numhl`, `linehl`, and `current_line_blame` in gitsigns | discard | `nvim.bak/lua/custom/configs/gitsigns.lua` | These are deliberate visibility choices which I do not like or therefore care about. | `gitsigns.nvim` opts override | None. |
| Branch and diff information in the statusline | discard | `nvim.bak/lua/custom/configs/statusline.lua` | The concept is already part of LazyVim's `lualine` setup. Only the exact layout and glyphs are custom, DO NOT PORT ANYTHING. | `lualine.nvim` default sections | None since the user does not want to keep old look. |
| Show git state in the file explorer | adapt to LazyVim | `nvim.bak/lua/custom/configs/file-tree.lua`, `nvim.bak/lua/custom/configs/colorscheme.lua` | Explorer git indicators are useful, but the old code targets `nvim-tree` specifically. | LazyVim explorer git decorations | Old `NvimTree*` highlight groups will not apply to the new explorer so use LazyVim's highlight groups if possible, otherwise create new ones. |

### Git-Aware Search Behavior

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Hidden and ignored files searchable by default | discard | `nvim.bak/lua/custom/configs/telescope-config.lua` | Handled by LazyVim already, use their existing solution by not attempting to do anything with the old custom setup. | `snacks.nvim` picker or Telescope opts to include hidden/no-ignore results | None |

### LSP Navigation Keymaps

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `<leader>gd` definitions via picker | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | LazyVim already exposes definitions, but the old config chose a leader-based picker workflow instead of canonical `gd`. Create a new keybinding to port the `<leader>gd` binding but use the LazyVim LSP navigation mappings. (`gd` keybinding should not be deleted). | LazyVim LSP navigation mappings with Snacks/Telescope picker backend | Overriding standard `gd`-adjacent navigation can make docs and muscle memory diverge. |
| `<leader>gr` and `<leader>cr` references via picker | discard | `nvim.bak/lua/custom/lsp.lua` | References are already provided by LazyVim with additional mappings which are useful. | LazyVim references mappings plus optional aliases | None |
| `<leader>gi` implementations via picker | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Make new binding using LazyVim implementation picker and then delete the default `<leader>gI` mapping. | LazyVim implementation picker | Minimal risk beyond key duplication. |
| `<leader>gt` type definitions via picker | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Same rationale as definition goto-picker mapping. | LazyVim type definition mapping | Minimal risk beyond key duplication, remove default `<leader>gT` mapping and `<leader>gt` mapping before setting new binding. |

### LSP Actions and Diagnostic UI

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `<leader>ca` code action | already provided by LazyVim | `nvim.bak/lua/custom/lsp.lua` | Code actions are standard and already first-class in LazyVim. | LazyVim LSP code-action mapping | None beyond upstream keymap changes. |
| `<leader>cd` hover docs | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Hover is already available in LazyVim, but usually on `K`. Remove `K` binding and add the `<leader>cd` binding for code hover matching what `K` did within default LazyVim. | Default hover plus optional alias | None |
| Diagnostic float style with rounded borders and minimal header | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` and `nvim.bak/lua/custom/keymaps.lua` (for `<leader>xx` old usage) | The visual result matters. Recreate through supported opts and with the switch to use trouble for diagnostics in mind rather than overriding core preview helpers. | `vim.diagnostic.config`, Noice opts, LazyVim LSP opts, or Trouble opts | Monkey-patching `vim.lsp.util.open_floating_preview` is brittle across Neovim upgrades. |

### LSP-Related Filetype Behavior

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Wrap + linebreak + spell for `markdown`, `text`, `gitcommit` | discard | `nvim.bak/lua/custom/lsp.lua` | Do not port. | `lua/config/autocmds.lua` | None, not being ported. |

### Completion Engine and Menu Behavior

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `blink.cmp` as the completion engine | already provided by LazyVim | `nvim.bak/lua/custom/lsp.lua`, `lazy-lock.json` | The current LazyVim lockfile already includes `blink.cmp`, so migration should be an options merge, not a plugin re-add. | `blink.cmp` plugin opts in LazyVim | None. |
| Manual popup behavior with `auto_show = false` | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is a meaningful preference: completion stays manual while documentation still auto-shows once open. | `blink.cmp` completion menu opts | Changes completion feel significantly; should be validated with real editing. |

### Completion Key Behavior

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `<C-Space>` toggles completion menu | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Common and sensible, but should be expressed through LazyVim's blink opts rather than a full replacement config unless needed. | `blink.cmp` keymap opts | Must not clobber any LazyVim insert-mode conventions unintentionally, remove existing `<C-Space>` bindings to be safe before setting new binding. |
| `<CR>` accept completion then fallback | adapt to LazyVim or already provided by LazyVim | `nvim.bak/lua/custom/lsp.lua` | Accept-on-Enter is standard completion behavior but might not work as intended, prefer to migrate for consistency. | `blink.cmp` opts | Verify behavior with snippets and autopairs before assuming parity. |
| `<Tab>` order: Copilot suggestion, next item, snippet forward, fallback | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua`, `nvim.bak/lua/custom/configs/copilot-setup.lua` | This is one of the strongest custom workflows in the old config. Preserve the intent with Copilot integration. | `blink.cmp` custom key handler plus `copilot.lua` integration with LazyVim extra | Very sensitive to plugin load order and snippet engine behavior. |
| `<C-J>` next completion item | adapt to LazyVim | None | Not originally in config, need it though. | `blink.cmp` keymap opts | `<C-J>` is often an existing mapping, delete any existing mapping for insert mode before setting new binding and ensure only available while completion menu is visible. |
| `<Left>` / `<Right>` snippet jump | discard | `nvim.bak/lua/custom/lsp.lua` | This is a non-default snippet navigation choice not worth preserving. | `blink.cmp` snippet key handlers or LuaSnip mappings | None |

### Completion Popup Presentation

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Completion documentation auto-show with rounded border | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is a UI preference layered on top of completion. | `blink.cmp` documentation window opts | Must be checked against Noice and overall float styling. |
| Signature help popup enabled with rounded border | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Still useful, but should be migrated through blink/LSP opts rather than copied wholesale. | `blink.cmp` signature opts or LazyVim LSP opts | Needs retest alongside Noice hover/signature rendering. |
| Disable ghost text | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Explicit and intentional. | `blink.cmp` ghost text opts | Small visual change, low migration risk. |
| Fuzzy matcher `prefer_rust` with prebuilt binary download | already provided by LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is a performance and installation preference already captured. | `blink.cmp` fuzzy opts | Should be handled already but verify first by validating documention but not super important at this time so ignore if unsuccessful at finding details. |

### Copilot Completion Coordination

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Copilot suggestion auto-trigger and hide during completion | adapt to LazyVim | `nvim.bak/lua/custom/configs/copilot-setup.lua` | This is custom coordination logic between Copilot and `blink.cmp`, not a default LazyVim behavior. | `copilot.lua` plus `blink.cmp` event hooks | Event names and Copilot internals can change across plugin versions and LazyVim defaults, proceed with caution. |
| Disable Copilot on buffers whose names match `.env` or `.env.*` | adapt to LazyVim | `nvim.bak/lua/custom/configs/copilot-setup.lua` | This is a deliberate choice to avoid suggesting completions in environment files or exposing environment secrets to AI copilot. | `copilot.lua` `should_attach` wrapper in `lua/plugins/copilot.lua` | None |

### Theme and Highlight Behavior

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `onedarkpro` theme with a classic One Dark palette | adapt to LazyVim | `nvim.bak/lua/custom/configs/colorscheme.lua`, `nvim.bak/init.lua` | The color identity is clearly deliberate, but the migration should use a LazyVim plugin spec instead of porting raw setup calls blindly. | LazyVim colorscheme override with `onedarkpro.nvim` in `lua/plugins/colorscheme.lua` | Large highlight override set may become expensive to maintain so port with LazyVim compatibility in mind. |
| Extensive highlight overrides for floats, Mason, Telescope, tree, diff, and bufferline | adapt to LazyVim | `nvim.bak/lua/custom/configs/colorscheme.lua` | Some of these should survive, but many target plugins or highlight groups that are no longer part of the LazyVim baseline. | Theme-specific highlight overrides in `lua/plugins/colorscheme.lua` | Only active LazyVim-native groups such as `FloatingTerm*`, Mason, Telescope, and diff highlights should be kept; removed-plugin groups remain intentionally absent. |

### Statusline, Messages, and Core UI Options

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Custom `lualine` “Eviline” layout | discard | `nvim.bak/lua/custom/configs/statusline.lua` | The old statusline is highly customized and visually intentional, but `lualine` is already present in LazyVim with good customizations. Ignore existing custom config from backup entirely. | `lualine.nvim` opts override | High effort for cosmetic value; can hide more important migration work, avoid like the plague. |
| `noice.nvim` and other old custom prettification techniques | already provided by LazyVim | `nvim.bak/lua/custom/configs/noice.lua` | LazyVim already ships  with pretty notifications  and other completions so avoid modifications to this setup entirely. | `noice.nvim` opts override and `notify` setup | None |
| Hide `showmode` and rely on statusline | already provided by LazyVim | `nvim.bak/init.lua`, `nvim.bak/lua/custom/configs/statusline.lua` | This is standard once a statusline is active. | LazyVim default options | None. |
| Global line numbers | adapt to LazyVim | `nvim.bak/init.lua` | Do not use relative line numbers.. | LazyVim default options plus `lua/config/options.lua` overrides | Avoid preloading `config.options` from `lua/config/lazy.lua`, because that caches user options too early and lets LazyVim defaults restore `relativenumber`. |
| Clipboard handling | already provided by LazyVim | `nvim.bak/init.lua` | Ignore. | LazyVim default options plus optional `lua/config/options.lua` overrides | N/A |

### Autocommands and Filetype Defaults

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Various autocommands for filetypes, Svelte change detection, and editor behavior | discard | `nvim.bak/lua/custom/lsp.lua` and `nvim.bak/lua/custom/configs/file-tree.lua` | These are old autocommands that may not align with LazyVim's structure. | LazyVim `autocmds.lua` or plugin-specific hooks | Old autocommand groups and event choices may not align with LazyVim's existing structure. |
| Wrap and spell in prose-oriented buffers | discard | `nvim.bak/lua/custom/lsp.lua` | Ignore | Custom autocmds in LazyVim | None beyond scope drift? |

### Formatting Plugin Policy

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `conform.nvim` Prettier policy through LazyVim's formatting recipe | adapt to LazyVim | `nvim.bak/lua/custom/configs/conform.lua`, `nvim.bak/lua/custom/keymaps.lua` | LazyVim's documented recommendation for web projects is the `formatting.prettier` extra, not a hand-rolled `prettierd` fallback chain. This repo keeps that recipe, opts into `vim.g.lazyvim_prettier_needs_config = true`, and extends it locally for `svelte`. | LazyVim `formatting.prettier` extra plus a small `lua/plugins/formatting.lua` opts override | Requires the `prettier` binary and an explicit Prettier config for repo-local JS/TS formatting; projects without a Prettier config intentionally do not auto-format through this path. |
| Disable LSP formatting for formatter-managed servers while keeping ESLint as a secondary fixer | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | LazyVim's documented web-dev recipe separates responsibilities: Prettier owns formatting and ESLint owns lint fixes on save. That means formatter-managed servers should still lose formatting capability, but ESLint must stay format-capable so the `linting.eslint` extra can register it as a secondary formatter. | LazyVim `linting.eslint` extra plus local `nvim-lspconfig` `LspAttach` capability override in `lua/plugins/lsp.lua` | Needs care so ESLint remains registered for fixes while other formatter-managed servers still defer to Conform. |

### Mason and LSP Server Configuration

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Mason UI dimensions, border, and icons | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is low-risk visual customization that should be reintroduced but not dwelled on if complex. | `mason.nvim` opts override in `lua/plugins/mason.lua` | Mostly cosmetic. |
| Mason tool installer for `mypy` and `stylua` | discard | `nvim.bak/lua/custom/lsp.lua` | Lsp/tool management should be automatic in LazyVim so ignore further mason configurations. | `mason.nvim` / `mason-tool-installer.nvim` plugin opts | None |
| Server-specific LSP settings for `lua_ls`, `pyright`, `eslint`, `ts_ls`, `ruff`, `svelte`, etc. | discard | `nvim.bak/lua/custom/lsp.lua` | These are substantive behavior decisions resulting from project-specific needs and should be reconsidered in the context of LazyVim's defaults. | LazyVim `nvim-lspconfig` opts and language extras | Server names, defaults, and LazyVim extras can differ from the old setup. |
| `svelte` JS/TS change notification autocmd | discard | `nvim.bak/lua/custom/lsp.lua` | Ignore. | `LspAttach` hook in LazyVim LSP config | N/A |

### Explorer Plugin Migration

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `nvim-tree` config: show ignored files, custom git glyphs, default on-attach mappings | discard | `nvim.bak/lua/custom/configs/file-tree.lua` | The explorer still matters, but `nvim-tree` itself is not in the new baseline and alot is already handled for us. | LazyVim explorer opts via `snacks.nvim` | Ignore. |
| `nvim-tree` rename hook into `Snacks.rename.on_rename_file` | discard | `nvim.bak/lua/custom/configs/file-tree.lua` | This exists only to bridge two old plugins together. If LazyVim uses Snacks-native rename flows, the bridge should disappear. | None unless explorer rename breaks | Porting this blindly would duplicate or fight the new explorer integration. |

### Bufferline Plugin Migration

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `barbar.nvim` bufferline configuration | discard | `nvim.bak/lua/custom/configs/barbar.lua`, `nvim.bak/lua/custom/configs/colorscheme.lua` | The old config invested heavily in bufferline visuals, but `barbar` is not part of the current LazyVim baseline and is not essential for core migration. | Optional future bufferline plugin if a real gap appears | High visual maintenance cost for low migration priority. |

### Picker and Treesitter Plugin Migration

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `telescope.nvim` hidden-file and no-ignore defaults | adapt to LazyVim | `nvim.bak/lua/custom/configs/telescope-config.lua` | The behavior is useful, but the new picker backend may be Snacks rather than Telescope-first. | `snacks.nvim` picker opts or Telescope opts override | Needs careful tuning to avoid noisy search results. |
| Runtime `nvim-treesitter.parsers.ft_to_lang` compatibility shim | discard | `nvim.bak/lua/custom/configs/telescope-config.lua` | This is a defensive workaround for an older parser API mismatch and should not be carried forward without reproducing the bug. | None | High chance of preserving obsolete compatibility code. |
| Treesitter parser install list and auto-start-on-filetype logic | discard | `nvim.bak/lua/custom/configs/treesitter-config.lua` | Parser coverage matters; custom bootstrapping logic does not so there is no need to install parsers manually when this should be handled automatically. | `nvim-treesitter` opts override or LazyVim language extras | Old imperative install logic is unnecessary in LazyVim. |

### Key Hint and Mini.nvim Enhancements

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| `which-key.nvim` leader hints | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua`, LazyVim default `which-key.nvim` spec | User reversed the earlier mini.clue decision and now wants which-key as the sole hint system. Use LazyVim's default hint plugin with local group overrides for migrated key ownership. The key-hints file is also the allowlist for leader groups during migration. | `which-key.nvim` plugin spec in `lua/plugins/key-hints.lua`, with unlisted top-level leader defaults removed in `lua/config/keymaps.lua` | Do not keep mini.clue active. Do not add standalone which-key entries only to preserve a binding. Any future top-level leader binding outside the listed groups should stay removed until the user explicitly re-adds it for a migrated workflow or changes this policy. |
| `mini.clue` leader hints | discard | `nvim.bak/lua/custom/plugins.lua` | User explicitly no longer wants mini.clue for key hints. | None | Keep disabled so it cannot compete with which-key. |
| `mini.hipatterns` TODO / NOTE / WARN highlighting | adapt to LazyVim | `nvim.bak/lua/custom/plugins.lua` | This is a nice enhancement to match what I actually use in my todo-esque code comments. | `mini.hipatterns` plugin spec or equivalent highlight tool | Hex-color highlighting is migrated first in `lua/plugins/mini.lua`; comment-marker ownership still needs a final decision alongside the existing `todo-comments.nvim` defaults. |
| `mini.comment`, `mini.cursorword`, `mini.bufremove`, `mini.pairs` | discard | `nvim.bak/lua/custom/plugins.lua` | These are quality-of-life plugins which LazyVim handles for us in default options. | LazyVim defaults and optional mini.nvim specs | Risk of duplicating behavior with existing LazyVim plugins. |

### Snacks.nvim Baseline Behavior

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns |
| --- | --- | --- | --- | --- | --- |
| Snacks config for float style, picker, terminal, lazygit, rename, indent | (mostly) already provided by LazyVim | `nvim.bak/lua/custom/plugins.lua` | Snacks is already in the target stack, so only true deviations from LazyVim defaults should be ported such as Snacks which are not enabled by default with LazyVim. | `snacks.nvim` opts override | Upstream LazyVim may already set overlapping opts. |

## Deferred / Lower-Priority Findings

- Debugger workflows in `nvim.bak/lua/custom/debugger.lua` were intentionally not migrated yet or detailed in findings because they are were non-fully functional in the custom configuration so full reimplemntation or reliance on LazyVim's debugger integration is preferred.
