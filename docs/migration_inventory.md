# LazyVim Migration Inventory

Last updated: 2026-05-13

This document is the authoritative migration reference for moving behavior from `nvim.bak` into the current LazyVim-based config. Future AI-assisted migration work should update this file whenever a decision changes, a new customization is discovered, or a migration risk becomes clearer.

## Baseline

- Source of truth for old behavior: `nvim.bak/`
- Source of truth for current target: LazyVim starter in the workspace root
- Current target stack confirmed in `lazy-lock.json`: `LazyVim`, `blink.cmp`, `conform.nvim`, `gitsigns.nvim`, `lualine.nvim`, `mason.nvim`, `noice.nvim`, `nvim-lspconfig`, `snacks.nvim`, `trouble.nvim`, `which-key.nvim`
- Migration rule: prefer existing LazyVim defaults unless the old config captures a deliberate workflow advantage
- Migration rule: avoid porting plugin-specific code when the underlying plugin no longer exists in LazyVim

## Classification Legend

- `keep exactly`: preserve behavior and mapping as-is unless implementation details must change
- `adapt to LazyVim`: preserve intent, but reimplement with LazyVim defaults, APIs, or plugins
- `discard`: do not migrate unless a later workflow gap proves it is needed
- `already provided by LazyVim`: keep the LazyVim default and avoid redundant custom code

