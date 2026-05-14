# Workflow Acceptance

Last updated: 2026-05-13

This document defines the acceptance gates for each migration slice. A slice is only considered accepted after the implementation exists in the correct LazyVim surface, the expected workflow is manually or programmatically validated, and no conflicting legacy behavior remains.

Rule: any workflow item or acceptance criterion classified as `discard` is ignored entirely during migration. Discarded items are recorded only as migration decisions and must not be implemented, validated, or checked off unless they are later reclassified.

## Editor Guardrail Keymaps

Slice status: accepted. Local keymaps are now loaded explicitly from `lua/config/lazy.lua`, so these guardrails apply during normal startup.

### Disable normal-mode `q` macro recording

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `q` in normal mode must be a no-op and must not enter macro-recording state.
- [x] Pressing `q` in normal mode must not change any macro register contents and must not show recording status in the command area.
- [x] The override must be limited to normal mode only. Other macro-related behavior such as `@` playback or any explicit future macro mapping must remain available unless separately changed.
- [x] The mapping must live in `lua/config/keymaps.lua` rather than in a plugin spec or legacy compatibility module.
- [x] There must be no second competing normal-mode mapping for `q` defined elsewhere in the active config.
- [x] The implementation must not depend on `nvim.bak` modules or plugin APIs.

Validation performed:

- [x] Headless startup confirmed `config.keymaps` loads automatically and `vim.fn.maparg("q", "n")` resolves to `<Nop>`.
- [x] The mapping is defined in `lua/config/keymaps.lua` and no active legacy module is required.

### Disable arrow keys in all intended non-terminal modes

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] `<Up>`, `<Down>`, `<Left>`, and `<Right>` must be disabled in normal, insert, visual, select, operator-pending, and command-line modes.
- [x] The same arrow keys must remain functional in terminal mode so shell programs, TUIs, and REPLs keep their expected controls.
- [x] The disabled mappings must resolve to explicit no-ops rather than to remapped movement commands.
- [x] The implementation must be centralized in `lua/config/keymaps.lua` and expressed as general editor behavior, not as terminal-plugin logic.
- [x] There must be no later mapping that silently re-enables arrow-key movement in the covered non-terminal modes.
- [x] The behavior must be consistent regardless of whether the user starts in insert mode, visual mode, or command-line mode.

Validation performed:

- [x] Headless startup confirmed all four arrow keys resolve to `<Nop>` in `n`, `i`, `v`, `x`, `s`, `o`, and `c` modes.
- [x] Headless startup confirmed the same arrow keys are not disabled in terminal mode.

## File, Buffer, and Quit Keymaps

Slice status: accepted for actionable items. The discarded buffer-cycling aliases remain ignored by rule.

### `<leader>w` save buffer

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>w` in normal mode must write the current buffer immediately.
- [x] The mapping must preserve normal write semantics: modified buffers save, unmodified buffers remain harmless, and error messages still surface for unwritable buffers.
- [x] The mapping must not also close the buffer, trigger formatting, or invoke unrelated file actions.
- [x] The mapping must be discoverable as a global keymap with a clear description.
- [x] The implementation must live in `lua/config/keymaps.lua` and must not call into legacy helper modules.
- [x] No conflicting normal-mode `<leader>w` mapping may remain active elsewhere in the config.

Suggested validation:

- [x] Edit a file, trigger `<leader>w`, and confirm the buffer's modified flag clears.
- [x] Check `:verbose nmap <leader>w` to confirm ownership comes from `lua/config/keymaps.lua`.

### Two-step quit prefix: `<leader>q`, `<leader>qq`, `<leader>qb`

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>q` alone must not quit anything; it must function only as a safe prefix and must not execute an action by itself.
- [x] Pressing `<leader>qq` must exit Neovim in a way that matches the intended "quit the program" workflow rather than only closing the current split.
- [x] Pressing `<leader>qb` must close the current buffer without exiting the entire Neovim session when other buffers remain.
- [x] Buffer closing must respect LazyVim's buffer workflow closely enough that bufferline state, alternate buffer behavior, and unsaved-change prompts still behave correctly.
- [x] Any default LazyVim quit mappings that conflict with this two-step ownership must be removed or overridden so there is one authoritative behavior for these keys.
- [x] The implementation must remain in `lua/config/keymaps.lua`; plugin-specific buffer deletion logic may be called from there if needed, but the user-facing ownership must stay in the keymaps layer.
- [x] Which-key or equivalent hinting must present `<leader>q` as a prefix, with the actual destructive actions only on the second keystroke.
- [x] The implementation must not leave hidden duplicate actions on `<leader>q` that can still fire before the second keypress resolves.

Suggested validation:

- [x] Press `<leader>q` and pause; confirm no quit action runs.
- [x] Press `<leader>qq` and confirm the Neovim session exits.
- [x] Press `<leader>qb` with multiple buffers open and confirm only the current buffer closes.

### `<C-Right>` / `<C-Left>` buffer cycling

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## Explorer, Diagnostics, Git, and Format Keymaps

Slice status: accepted. The active mappings use LazyVim-native Snacks, Trouble, and formatting integrations with stale `nvim-tree` and Telescope diagnostics assumptions left only in `nvim.bak`.

### `<leader>e` file explorer toggle