## Global Keymaps

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns | Revisit later |
| --- | --- | --- | --- | --- | --- | --- |
| Disable normal-mode `q` macro recording | keep exactly | `nvim.bak/lua/custom/keymaps.lua` | This is a deliberate workflow guardrail and matches the repo convention to avoid accidental macro recording. | Plain `vim.keymap.set` override in `lua/config/keymaps.lua` | Removes macro recording unless another mapping is added intentionally. | no |
| Disable arrow keys in all intended non-terminal modes | keep exactly | `nvim.bak/lua/custom/keymaps.lua` | This is a stable editing habit preference, not a plugin detail. The legacy mapping covered normal, insert, visual, select, operator-pending, and command-line modes, but not terminal mode. | Plain `vim.keymap.set` overrides in `lua/config/keymaps.lua` | Terminal-mode arrows should stay available so terminal applications keep their expected controls. | no |
| `<leader>w` save buffer | already provided by LazyVim | `nvim.bak/lua/custom/keymaps.lua` | LazyVim already treats save as a first-class default workflow; re-adding it would be redundant unless the exact description matters. | LazyVim default save mapping | Default keymap details may shift upstream, but behavior is standard. | no |
| Two-step quit prefix: `<leader>q`, `<leader>qq`, `<leader>qb` | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | The intent is safety against accidental quitting. LazyVim already has quit and buffer-delete flows, but the old two-step mnemonic is custom. | LazyVim quit mappings plus optional custom `<leader>qq` / `<leader>qb` aliases | `<leader>q` is often a live prefix in LazyVim. Overriding it too early can hide useful defaults. | yes |
| `<C-Right>` / `<C-Left>` buffer cycling | keep exactly | `nvim.bak/lua/custom/keymaps.lua` | These map to generic `:bn` and `:bp` commands and are independent of the old bufferline plugin. | Plain mappings in `lua/config/keymaps.lua` | Terminal and OS shortcuts may intercept these keys. | yes |
| `<D-Right>` / `<D-Left>` buffer cycling | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | This is a platform-specific convenience mapping. The current environment is Linux, so it should not be migrated blindly. | Optional platform-gated mappings in `lua/config/keymaps.lua` | Command-key handling differs across GUI clients and terminal emulators. | yes |
| `<leader>e` file explorer toggle | already provided by LazyVim | `nvim.bak/lua/custom/keymaps.lua` | Explorer toggle is a standard LazyVim behavior. The old implementation is tied to `nvim-tree`, which is not part of the new baseline. | LazyVim explorer toggle via `snacks.nvim` | Old `nvim-tree` API calls are not portable. | no |
| `<leader>xx` diagnostics/issues picker for current file | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | The old mapping used Telescope diagnostics. LazyVim already ships Trouble and Snacks-based diagnostics workflows; keep the intent, not the implementation. | `trouble.nvim` diagnostics views or LazyVim default diagnostics mappings | Existing `<leader>xx` in LazyVim may target workspace diagnostics, not file-local diagnostics. | yes |
| `<leader>lg` open LazyGit | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | The behavior still matters, but LazyVim usually standardizes this under its own git prefix. Preserve the workflow while aligning with LazyVim conventions. | `snacks.nvim` lazygit integration, usually under the git group | Reusing the old `lg` key may conflict with which-key organization. | yes |
| `<leader>f` format buffer | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua` | In the old config this was a top-level formatting shortcut. In LazyVim, formatting usually lives under code actions and file prefixes are heavily used. | `conform.nvim` through LazyVim default format mapping | Reusing `<leader>f` may collide with LazyVim file-finder workflows. | yes |
| Search suite under `<leader>s*`, `<leader>/`, and `<leader>sn` | mostly already provided by LazyVim | `nvim.bak/lua/custom/keymaps.lua` | The old search surface is conceptually aligned with LazyVim: help, keymaps, files, grep, diagnostics, recent files, current buffer, and config search. Most of this should stay on LazyVim defaults. | LazyVim picker mappings backed by `snacks.nvim` and optional Telescope | The exact picker backend and hidden-file behavior differ from the old setup. | yes |
| Normal-mode `<Esc>` closes file tree if visible | discard | `nvim.bak/lua/custom/keymaps.lua` | The implementation suppresses normal Escape behavior when the tree is not open. LazyVim should keep `Esc` as a universal back-out key. | Rely on LazyVim default `Esc` behavior; close explorer via explorer-specific mappings | High risk of surprising normal-mode behavior and regressions. | no |
| Terminal-mode `<Esc>` closes floating terminal | adapt to LazyVim | `nvim.bak/lua/custom/keymaps.lua`, `nvim.bak/lua/custom/terminal.lua` | The intent is good, but it is tightly coupled to the custom floating terminal state machine. | `snacks.nvim` terminal mapping or a named terminal wrapper | Raw terminal mode often expects `Esc` to stay available for terminal programs. | yes |

## Terminal Workflows

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns | Revisit later |
| --- | --- | --- | --- | --- | --- | --- |
| Single reusable floating shell terminal on `<leader>t` | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua`, `nvim.bak/lua/custom/keymaps.lua` | The workflow is intentional, but the old implementation reimplements float lifecycle management that `snacks.nvim` can already provide. | `snacks.terminal` with a named shell terminal and a custom keymap | Need to confirm whether LazyVim already exposes a preferred terminal toggle that should be reused. | yes |
| Dedicated floating `copilot` CLI terminal on `<leader>cc` | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua`, `nvim.bak/lua/custom/keymaps.lua` | This is a specialized workflow worth preserving if the Copilot CLI is still part of daily use. | Named `snacks.terminal` instance or custom terminal command wrapper | Requires `copilot` CLI availability on the machine; missing binary should fail gracefully. | yes |
| Close other floating terminals when opening one | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua` | The behavior prevents stacked floating windows and likely reflects a real workflow preference. | Enforce one active named terminal at a time with `snacks.nvim` helpers | May be awkward if LazyVim users expect multiple concurrent terminals. | yes |
| Reuse existing terminal buffer and running job | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua` | Reusing the same shell session is useful and avoids losing shell state. The intent should survive even if the implementation changes. | Persistent named terminal support in `snacks.nvim` | Session persistence behavior may differ across terminal backends. | yes |
| Auto-close floating terminal on `BufLeave` | discard | `nvim.bak/lua/custom/terminal.lua` | This is opinionated and can be hostile to multi-window or split-based workflows. LazyVim should not inherit it without strong evidence. | None; rely on explicit terminal close/toggle | High chance of accidental terminal dismissal during navigation. | no |
| Terminal local options: disable number, relativenumber, signcolumn | already provided by LazyVim | `nvim.bak/lua/custom/terminal.lua` | Terminal buffers normally receive sensible defaults already. This should only be reintroduced if the target terminal backend does not cover it. | LazyVim terminal defaults | Backend-specific differences may exist, but the behavior is standard. | no |
| Floating terminal highlight group customization | adapt to LazyVim | `nvim.bak/lua/custom/terminal.lua`, `nvim.bak/lua/custom/configs/colorscheme.lua` | Visual consistency matters, but the highlight names and active float plugin differ in LazyVim. | Theme-specific float highlight overrides | Old groups reference custom terminal highlight names that do not exist yet. | yes |

## Git Workflows

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns | Revisit later |
| --- | --- | --- | --- | --- | --- | --- |
| Open LazyGit from the editor | already provided by LazyVim | `nvim.bak/lua/custom/keymaps.lua`, `nvim.bak/lua/custom/plugins.lua` | LazyVim already ships the necessary stack for this workflow. Preserve the capability, but avoid old custom wrappers unless the key choice matters. | `snacks.nvim` lazygit integration | Only key choice differs materially. | no |
| Gitsigns signs for add/change/changedelete | adapt to LazyVim | `nvim.bak/lua/custom/configs/gitsigns.lua` | The default plugin is still present, but the old text signs are a visual preference rather than a structural requirement. | `gitsigns.nvim` opts override in a plugin spec | Sign characters may need retesting with Nerd Font and terminal font rendering. | yes |
| Enable `numhl`, `linehl`, and `current_line_blame` in gitsigns | adapt to LazyVim | `nvim.bak/lua/custom/configs/gitsigns.lua` | These are deliberate visibility choices and are not guaranteed to match LazyVim defaults. | `gitsigns.nvim` opts override | `linehl` can be visually heavy, especially with LazyVim colorschemes. | yes |
| Branch and diff information in the statusline | already provided by LazyVim | `nvim.bak/lua/custom/configs/statusline.lua` | The concept is already part of LazyVim's `lualine` setup. Only the exact layout and glyphs are custom. | `lualine.nvim` default sections | None unless the user wants the old exact aesthetic. | no |
| Show git state in the file explorer | adapt to LazyVim | `nvim.bak/lua/custom/configs/file-tree.lua`, `nvim.bak/lua/custom/configs/colorscheme.lua` | Explorer git indicators are useful, but the old code targets `nvim-tree` specifically. | LazyVim explorer git decorations | Old `NvimTree*` highlight groups will not apply to the new explorer. | yes |
| Hidden and ignored files searchable by default | adapt to LazyVim | `nvim.bak/lua/custom/configs/telescope-config.lua` | This materially changes search behavior and is likely intentional for dotfiles work. It should be ported deliberately if still desired. | `snacks.nvim` picker or Telescope opts to include hidden/no-ignore results | Searching ignored files can produce noisy or slow results in larger repos. | yes |

## LSP Mappings

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns | Revisit later |
| --- | --- | --- | --- | --- | --- | --- |
| `<leader>gd` definitions via picker | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | LazyVim already exposes definitions, but the old config chose a leader-based picker workflow instead of canonical `gd`. Preserve only if the mnemonic matters. | LazyVim LSP navigation mappings with Snacks/Telescope picker backend | Overriding standard `gd`-adjacent navigation can make docs and muscle memory diverge. | yes |
| `<leader>gr` and `<leader>cr` references via picker | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | References are already provided, but the old config intentionally duplicated them under goto and code groups. | LazyVim references mappings plus optional aliases | Duplicate mappings increase maintenance cost with little functional benefit. | yes |
| `<leader>gi` implementations via picker | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Same rationale as definitions and references. | LazyVim implementation picker | Minimal risk beyond key duplication. | yes |
| `<leader>gt` type definitions via picker | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Same rationale as other picker-backed goto mappings. | LazyVim type definition mapping | Minimal risk beyond key duplication. | yes |
| `<leader>ca` code action | already provided by LazyVim | `nvim.bak/lua/custom/lsp.lua` | Code actions are standard and already first-class in LazyVim. | LazyVim LSP code-action mapping | None beyond upstream keymap changes. | no |
| `<leader>cd` hover docs | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Hover is already available in LazyVim, but usually on `K`. Re-add only if the code-prefix mnemonic is specifically valuable. | Default hover plus optional alias | Duplicating hover across keys may be unnecessary. | yes |
| Diagnostic float style with rounded borders and minimal header | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | The visual result matters more than the monkey-patch approach. Recreate through supported opts rather than overriding core preview helpers. | `vim.diagnostic.config`, Noice opts, or LazyVim LSP opts | Monkey-patching `vim.lsp.util.open_floating_preview` is brittle across Neovim upgrades. | yes |
| Wrap + linebreak + spell for `markdown`, `text`, `gitcommit` | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is useful editor behavior, but it does not belong to LSP. Port it as an autocmd, not as part of LSP setup. | `lua/config/autocmds.lua` | Could be forgotten if migration only focuses on plugins. | no |

## Completion Behavior

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns | Revisit later |
| --- | --- | --- | --- | --- | --- | --- |
| `blink.cmp` as the completion engine | already provided by LazyVim | `nvim.bak/lua/custom/lsp.lua`, `lazy-lock.json` | The current LazyVim lockfile already includes `blink.cmp`, so migration should be an options merge, not a plugin re-add. | `blink.cmp` plugin opts in LazyVim | None. | no |
| Manual popup behavior with `auto_show = false` | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is a meaningful preference: completion stays manual while documentation still auto-shows once open. | `blink.cmp` completion menu opts | Changes completion feel significantly; should be validated with real editing. | yes |
| `<C-Space>` toggles completion menu | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Common and sensible, but should be expressed through LazyVim's blink opts rather than a full replacement config unless needed. | `blink.cmp` keymap opts | Must not clobber any LazyVim insert-mode conventions unintentionally. | yes |
| `<CR>` accept completion then fallback | already provided by LazyVim | `nvim.bak/lua/custom/lsp.lua` | Accept-on-Enter is standard completion behavior and should not require custom migration unless defaults differ materially. | Default `blink.cmp` enter handling | Verify behavior with snippets and autopairs before assuming parity. | yes |
| `<Tab>` order: Copilot suggestion, next item, snippet forward, fallback | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua`, `nvim.bak/lua/custom/configs/copilot-setup.lua` | This is one of the strongest custom workflows in the old config. Preserve the intent if Copilot is restored. | `blink.cmp` custom key handler plus `copilot.lua` integration | Very sensitive to plugin load order and snippet engine behavior. | yes |
| `<C-Tab>` previous completion item | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Useful, but should only be ported if the terminal and GUI reliably transmit the keycode. | `blink.cmp` keymap opts | `<C-Tab>` is often unavailable in terminal Neovim. | yes |
| `<Left>` / `<Right>` snippet jump | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is a non-default snippet navigation choice worth preserving only if it still feels natural. | `blink.cmp` snippet key handlers or LuaSnip mappings | Overriding arrow keys conflicts with the global “disable arrows” rule unless insert-mode behavior is carefully scoped. | yes |
| Completion documentation auto-show with rounded border | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is a UI preference layered on top of completion. | `blink.cmp` documentation window opts | Must be checked against Noice and overall float styling. | yes |
| Signature help popup enabled with rounded border | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Still useful, but should be migrated through blink/LSP opts rather than copied wholesale. | `blink.cmp` signature opts or LazyVim LSP opts | Needs retest alongside Noice hover/signature rendering. | yes |
| Disable ghost text | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Explicit and likely intentional. | `blink.cmp` ghost text opts | Small visual change, low migration risk. | no |
| Fuzzy matcher `prefer_rust` with prebuilt binary download | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is a performance and installation preference already captured in repo memory. | `blink.cmp` fuzzy opts | Prebuilt binary availability varies by platform and environment. | no |
| Copilot suggestion auto-trigger and hide during completion | adapt to LazyVim | `nvim.bak/lua/custom/configs/copilot-setup.lua` | This is custom coordination logic between Copilot and `blink.cmp`, not a default LazyVim behavior. | `copilot.lua` plus `blink.cmp` event hooks | Event names and Copilot internals can change across plugin versions. | yes |
| Disable Copilot on buffers whose names match `env` | discard | `nvim.bak/lua/custom/configs/copilot-setup.lua` | The heuristic is too broad and string-based to be trustworthy as a general policy. | None | Can disable Copilot in unintended files such as `.env.example` or paths containing `env`. | no |

## UI Behavior

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns | Revisit later |
| --- | --- | --- | --- | --- | --- | --- |
| `onedarkpro` theme with a classic One Dark palette | adapt to LazyVim | `nvim.bak/lua/custom/configs/colorscheme.lua`, `nvim.bak/init.lua` | The color identity is clearly deliberate, but the migration should use a LazyVim plugin spec instead of porting raw setup calls blindly. | LazyVim colorscheme override with `onedarkpro.nvim` | Large highlight override set may become expensive to maintain. | yes |
| Extensive highlight overrides for floats, Mason, Telescope, tree, diff, and bufferline | adapt to LazyVim | `nvim.bak/lua/custom/configs/colorscheme.lua` | Some of these should survive, but many target plugins or highlight groups that are no longer part of the LazyVim baseline. | Theme-specific highlight overrides in a dedicated plugin spec | `NvimTree*` and `Buffer*` groups will not map cleanly if `nvim-tree` and `barbar` are not migrated. | yes |
| Custom `lualine` “Eviline” layout | adapt to LazyVim | `nvim.bak/lua/custom/configs/statusline.lua` | The old statusline is highly customized and visually intentional, but `lualine` is already present in LazyVim. Port only after core workflows are stable. | `lualine.nvim` opts override | High effort for cosmetic value; can hide more important migration work. | yes |
| `noice.nvim` command palette popup, notify routing, popupmenu backend, rounded borders | adapt to LazyVim | `nvim.bak/lua/custom/configs/noice.lua` | LazyVim already ships `noice.nvim`, so this is an opts merge problem rather than a plugin decision. | `noice.nvim` opts override and `notify` setup | `noice` presets and view names can change across releases. | yes |
| `notify.nvim` wrapped compact render, bottom-up display, fixed timeout | adapt to LazyVim | `nvim.bak/lua/custom/configs/noice.lua` | These are stylistic choices and should only be ported if the current notification experience feels materially worse. | `notify.nvim` opts override | Notification stacking and sizing may interact differently with other LazyVim UI components. | yes |
| Hide `showmode` and rely on statusline | already provided by LazyVim | `nvim.bak/init.lua`, `nvim.bak/lua/custom/configs/statusline.lua` | This is standard once a statusline is active. | LazyVim default options | None. | no |
| Global line numbers, signcolumn always on, breakindent, clipboard, undo file, mouse | already provided by LazyVim or standard Neovim defaults worth keeping | `nvim.bak/init.lua` | These are foundational editor options, not migration hotspots. Only revisit if LazyVim defaults diverge in a meaningful way. | LazyVim default options plus optional `lua/config/options.lua` overrides | Clipboard behavior can vary by environment. | no |
| Wrap and spell in prose-oriented buffers | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is editor UX, not LSP. It should likely move to `lua/config/autocmds.lua`. | Custom autocmds in LazyVim | None beyond scope drift if forgotten. | no |