Classification: `already provided by LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] A file explorer toggle must remain available on `<leader>e` through the active LazyVim explorer stack.
- [x] The migration must not restore `nvim-tree`-specific API calls or compatibility wrappers just to preserve the key.
- [x] The key must open and close the LazyVim-native explorer consistently without requiring legacy modules from `nvim.bak`.
- [x] The explorer workflow must remain discoverable through the active key-hint system.
- [x] If LazyVim already owns `<leader>e`, acceptance prefers keeping that default ownership over adding redundant custom code.
- [x] No duplicate explorer toggle mapping may remain that points to a removed plugin implementation.

Suggested validation:

- [x] Trigger `<leader>e` twice and confirm the explorer toggles open and closed.
- [x] Search for `nvim-tree` references in active config and confirm none are required for this workflow.

### Diagnostics and issues picker for the current file

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] The old intent, "show diagnostics for the current file," must remain reachable through a LazyVim-native diagnostics view.
- [x] If LazyVim keeps `<leader>xx` for workspace diagnostics, the file-local workflow must be available on the accepted alternative key described in the inventory, with no ambiguity between workspace-wide and current-file scopes.
- [x] The implementation must use `trouble.nvim`, Snacks, or another LazyVim-native diagnostics surface rather than restoring Telescope-only legacy code for this purpose.
- [x] The chosen mapping must clearly indicate file-local diagnostics in its description so the narrower scope is visible to the user.
- [x] The mapping must open a diagnostics list for the current buffer only and must not silently expand to workspace diagnostics.
- [x] Conflicting legacy mappings for the same key sequence must be removed so the active scope is deterministic.
- [x] The behavior must work even when multiple files in the workspace have diagnostics; only the current buffer's diagnostics should appear in the file-local view.

Validation performed:

- [x] Confirm the final key sequence points to LazyVim-native Trouble diagnostics with `filter.buf=0` for current-buffer scope.
- [x] Confirm no active keymap in `lua/config/keymaps.lua` restores the old Telescope diagnostics command.

### `<leader>lg` open LazyGit

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>lg` in normal mode must open LazyGit from within the editor.
- [x] The workflow must use LazyVim's existing Snacks LazyGit integration rather than a reintroduced standalone plugin setup.
- [x] Any default mappings that conflict with preserving the old `<leader>lg` habit must be removed or neutralized so the legacy mnemonic is the single accepted entry point.
- [x] The mapping description must remain clear enough for key-hint discovery.
- [x] The implementation must fail cleanly when LazyGit is unavailable, surfacing an ordinary error or notification rather than crashing config load.
- [x] The mapping must live in `lua/config/keymaps.lua`, with plugin behavior implemented by the owned LazyVim plugin stack.

Validation performed:

- [x] Trigger the `<leader>lg` callback inside a Git repository and confirm it enters the LazyGit TUI path.
- [x] Check that `<leader>gg` and `<leader>gG` no longer compete if the migration intentionally gives `<leader>lg` exclusive ownership of this habit.

### `<leader>f` format buffer

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>f` in normal mode must format the current buffer through LazyVim's formatting stack.
- [x] The mapping must use the active `conform.nvim` or LazyVim format path rather than legacy standalone formatting code.
- [x] The action must target the current buffer only and must not also save, search files, or trigger unrelated file-prefix behaviors.
- [x] Any conflicting LazyVim key ownership that prevents bare `<leader>f` from acting as an immediate format command must be resolved so the top-level key does exactly one thing.
- [x] The final key-hint presentation must not mislead the user into expecting file-finder behavior on bare `<leader>f`.
- [x] Formatting errors must surface normally without breaking future invocations of the key.
- [x] The implementation must remain in `lua/config/keymaps.lua`, with formatter policy configured separately in plugin specs when needed.

Suggested validation:

- [x] Trigger `<leader>f` in a buffer with known formatter support and confirm the contents are reformatted.
- [x] Run `:verbose nmap <leader>f` and confirm the mapping comes from the keymaps layer rather than an accidental plugin default.

## Search and Picker Keymaps

Slice status: accepted. The active picker backend is Telescope through LazyVim's `editor.telescope` extra, with migration-specific key ownership in `lua/plugins/picker.lua`.

### Search suite under `<leader>s*`, `<leader>/`, and `<leader>sn`

Classification: `mostly already provided by LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] The legacy search intents must all remain reachable through LazyVim-native picker workflows: help tags, keymaps, files, document symbols or picker list, current word, live grep, diagnostics, recent files, current-buffer fuzzy search, open buffers, and Neovim-config files.
- [x] The accepted search keys must be coherent with LazyVim conventions rather than a direct port of Telescope helper functions from `nvim.bak`.
- [x] Where LazyVim already provides an equivalent mapping, acceptance prefers the default key over custom duplicate aliases unless the inventory explicitly preserves a muscle-memory alias.
- [x] Duplicate bindings for the same search action must be removed when they create ambiguity or split discoverability.
- [x] If the active picker backend is Snacks rather than Telescope, the migration must use that backend's public API or LazyVim wrappers instead of plugin-specific legacy commands.
- [x] Hidden-file and picker-backend differences are acceptable only if the core intent of each search action remains available and documented.
- [x] The config-search workflow for the Neovim config directory must remain reachable, whether on `<leader>sn` or another explicitly accepted LazyVim-native equivalent.
- [x] The current-buffer search action must support searching within the open file without depending on the removed Telescope-only implementation.
- [x] No stale `telescope.nvim`-only assumptions may remain in active keymap code unless Telescope is still the active owner for that exact workflow.

Validation performed:

- [x] Headless startup confirmed `<leader>sh`, `<leader>sk`, `<leader>sf`, `<leader>ss`, `<leader>sw`, `<leader>sg`, `<leader>sd`, `<leader>s.`, `<leader>/`, `<leader>s/`, `<leader>sb`, `<leader><space>`, `<leader>,`, and `<leader>sn` all resolve to accepted picker mappings.
- [x] Headless startup confirmed conflicting Telescope file-prefix mappings on `<leader>fb`, `<leader>ff`, `<leader>fg`, `<leader>fr`, and `<leader>fc` are unmapped so bare `<leader>f` remains the accepted Format action.
- [x] Headless startup confirmed Noice's `<leader>sn*` mappings no longer block `<leader>sn` as the config-file picker.

## Escape Key Behavior

Slice status: accepted for terminal-mode Escape behavior. The discarded normal-mode file-tree Escape behavior remains ignored by rule.