## Plugin-Specific Customizations

| Item | Classification | Original source | Reasoning | LazyVim equivalent | Risks / compatibility concerns | Revisit later |
| --- | --- | --- | --- | --- | --- | --- |
| `conform.nvim` filetype formatter map with Prettier root detection and fallback behavior | adapt to LazyVim | `nvim.bak/lua/custom/configs/conform.lua`, `nvim.bak/lua/custom/keymaps.lua` | The formatting policy is real project behavior and should move into a LazyVim plugin spec instead of a standalone setup module. | `conform.nvim` opts override in `lua/plugins/*.lua` | Must align with LazyVim's formatter defaults and repo-specific tool installation. | yes |
| Disable LSP formatting for formatter-managed servers | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This prevents conflicts and is already reflected in repo memory as an important practice. | LazyVim `nvim-lspconfig` server setup hooks | Needs care so server capabilities are changed after attachment and only where desired. | no |
| Mason UI dimensions, border, and icons | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is low-risk visual customization that can be reintroduced later if missed. | `mason.nvim` opts override | Mostly cosmetic. | yes |
| Mason tool installer for `mypy` and `stylua` | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | Tool installation belongs in LazyVim plugin opts and should be merged with any new migration choices. | `mason.nvim` / `mason-tool-installer.nvim` plugin opts | Must keep LSP servers separate from non-LSP tools. | no |
| Server-specific LSP settings for `lua_ls`, `pyright`, `eslint`, `ts_ls`, `ruff`, `svelte`, etc. | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | These are substantive behavior decisions and should be migrated deliberately one server at a time. | LazyVim `nvim-lspconfig` opts and language extras | Server names, defaults, and LazyVim extras can differ from the old setup. | yes |
| `svelte` JS/TS change notification autocmd | adapt to LazyVim | `nvim.bak/lua/custom/lsp.lua` | This is narrow but functionally important if Svelte editing is still active. | `LspAttach` hook in LazyVim LSP config | Must be validated against current Svelte LSP behavior before carrying it over. | yes |
| `nvim-tree` config: show ignored files, custom git glyphs, default on-attach mappings | adapt to LazyVim | `nvim.bak/lua/custom/configs/file-tree.lua` | The explorer still matters, but `nvim-tree` itself is not in the new baseline. Port the behavior, not the plugin code. | LazyVim explorer opts via `snacks.nvim` | Old APIs and highlight groups are not reusable as-is. | yes |
| `nvim-tree` rename hook into `Snacks.rename.on_rename_file` | discard | `nvim.bak/lua/custom/configs/file-tree.lua` | This exists only to bridge two old plugins together. If LazyVim uses Snacks-native rename flows, the bridge should disappear. | None unless explorer rename breaks | Porting this blindly would duplicate or fight the new explorer integration. | no |
| `barbar.nvim` bufferline configuration | discard | `nvim.bak/lua/custom/configs/barbar.lua`, `nvim.bak/lua/custom/configs/colorscheme.lua` | The old config invested heavily in bufferline visuals, but `barbar` is not part of the current LazyVim baseline and is not essential for core migration. | Optional future bufferline plugin if a real gap appears | High visual maintenance cost for low migration priority. | no |
| `telescope.nvim` hidden-file and no-ignore defaults | adapt to LazyVim | `nvim.bak/lua/custom/configs/telescope-config.lua` | The behavior is useful, but the new picker backend may be Snacks rather than Telescope-first. | `snacks.nvim` picker opts or Telescope opts override | Needs careful tuning to avoid noisy search results. | yes |
| Runtime `nvim-treesitter.parsers.ft_to_lang` compatibility shim | discard | `nvim.bak/lua/custom/configs/telescope-config.lua` | This is a defensive workaround for an older parser API mismatch and should not be carried forward without reproducing the bug. | None | High chance of preserving obsolete compatibility code. | no |
| Treesitter parser install list and auto-start-on-filetype logic | adapt to LazyVim | `nvim.bak/lua/custom/configs/treesitter-config.lua` | Parser coverage matters; custom bootstrapping logic does not. Keep the parser list, not the installation/startup implementation. | `nvim-treesitter` opts override or LazyVim language extras | Old imperative install logic is unnecessary in LazyVim. | no |
| `mini.clue` leader hints | already provided by LazyVim | `nvim.bak/lua/custom/plugins.lua` | LazyVim already uses `which-key.nvim` to surface key groups. | `which-key.nvim` | No need to keep both systems. | no |
| `mini.hipatterns` TODO / NOTE / WARN highlighting | adapt to LazyVim | `nvim.bak/lua/custom/plugins.lua` | This is a nice enhancement but not core migration work. | `mini.hipatterns` plugin spec or equivalent highlight tool | Low risk, low priority. | yes |
| `mini.comment`, `mini.cursorword`, `mini.bufremove`, `mini.pairs` | mostly already provided by LazyVim or easy to defer | `nvim.bak/lua/custom/plugins.lua` | These are quality-of-life plugins; migrate only after confirming LazyVim does not already cover the workflow. | LazyVim defaults and optional mini.nvim specs | Risk of duplicating behavior with existing LazyVim plugins. | yes |
| Snacks config for float style, picker, terminal, lazygit, rename, indent | mostly already provided by LazyVim | `nvim.bak/lua/custom/plugins.lua` | Snacks is already in the target stack, so only true deviations from LazyVim defaults should be ported. | `snacks.nvim` opts override | Upstream LazyVim may already set overlapping opts. | yes |