### Normal-mode `<Esc>` closes file tree if visible

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### Terminal-mode `<Esc>` closes floating terminal

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<Esc>` in terminal mode inside a migrated floating terminal must close or hide that floating terminal window.
- [x] The behavior must apply to Snacks terminal floats without requiring legacy `custom.terminal` modules.
- [x] Normal terminal applications outside the migrated floating-terminal workflow must not receive unrelated global keymap breakage.
- [x] The mapping must live in the appropriate terminal plugin override layer rather than as unrelated editor-wide Escape behavior.
- [x] The implementation must not reintroduce the discarded normal-mode file-tree Escape behavior.

Validation performed:

- [x] Headless startup confirmed terminal-mode `<Esc>` resolves to the Snacks terminal `Hide Terminal` window key.
- [x] Active config search confirmed no normal-mode file-tree Escape mapping was reintroduced.

## Terminal Entry Points

Slice status: accepted. Terminal entry points are implemented through `snacks.terminal` in `lua/plugins/terminal.lua`.

### Single reusable floating shell terminal on `<leader>t`

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>t` must toggle one dedicated reusable floating shell terminal.
- [x] The implementation must use `snacks.terminal` rather than the legacy terminal lifecycle code.
- [x] Reopening the terminal must return to the same running shell job while that job remains valid.
- [x] The mapping must be discoverable with a clear description and must not conflict with LazyVim terminal defaults that change the accepted workflow.
- [x] The terminal identity must be stable enough that repeated toggles do not spawn stacked duplicate shell floats.

Validation performed:

- [x] Headless startup confirmed `<leader>t` resolves to a migrated callback with the `Terminal` description.
- [x] Code audit confirmed the terminal identity is stable through the Snacks terminal id inputs: command, first-launch cwd, env, and count.

### Dedicated floating `copilot` CLI terminal on `<leader>cc`

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>cc` must open a dedicated floating terminal running the `copilot` CLI when the binary is available.
- [x] The Copilot CLI terminal must have its own stable terminal identity separate from the general shell terminal.
- [x] Opening the Copilot terminal must use `snacks.terminal` and must not call legacy terminal modules.
- [x] If the `copilot` binary is missing, the mapping must fail cleanly with a useful notification or error.
- [x] Repeated use must reuse or toggle the dedicated Copilot terminal rather than stacking new floats.

Validation performed:

- [x] `command -v copilot` confirmed the CLI exists in this environment.
- [x] Headless startup confirmed `<leader>cc` resolves to a migrated callback with the `Copilot CLI` description.
- [x] Code audit confirmed the callback notifies and returns cleanly if `vim.fn.executable("copilot")` is false.

## Terminal Lifecycle and Reuse

Slice status: accepted. Migrated terminal reuse is scoped to Snacks terminal instances.

### Close other floating terminals when opening one

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Opening one migrated floating terminal must hide any other active migrated floating terminal window.
- [x] Hidden terminal buffers and running jobs must remain reusable in the background.
- [x] The behavior must prevent visually stacked terminal floats without killing terminal processes unnecessarily.
- [x] The implementation must be scoped to the migrated Snacks terminal instances.
- [x] Switching between shell and Copilot terminals must produce one visible floating terminal at a time.

Validation performed:

- [x] Code audit confirmed `hide_other_terminals()` hides any other visible migrated Snacks terminal before opening the requested terminal kind.
- [x] The implementation calls `hide()` rather than `close()` so hidden terminal buffers and jobs remain reusable.

### Reuse existing terminal buffer and running job

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Each migrated terminal kind must reuse its existing buffer and running job while valid.
- [x] Hiding and reopening a terminal must not reset shell state or command history.
- [x] If a terminal process exits cleanly, the next toggle may create a fresh terminal without errors.
- [x] Terminal reuse must be implemented with Snacks terminal identity or equivalent LazyVim-native state, not with `nvim.bak` state tables.
- [x] Reuse must remain deterministic across repeated toggles in the same Neovim session.

Validation performed:

- [x] Code audit confirmed `Snacks.terminal.get(..., { create = false })` is used before toggling and that the same Snacks terminal identity is reused while the buffer remains valid.
- [x] The implementation uses no legacy `nvim.bak` terminal state table.

### Auto-close floating terminal on `BufLeave`

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Leaving a migrated floating terminal buffer must hide or close the terminal float according to the accepted single-float workflow.
- [x] The terminal process must not be killed merely because the window was hidden on buffer leave.
- [x] The behavior must not break non-terminal buffer navigation or LazyVim's ordinary window handling outside this migrated terminal slice.
- [x] Any LazyVim split or multi-window terminal mappings that conflict with the accepted workflow must be removed or neutralized.
- [x] The behavior must be documented as an intentional terminal workflow choice rather than a general editor autocmd.

Validation performed:

- [x] Code audit confirmed the Snacks terminal window registers a buffer-local `BufLeave` handler that hides the float without deleting the terminal buffer.
- [x] Headless startup confirmed LazyVim's default `<C-/>` and `<C-_>` terminal focus mappings are unmapped; `<leader>ft` and `<leader>fT` were already cleared with the file-prefix removal.

## Terminal Window Presentation

Slice status: accepted for terminal local options. Floating terminal highlight customization remains open.

### Terminal local options: disable number, relativenumber, signcolumn

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Migrated terminal floats must display without `number`, `relativenumber`, or a visible `signcolumn`.
- [x] These options must be local to terminal windows and must not change normal editing buffers globally.
- [x] The implementation must be expressed through Snacks terminal window options or terminal-local configuration.
- [x] Reopening the same terminal must preserve the local presentation settings.

Validation performed:

- [x] Headless terminal smoke testing confirmed the migrated terminal window options are `number=false`, `relativenumber=false`, and `signcolumn=no` before teardown.
- [x] Code audit confirmed these are Snacks terminal window-local options rather than global option changes.

### Floating terminal highlight group customization

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Floating terminal borders and background must use the accepted LazyVim-compatible highlight groups.
- [ ] The implementation must not depend on obsolete highlight groups from removed plugins.
- [ ] Terminal float styling must remain compatible with the active colorscheme.
- [ ] Highlight overrides must live in the theme or plugin presentation layer, not in general keymap code.
- [ ] The terminal must remain readable in both focused and unfocused states.

Suggested validation:

- [ ] Open a floating terminal and visually confirm border and background colors match the intended theme style.
- [ ] Run `:hi` checks for the terminal-related highlight groups and confirm they resolve to active groups.

## Git Entry Points

Slice status: acceptance criteria defined. Do not mark this slice accepted until each item below is implemented or confirmed provided and then validated.

### Open LazyGit from the editor

Classification: `already provided by LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] LazyGit must remain available from inside Neovim through LazyVim's Snacks integration.
- [ ] The accepted user-facing key habit must be `<leader>lg` if the migration preserves the old mnemonic.
- [ ] Default LazyVim LazyGit mappings that compete with exclusive `<leader>lg` ownership must be removed or intentionally documented.
- [ ] The workflow must not re-add a separate LazyGit plugin setup.
- [ ] Missing LazyGit executable behavior must surface cleanly without breaking config load.

Suggested validation:

- [ ] Trigger `<leader>lg` in a Git repository and confirm LazyGit opens.
- [ ] Check final LazyGit key ownership with `:verbose nmap` for `<leader>lg`, `<leader>gg`, and `<leader>gG`.

## Git Signs, Status, and Explorer State

Slice status: acceptance criteria defined. Discarded items in this slice remain intentionally out of scope.

### Gitsigns signs for add/change/changedelete

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### Enable `numhl`, `linehl`, and `current_line_blame` in gitsigns

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### Branch and diff information in the statusline

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### Show git state in the file explorer

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] The active LazyVim explorer must show useful Git state for files where the explorer supports it.
- [ ] The implementation must not reintroduce `nvim-tree` solely for Git indicators.
- [ ] Any highlight or icon customization must target the active explorer's supported groups.
- [ ] Explorer Git state must coexist with LazyVim's existing Git signs and statusline behavior without duplicating plugin ownership.
- [ ] Missing or unsupported explorer Git decorations must be documented as a LazyVim-native limitation before accepting the slice.

Suggested validation:

- [ ] Open the explorer in a Git repo with modified and untracked files and confirm Git state is visible if supported.
- [ ] Search active config for `NvimTree` references and confirm none are required for this workflow.

## Git-Aware Search Behavior

Slice status: acceptance criteria defined. Discarded items in this slice remain intentionally out of scope.

### Hidden and ignored files searchable by default

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## LSP Navigation Keymaps

Slice status: accepted for actionable items. The migrated leader mappings are implemented through `nvim-lspconfig` opts in `lua/plugins/lsp.lua`; discarded reference aliases remain ignored by rule.

### `<leader>gd` definitions via picker

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>gd` in an attached LSP buffer must show definitions through the active LazyVim picker/navigation stack.
- [x] The canonical `gd` mapping must remain available unless separately reclassified.
- [x] The implementation must not require Telescope-only legacy helper code if Snacks is the active picker owner.
- [x] The mapping must be buffer-aware and only active when LSP navigation is meaningful.
- [x] Conflicting `<leader>gd` mappings must be removed or resolved so the behavior is deterministic.

Validation performed:

- [x] Headless Neovim opened `lua/plugins/lsp.lua`, waited for `lua_ls` attach, and confirmed `<leader>gd` resolves to the migrated `Goto Definition` mapping after Snacks' LSP-key debounce.
- [x] The same runtime check confirmed canonical `gd` still resolves to LazyVim's `Goto Definition` mapping.

### `<leader>gr` and `<leader>cr` references via picker

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### `<leader>gi` implementations via picker

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>gi` in an attached LSP buffer must show implementations through the LazyVim-native picker/navigation workflow.
- [x] Any conflicting default `<leader>gI` mapping must be removed or intentionally redirected according to the inventory decision.
- [x] The mapping must not depend on legacy Telescope-only code unless Telescope is the accepted active owner.
- [x] The description must clearly identify implementation lookup.
- [x] The behavior must be scoped to LSP-capable buffers.

Validation performed:

- [x] Headless Neovim opened `lua/plugins/lsp.lua`, waited for `lua_ls` attach, and confirmed `<leader>gi` resolves to `Goto Implementation`.
- [x] Merged `nvim-lspconfig` opts were checked to confirm any `<leader>gI` owner is removed before migrated LSP keys are appended.

### `<leader>gt` type definitions via picker

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>gt` in an attached LSP buffer must show type definitions through the LazyVim-native picker/navigation workflow.
- [x] Default mappings on `<leader>gT` and preexisting `<leader>gt` must be resolved before adding the accepted binding.
- [x] The mapping must not remove unrelated standard LSP navigation defaults.
- [x] The mapping description must clearly identify type definition lookup.
- [x] The behavior must fail harmlessly when the server does not support type definitions.

Validation performed:

- [x] Headless Neovim opened `lua/plugins/lsp.lua`, waited for `lua_ls` attach, and confirmed `<leader>gt` resolves to `Goto Type Definition`.
- [x] Merged `nvim-lspconfig` opts were checked to confirm any `<leader>gT` owner is removed before migrated LSP keys are appended.

## LSP Actions and Diagnostic UI

Slice status: accepted for code action, hover docs, and diagnostic float style. The implementation stays in LazyVim-native LSP and diagnostic surfaces rather than legacy monkey patches.

### `<leader>ca` code action

Classification: `already provided by LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Code actions must remain reachable on the accepted LazyVim code-action mapping.
- [x] The migration must not add redundant legacy mappings for the same behavior unless a specific workflow gap is documented.
- [x] The action must use `vim.lsp.buf.code_action` or LazyVim's configured wrapper without legacy module dependencies.
- [x] The key hint description must remain clear for code actions.

Validation performed:

- [x] Headless Neovim opened `lua/plugins/lsp.lua`, waited for `lua_ls` attach, and confirmed `<leader>ca` still resolves to LazyVim's `Code Action` mapping.
- [x] Active config search confirmed no legacy `custom.lsp` module is loaded or required.

### `<leader>cd` hover docs

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Pressing `<leader>cd` in an attached LSP buffer must show hover documentation.
- [x] The default `K` hover binding must be removed only if the migration explicitly gives `<leader>cd` sole ownership.
- [x] The hover implementation must use LazyVim/LSP APIs and not a legacy wrapper.
- [x] The mapping description must make the hover-doc behavior discoverable.
- [x] Hover windows must inherit the accepted float styling where possible.

Validation performed:

- [x] Headless Neovim opened `lua/plugins/lsp.lua`, waited for `lua_ls` attach, and confirmed `<leader>cd` resolves to the migrated `Hover` mapping.
- [x] The same runtime check confirmed `K` is unmapped after the LSP attach cleanup runs.
- [x] `lua/config/keymaps.lua` removes LazyVim's global `<leader>cd` line-diagnostics mapping so the LSP buffer-local hover mapping is deterministic.