## Deferred / Lower-Priority Findings

- Debugger workflows in `nvim.bak/lua/custom/debugger.lua` were intentionally not migrated yet because they are outside the requested inventory categories and would materially expand scope.
- Bufferline-specific highlight work in the old colorscheme should stay deferred unless a bufferline plugin is reintroduced.
- The old config used several dedicated setup modules. In LazyVim, most of this should collapse into `lua/config/*.lua` and targeted `lua/plugins/*.lua` specs instead of restoring the old module layout.

## Workflow Notes For Future Migration Sessions

- Update this file before or alongside any migration change that alters a decision, not after a large batch of unrelated edits.
- Prefer one behavior slice at a time: keymaps, terminal, LSP server settings, formatting, then UI polish.
- When an old behavior depends on a plugin that no longer exists in LazyVim, migrate the user-visible workflow first and only re-add the old plugin if the new stack cannot support it.
- Treat `nvim.bak/lua/custom/lsp.lua`, `nvim.bak/lua/custom/keymaps.lua`, and `nvim.bak/lua/custom/terminal.lua` as the highest-signal old files for future migration work.
- Before migrating a UI customization, confirm the corresponding plugin is actually in the LazyVim baseline. Do not port `nvim-tree` or `barbar` highlight code into unrelated plugins.

## Recommended Next Migration Order

1. Port editor habits that are plugin-independent: `q` disable, arrow-key disable, prose buffer autocmds.
2. Port formatting and LSP server settings that affect correctness: `conform.nvim`, server-specific opts, formatting capability rules.
3. Port terminal and git workflows with `snacks.nvim` so command-line workflows stay productive.
4. Revisit completion and Copilot coordination only after the base LSP stack is stable.
5. Revisit theme, `noice`, and statusline polish last.