### Diagnostic float style with rounded borders and minimal header

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Diagnostic floats must use rounded borders and a minimal header/prefix presentation where supported.
- [x] The implementation must prefer supported diagnostic, Noice, Trouble, or LazyVim opts over monkey-patching `vim.lsp.util.open_floating_preview`.
- [x] Diagnostic list workflows must remain compatible with the file-local diagnostics mapping from the inventory.
- [x] Styling must not degrade hover, signature help, or completion documentation windows unexpectedly.
- [x] The final behavior must be documented in the owning plugin or diagnostic configuration surface.

Validation performed:

- [x] Merged `nvim-lspconfig` opts were checked to confirm diagnostic floats set `border = "rounded"`, `source = "always"`, empty `header`, empty `prefix`, `focusable = false`, and `style = "minimal"`.
- [x] Runtime `vim.diagnostic.config().float` was checked after startup and LSP attach to confirm the accepted diagnostic float options are active.

## LSP-Related Filetype Behavior

Slice status: acceptance criteria defined. Discarded items in this slice remain intentionally out of scope.

### Wrap + linebreak + spell for `markdown`, `text`, `gitcommit`

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## Completion Engine and Menu Behavior

Slice status: implemented and partially accepted. `blink.cmp` engine ownership is accepted; the manual popup feel still needs an interactive insert-mode smoke test.

### `blink.cmp` as the completion engine

Classification: `already provided by LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] `blink.cmp` must remain the active completion engine through LazyVim's plugin stack.
- [x] The migration must configure `blink.cmp` through LazyVim plugin opts rather than re-adding or fully replacing the plugin setup.
- [x] Completion capabilities must remain wired into LSP clients.
- [x] No legacy completion engine setup may compete with `blink.cmp`.

Validation performed:

- [x] Headless Neovim loaded the full plugin set and confirmed `LazyVim.opts("blink.cmp")` resolves to the migrated merged configuration.
- [x] The same runtime validation confirmed `lua_ls` attaches successfully and still uses the Blink-backed LSP capability path.

### Manual popup behavior with `auto_show = false`

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Completion menu auto-show must be disabled so completion remains manually triggered.
- [ ] Documentation may still auto-show after the completion menu is open according to the accepted popup behavior.
- [ ] The setting must be applied through `blink.cmp` opts without replacing unrelated LazyVim defaults unnecessarily.
- [ ] Manual triggering must still work reliably in insert mode.
- [ ] The changed completion feel must be explicitly validated with real editing.

Suggested validation:

- [ ] Enter insert mode and type completion-worthy text; confirm the menu does not open automatically.
- [ ] Press the accepted manual trigger and confirm the completion menu opens.

## Completion Key Behavior

Slice status: acceptance criteria defined. Do not mark this slice accepted until each item below is implemented or intentionally left absent according to its classification and then validated.

### `<C-Space>` toggles completion menu

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Pressing `<C-Space>` in insert mode must show the completion menu when it is hidden.
- [ ] Pressing `<C-Space>` again must hide or toggle the menu according to the accepted `blink.cmp` behavior.
- [ ] Any preexisting insert-mode `<C-Space>` binding that conflicts must be removed before the accepted binding is applied.
- [ ] The mapping must be configured through `blink.cmp` keymap opts.
- [ ] The binding must not break terminal-mode or normal-mode use of `<C-Space>` outside completion.

Suggested validation:

- [ ] Trigger `<C-Space>` in insert mode and confirm the completion menu opens.
- [ ] Trigger it while the menu is open and confirm the accepted toggle behavior.

### `<CR>` accept completion then fallback

Classification: `adapt to LazyVim or already provided by LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Pressing `<CR>` with a selected completion item must accept that item.
- [ ] Pressing `<CR>` when completion should not accept an item must fall back to normal Enter behavior.
- [ ] The behavior must coexist with snippets and autopairs without obvious regressions.
- [ ] The mapping must be expressed through `blink.cmp` keymap opts or confirmed as already provided.
- [ ] The final behavior must be validated in both completion and ordinary newline contexts.

Suggested validation:

- [ ] Open completion, select an item, press `<CR>`, and confirm it is accepted.
- [ ] Press `<CR>` in insert mode with no completion menu and confirm a normal newline is inserted.

### `<Tab>` order: Copilot suggestion, next item, snippet forward, fallback

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Pressing `<Tab>` must accept a visible Copilot suggestion before selecting completion items.
- [ ] If no Copilot suggestion is visible and completion is open, `<Tab>` must select the next completion item.
- [ ] If snippet navigation is active, `<Tab>` must jump forward before falling back.
- [ ] If none of those contexts apply, `<Tab>` must fall back to ordinary insert behavior.
- [ ] The implementation must account for plugin load order between Copilot, snippets, and `blink.cmp`.

Suggested validation:

- [ ] Validate `<Tab>` with a visible Copilot suggestion, an open completion menu, an active snippet, and a plain insert context.
- [ ] Confirm no errors occur when Copilot is unavailable or disabled for the buffer.

### `<C-J>` next completion item

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Pressing `<C-J>` while completion is visible must move to the next completion item.
- [ ] The mapping must be scoped to completion behavior and should fall back when the completion menu is not visible.
- [ ] Any conflicting insert-mode `<C-J>` mapping must be removed or resolved before acceptance.
- [ ] The behavior must be configured through `blink.cmp` keymap opts.
- [ ] The mapping must not interfere with normal-mode navigation or terminal behavior.

Suggested validation:

- [ ] Open completion and press `<C-J>` repeatedly to confirm item selection advances.
- [ ] Press `<C-J>` with completion closed and confirm the fallback behavior is acceptable.

### `<Left>` / `<Right>` snippet jump

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## Completion Popup Presentation

Slice status: implemented and partially accepted. The fuzzy matcher preference is accepted; the popup rendering items still need interactive UI confirmation.

### Completion documentation auto-show with rounded border

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Completion documentation must auto-show once the completion menu is open.
- [ ] Completion documentation windows must use rounded borders where supported.
- [ ] The configuration must be applied through `blink.cmp` documentation window opts.
- [ ] Documentation rendering must remain compatible with Treesitter highlighting if enabled.
- [ ] The documentation window must not conflict visually with Noice or other float styling.

Suggested validation:

- [ ] Manually open completion on an item with documentation and confirm the docs window appears with rounded borders.
- [ ] Move between completion items and confirm the docs window updates without errors.

### Signature help popup enabled with rounded border

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Signature help must be enabled for supported LSP contexts.
- [ ] Signature help windows must use rounded borders where supported.
- [ ] The implementation must use `blink.cmp` signature opts or LazyVim LSP opts rather than legacy setup code.
- [ ] Signature help must not obscure or break completion menu interactions.
- [ ] Unsupported servers must fail silently without config errors.

Suggested validation:

- [ ] Type a function call in an LSP-backed file and confirm signature help appears.
- [ ] Confirm the signature window border matches the accepted rounded style.

### Disable ghost text

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Completion ghost text must be disabled in ordinary insert-mode editing.
- [ ] Disabling ghost text must not disable completion menu items or Copilot suggestion handling.
- [ ] The setting must be applied through `blink.cmp` opts.
- [ ] The visual result must be checked in a buffer with active completion sources.

Suggested validation:

- [ ] Type completion-worthy text and confirm no inline completion ghost text appears.
- [ ] Manually open completion and confirm completion items still appear.

### Fuzzy matcher `prefer_rust` with prebuilt binary download

Classification: `already provided by LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] The `blink.cmp` fuzzy matcher must remain on the LazyVim-provided or accepted performant implementation.
- [x] The migration must not add redundant fuzzy matcher setup if LazyVim already provides it.
- [x] If verified, prebuilt binary download behavior must match the accepted `prefer_rust` preference.
- [x] Failure to verify this low-priority detail must be documented rather than blocking unrelated completion migration.

Validation performed:

- [x] Headless runtime validation confirmed `LazyVim.opts("blink.cmp").fuzzy.implementation == "prefer_rust"` and that the migrated opts retain the prebuilt-binary download setting.
- [x] Completion ranking in a live editing session still remains worth a manual smoke test, but the intended option state is active.

## Copilot Completion Coordination

Slice status: implemented and partially accepted. The `.env` attachment guard is accepted; suggestion rendering and hide behavior still need an interactive insert-mode smoke test.

### Copilot suggestion auto-trigger and hide during completion

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Copilot suggestions must auto-trigger according to the accepted old workflow.
- [ ] Copilot suggestions must hide or avoid visual overlap while the `blink.cmp` completion menu is visible.
- [ ] The implementation must use supported `copilot.lua` and `blink.cmp` integration points where possible.
- [ ] Event handling must tolerate plugin load order and missing Copilot availability without config errors.
- [ ] The behavior must be validated alongside the accepted `<Tab>` priority order.

Suggested validation:

- [ ] In a Copilot-enabled buffer, confirm suggestions appear automatically when completion is closed.
- [ ] Open the completion menu and confirm Copilot suggestions hide or no longer overlap.

### Disable Copilot on buffers whose names match `.env` or `.env.*`

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Copilot must be disabled for `.env` and `.env.*` buffers.
- [x] The disable rule must use buffer name or file pattern checks supported by `copilot.lua`.
- [x] The rule must not disable Copilot for unrelated files.
- [x] The implementation must avoid reading, logging, or exposing environment file contents.
- [x] The behavior must work for both newly opened and already loaded environment buffers where practical.

Validation performed:

- [x] Headless runtime validation confirmed `LazyVim.opts("copilot.lua").should_attach(0, ".env") == false`.
- [x] Code audit confirmed the migrated `should_attach` wrapper only filters `.env` and `.env.*` basenames before delegating to Copilot's default attach policy.

## Theme and Highlight Behavior

Slice status: accepted. The active theme and retained highlight overrides are now implemented in `lua/plugins/colorscheme.lua`.

### `onedarkpro` theme with a classic One Dark palette

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] The active colorscheme must be `onedarkpro` or the accepted One Dark-compatible LazyVim theme setup.
- [x] The theme must be declared through a LazyVim plugin spec or colorscheme override, not legacy setup code.
- [x] The colorscheme must load cleanly on startup without fallback errors.
- [x] The selected palette must preserve the classic One Dark visual identity closely enough for the migration goal.
- [x] Theme setup must not duplicate removed plugin-specific highlight assumptions.

Validation performed:

- [x] Headless Neovim loaded the full plugin set and confirmed `vim.g.colors_name == "onedark"`.
- [x] Code audit confirmed the theme now lives in `lua/plugins/colorscheme.lua` and no legacy `nvim.bak` colorscheme module is required.

### Extensive highlight overrides for floats, Mason, Telescope, tree, diff, and bufferline

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Only highlight overrides that still target active LazyVim plugins or real workflow needs should be migrated.
- [x] Removed-plugin groups such as `NvimTree*` or old barbar groups must not be blindly ported.
- [x] Float, Mason, picker, diff, and explorer highlights must be mapped to active group names where migrated.
- [x] Highlight customization must live in the theme/plugin presentation layer.
- [x] The final highlight set must be maintainable and documented when it intentionally diverges from LazyVim defaults.

Validation performed:

- [x] Headless runtime validation confirmed active highlight groups exist for the migrated terminal float groups and the new theme loads without errors.
- [x] Code audit confirmed the migrated highlight set keeps active groups such as `FloatingTerm*`, Mason, Telescope, and diff highlights while intentionally leaving removed-plugin groups absent.

## Statusline, Messages, and Core UI Options

Slice status: accepted for showmode and global line-number defaults. Other provided items remain on LazyVim defaults.

### Custom `lualine` “Eviline” layout

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### `noice.nvim` and other old custom prettification techniques

Classification: `already provided by LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] LazyVim's existing Noice and notification stack must remain available if enabled by the baseline.
- [ ] The migration must not port the old custom Noice setup unless a concrete workflow gap is reclassified.
- [ ] Message, command-line, and notification behavior must load without legacy module dependencies.
- [ ] Any visual differences from the old setup are acceptable unless documented as a workflow regression.

Suggested validation:

- [ ] Start Neovim and confirm Noice-related startup has no errors.
- [ ] Trigger a command-line message or notification and confirm the LazyVim-provided UI handles it.

### Hide `showmode` and rely on statusline

Classification: `already provided by LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] `showmode` must remain disabled when the active statusline provides mode visibility.
- [x] The migration must not re-enable old duplicate mode text in the command area.
- [x] The behavior may be provided by LazyVim defaults or a minimal `lua/config/options.lua` override.
- [x] Statusline ownership must remain with LazyVim's active statusline configuration.

Validation performed:

- [x] Headless runtime validation confirmed `vim.o.showmode == false` after full startup.
- [x] The option now lives in `lua/config/options.lua`, with the startup path corrected so LazyVim defaults no longer overwrite it.

### Global line numbers

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Absolute line numbers must be enabled globally.
- [x] Relative line numbers must be disabled according to the inventory preference.
- [x] The implementation must live in `lua/config/options.lua` as core editor behavior.
- [x] Terminal floats may still override line-number display locally according to terminal presentation criteria.
- [x] No later LazyVim toggle should silently re-enable relative numbers as the default state.

Validation performed:

- [x] Headless runtime validation confirmed `vim.o.number == true` and `vim.o.relativenumber == false` after full startup.
- [x] The startup path no longer preloads `config.options`, so the final option state now reflects the user override instead of LazyVim's default `relativenumber = true`.

### Clipboard handling

Classification: `already provided by LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] LazyVim's default clipboard behavior must remain acceptable without porting old clipboard setup.
- [ ] The migration must not add redundant clipboard configuration unless a platform-specific gap is found.
- [ ] Clipboard setup must not break SSH or headless contexts handled by LazyVim defaults.
- [ ] Yank and paste behavior must work in ordinary editing buffers.

Suggested validation:

- [ ] Inspect `vim.o.clipboard` in the target environment and confirm it matches the accepted LazyVim behavior.
- [ ] Yank text and paste it through the system clipboard path if available.

## Autocommands and Filetype Defaults

Slice status: acceptance criteria defined. Discarded items in this slice remain intentionally out of scope.

### Various autocommands for filetypes, Svelte change detection, and editor behavior

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### Wrap and spell in prose-oriented buffers

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## Formatting Plugin Policy

Slice status: accepted. The repo now follows LazyVim's documented ESLint-and-Prettier recipe, with a local Prettier config gate and a small Svelte extension.

### `conform.nvim` Prettier policy through LazyVim's formatting recipe

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Formatter selection must be configured through LazyVim's `formatting.prettier` recipe and a local `conform.nvim` opts override rather than a standalone legacy setup module.
- [x] Project-local Prettier config detection must be preserved for this repo through `vim.g.lazyvim_prettier_needs_config = true`.
- [x] The active formatter map must still cover the repo's accepted local web-dev filetypes, including `svelte`.
- [x] Projects without a Prettier config must not unexpectedly format through this path.
- [x] Missing external formatter binaries must produce ordinary formatting errors rather than config-load failures.

Validation performed:

- [x] Headless runtime validation confirmed `lazyvim.json` enables `lazyvim.plugins.extras.formatting.prettier` and `vim.g.lazyvim_prettier_needs_config == true` after startup.
- [x] Headless runtime validation confirmed merged `conform.nvim` opts still map `svelte` to `prettier` and keep the upstream `prettier` condition function from the extra.
- [x] A temp JavaScript file in a directory with `.prettierrc.json` was formatted and written to disk as `const x = { foo: "bar" };`.
- [x] A temp JavaScript file in a directory without a Prettier config remained unchanged, confirming the config gate still applies.

### Disable LSP formatting for formatter-managed servers while keeping ESLint as a secondary fixer

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] LSP formatting capabilities must be disabled or deprioritized for servers whose formatting is managed by Conform, while ESLint remains eligible for the documented fix-on-save registration.
- [x] The implementation must follow LazyVim-compatible LSP setup hooks and documented formatting recipes.
- [x] ESLint and Prettier responsibilities must be separated according to the accepted migration policy.
- [x] Disabling server formatting must not disable diagnostics, code actions, or navigation from those servers.
- [x] The behavior must be validated in at least one formatter-managed LSP buffer.

Validation performed:

- [x] Headless runtime validation opened `lua/plugins/lsp.lua`, waited for `lua_ls` attach, and confirmed `client.server_capabilities.documentFormattingProvider == false` for that formatter-managed server.
- [x] Headless runtime validation confirmed merged `nvim-lspconfig` opts now include the `linting.eslint` extra's `eslint.settings.workingDirectories.mode = "auto"` and `eslint.settings.format = true` recipe values.
- [x] The same validation confirmed LSP attachment still succeeds, so diagnostics and navigation remain intact while formatting ownership moves to Conform.

## Mason and LSP Server Configuration

Slice status: accepted for actionable items. The Mason UI override is restored and the remaining items stay discarded.

### Mason UI dimensions, border, and icons

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] Mason UI must use the accepted dimensions, rounded border, and icon choices where supported.
- [x] The customization must be implemented through a `mason.nvim` opts override.
- [x] Mason setup must not duplicate LazyVim's package management ownership.
- [x] Cosmetic Mason changes must not block LSP startup if Mason is unavailable or lazy-loaded.
- [x] The configuration must remain low-risk and isolated from server installation policy.

Validation performed:

- [x] Headless runtime validation confirmed `LazyVim.opts("mason.nvim").ui` contains the migrated rounded border, dimensions, and icon choices.
- [x] The full plugin load completed successfully with the Mason override present, so the cosmetic config does not block startup.

### Mason tool installer for `mypy` and `stylua`

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### Server-specific LSP settings for `lua_ls`, `pyright`, `eslint`, `ts_ls`, `ruff`, `svelte`, etc

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### `svelte` JS/TS change notification autocmd

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## Explorer Plugin Migration

Slice status: acceptance criteria defined. Discarded items in this slice remain intentionally out of scope.

### `nvim-tree` config: show ignored files, custom git glyphs, default on-attach mappings

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### `nvim-tree` rename hook into `Snacks.rename.on_rename_file`

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## Bufferline Plugin Migration

Slice status: acceptance criteria defined. Discarded items in this slice remain intentionally out of scope.

### `barbar.nvim` bufferline configuration

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## Picker and Treesitter Plugin Migration

Slice status: acceptance criteria defined. Do not mark this slice accepted until actionable items are implemented; discarded items remain out of scope.

### `telescope.nvim` hidden-file and no-ignore defaults

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] The accepted picker backend must preserve the useful ability to include hidden or normally ignored files where that remains desired.
- [ ] The implementation must prefer Snacks picker opts when Snacks is the active LazyVim picker backend.
- [ ] Telescope-specific configuration must only remain if Telescope is the active owner for that workflow.
- [ ] Search noise from ignored files must be balanced against the workflow need and documented.
- [ ] The picker configuration must not duplicate unrelated search mappings.

Suggested validation:

- [ ] Run the accepted file search and grep workflows against hidden files and confirm expected visibility.
- [ ] Confirm the active picker backend owns the configuration path being used.

### Runtime `nvim-treesitter.parsers.ft_to_lang` compatibility shim

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### Treesitter parser install list and auto-start-on-filetype logic

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## Key Hint and Mini.nvim Enhancements

Slice status: accepted for `which-key.nvim` leader hints. `mini.clue` is disabled by current preference and `mini.hipatterns` remains open.

### `which-key.nvim` leader hints

Classification: `adapt to LazyVim`

Overall requirement: [x] Accepted

Acceptance criteria:

- [x] `which-key.nvim` must provide leader-key hints for the accepted key groups.
- [x] `mini.clue` must be disabled or absent so there is one active key-hint system.
- [x] Which-key group descriptions must match the migrated granular workflow groups closely enough for discoverability.
- [x] Which-key must not present stale LazyVim file/find ownership for bare `<leader>f`, because that key is now the immediate Format action.
- [x] Which-key must not present stale LazyVim window-prefix ownership for bare `<leader>w`, because that key is now the immediate Write action.
- [x] Which-key duplicate and overlap checks must report no duplicate mappings and no overlapping keymaps for the accepted migrated top-level leader ownership.
- [x] `lua/plugins/key-hints.lua` must declare every accepted top-level leader group.
- [x] Top-level leader bindings outside the groups declared in `lua/plugins/key-hints.lua` must be removed from the active config until the user explicitly re-adds them for a migrated workflow or changes this policy.
- [x] Standalone which-key entries must not be added just to preserve otherwise unlisted bindings.
- [x] The top-level `<leader>l` key must remain a prefix-only LazyGit namespace and must not fall back to LazyVim's default `:Lazy` action after `User VeryLazy` keymaps load.
- [x] The implementation must live in a plugin spec under `lua/plugins`.

Validation performed:

- [x] Headless startup confirmed `which-key.nvim` is present in Lazy's resolved plugin set and `require("which-key")` succeeds.
- [x] Headless startup confirmed `mini.clue` is absent from Lazy's resolved plugin set and `package.loaded["mini.clue"]` remains nil.
- [x] Headless startup confirmed migrated mappings such as `<leader>f`, `<leader>sf`, and removed `<leader>ff` remain unchanged after switching hint systems.
- [x] Headless inspection of `which-key.config` confirmed the active spec contains migration-aware groups and no stale `<leader>f` file/find or `<leader>w` windows group.
- [x] Headless startup confirmed unlisted top-level leader bindings are unmapped while declared groups remain active.
- [x] Headless startup after `User VeryLazy` confirmed `<leader>l` resolves to `<Nop>` with the migrated LazyGit description instead of LazyVim's default `:Lazy` mapping.
- [x] Headless Neovim intercepted `require("which-key.health").check()` and confirmed the resolved config reports no overlapping keymaps and no duplicate mappings.

### `mini.clue` leader hints

Classification: `discard`

Ignored by rule: this item is classified as `discard` after the user's current preference change and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

### `mini.hipatterns` TODO / NOTE / WARN highlighting

Classification: `adapt to LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] `TODO`, `NOTE`, `WARN`, and similar accepted comment markers must be highlighted.
- [x] Hex color highlighting should remain available if included in the accepted setup.
- [ ] The implementation must use `mini.hipatterns` or an explicitly accepted LazyVim-native equivalent.
- [ ] Highlighting must not duplicate or visibly conflict with any active LazyVim todo-comment plugin.
- [ ] The behavior must load for normal code buffers without manual commands.

Suggested validation:

- [ ] Open a buffer containing `TODO`, `NOTE`, and `WARN` comments and confirm highlights appear.
- [ ] Add a hex color literal and confirm color highlighting works if that feature is enabled.

### `mini.comment`, `mini.cursorword`, `mini.bufremove`, `mini.pairs`

Classification: `discard`

Ignored by rule: this item is classified as `discard` and is out of scope for implementation, acceptance tracking, and validation unless later reclassified.

## Snacks.nvim Baseline Behavior

Slice status: acceptance criteria defined. Do not mark this slice accepted until the baseline is confirmed and any true deviations are implemented.

### Snacks config for float style, picker, terminal, lazygit, rename, indent

Classification: `(mostly) already provided by LazyVim`

Overall requirement: [ ] Accepted

Acceptance criteria:

- [ ] Snacks must remain the accepted owner for LazyVim-native float, picker, terminal, LazyGit, rename, and indent workflows where applicable.
- [ ] Only deviations from LazyVim defaults that preserve real workflow requirements should be implemented.
- [ ] Snacks opts must be merged through LazyVim plugin specs rather than by replacing the whole setup.
- [ ] Snacks terminal customizations must align with the terminal-specific acceptance criteria in this document.
- [ ] Snacks picker and LazyGit behavior must not be duplicated by removed legacy plugin code.

Suggested validation:

- [ ] Exercise representative Snacks-backed workflows: picker, terminal, LazyGit, and rename if configured.
- [ ] Inspect plugin specs and confirm Snacks opts are merged rather than replaced wholesale.

## Deferred / Lower-Priority Findings

Slice status: documented only. These findings are intentionally not acceptance gates until a future migration slice reclassifies them.

### Debugger workflows

Classification: deferred / lower priority

Ignored by current rule: debugger workflows are not accepted migration targets yet because the old debugger setup was non-fully functional and should be reconsidered against LazyVim's debugger integration in a future slice.
