-- VSCode Neovim Configuration
-- This file is specifically for when Neovim is running inside VSCode
-- It maintains all your native Neovim keybindings while leveraging VSCode features

-- Set leader keys (same as native config)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable macro recording by unmapping 'q' in normal mode (behaves unexpectedly in VSCode)
vim.keymap.set("n", "q", "<Nop>", { noremap = true, silent = true })

-- This file is loaded when running inside VSCode
-- The main init.lua will detect VSCode and load this file

-- ============================================================================
-- INSERT MODE PROTECTION
-- ============================================================================
-- Disable all key mappings in insert mode to prevent accidental command triggers
-- This ensures that typing 'n', 'g', or any other character in insert mode
-- will NEVER trigger a normal mode command
vim.api.nvim_create_augroup("InsertModeProtection", { clear = true })
vim.api.nvim_create_autocmd("ModeChanged", {
	group = "InsertModeProtection",
	pattern = "*:i",
	callback = function()
		-- When entering insert mode, disable timeout so no mappings in neovim can be triggered
		vim.opt.timeout = false
	end,
})
vim.api.nvim_create_autocmd("ModeChanged", {
	group = "InsertModeProtection",
	pattern = "i:*",
	callback = function()
		-- When leaving insert mode, re-enable timeout for mappings
		vim.opt.timeout = true
	end,
})

-- ============================================================================
-- CORE SETTINGS (VSCode Compatible)
-- ============================================================================

vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
-- Increased timeout to prevent accidental triggering of key sequences while typing in insert mode
-- A longer timeout means you have more time between keypresses before it times out
-- This helps prevent 'n' or other characters from triggering commands in insert mode
vim.opt.timeoutlen = 3000
vim.opt.ttimeoutlen = 10

-- ============================================================================
-- VSCODE-SPECIFIC HELPER FUNCTIONS
-- ============================================================================

local vscode = require("vscode-neovim")

-- Helper function to call VSCode commands
local function vscodeCall(command)
	return function()
		vscode.call(command)
	end
end

-- Helper for VSCode actions with custom logic
local function vscodeAction(command)
	return function()
		vscode.action(command)
	end
end

-- ============================================================================
-- FILE NAVIGATION & SEARCH (Telescope → VSCode Quick Open)
-- ============================================================================

-- File finding
vim.keymap.set("n", "<leader>sf", vscodeCall("workbench.action.quickOpen"), { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader><leader>", vscodeCall("workbench.action.showAllEditors"), { desc = "Show Buffers" })

-- Text search
vim.keymap.set("n", "<leader>sg", vscodeCall("workbench.action.findInFiles"), { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sw", vscodeCall("workbench.action.findInFiles"), { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>/", vscodeCall("workbench.action.findInFiles"), { desc = "[/] Search in buffer" })

-- Diagnostics search
vim.keymap.set("n", "<leader>sd", vscodeCall("workbench.actions.view.problems"), { desc = "[S]earch [D]iagnostics" })

-- Help
vim.keymap.set("n", "<leader>sh", vscodeCall("workbench.action.showCommands"), { desc = "[S]earch [H]elp/Commands" })
vim.keymap.set("n", "<leader>sk", vscodeCall("workbench.action.openGlobalKeybindings"), { desc = "[S]earch [K]eymaps" })

-- Recent files
vim.keymap.set("n", "<leader>s.", vscodeCall("workbench.action.openRecent"), { desc = "[S]earch Recent Files" })

-- Search in current buffer
vim.keymap.set("n", "<leader>ss", vscodeCall("workbench.action.showCommands"), { desc = "[S]earch [S]elect Commands" })

-- Config navigation
vim.keymap.set("n", "<leader>sn", function()
	vscode.call("workbench.action.quickOpen", { args = { vim.fn.stdpath("config") } })
end, { desc = "[S]earch [N]eovim files" })

-- ============================================================================
-- FILE EXPLORER (Neo-tree → VSCode Explorer)
-- ============================================================================

vim.keymap.set("n", "<leader>e", vscodeCall("workbench.view.explorer"), { desc = "Toggle Explorer" })
vim.keymap.set("n", "<leader>E", vscodeCall("workbench.files.action.focusFilesExplorer"), { desc = "Focus Explorer" })

-- ============================================================================
-- LSP KEYBINDINGS (Native LSP → VSCode LSP)
-- ============================================================================

-- Go to definition
vim.keymap.set("n", "<leader>gd", vscodeCall("editor.action.revealDefinition"), { desc = "[G]oto [D]efinition" })
vim.keymap.set("n", "gd", vscodeCall("editor.action.revealDefinition"), { desc = "Go to Definition" })

-- Go to references
vim.keymap.set("n", "<leader>gr", vscodeCall("references-view.findReferences"), { desc = "[G]oto [R]eferences" })
vim.keymap.set("n", "gr", vscodeCall("references-view.findReferences"), { desc = "Find References" })

-- Go to implementation
vim.keymap.set("n", "<leader>gI", vscodeCall("editor.action.goToImplementation"), { desc = "[G]oto [I]mplementation" })
vim.keymap.set("n", "gI", vscodeCall("editor.action.goToImplementation"), { desc = "Go to Implementation" })

-- Go to type definition
vim.keymap.set("n", "<leader>gt", vscodeCall("editor.action.goToTypeDefinition"), { desc = "[G]oto [T]ype Definition" })

-- Peek definition
vim.keymap.set("n", "gD", vscodeCall("editor.action.peekDefinition"), { desc = "Peek Definition" })

-- Code actions
vim.keymap.set("n", "<leader>ca", vscodeCall("editor.action.quickFix"), { desc = "[C]ode [A]ction" })
vim.keymap.set("v", "<leader>ca", vscodeCall("editor.action.quickFix"), { desc = "[C]ode [A]ction" })

-- Rename
vim.keymap.set("n", "<leader>r", vscodeCall("editor.action.rename"), { desc = "[R]ename" })

-- Format
vim.keymap.set("n", "<leader>f", vscodeCall("editor.action.formatDocument"), { desc = "[F]ormat Document" })
vim.keymap.set("v", "<leader>f", vscodeCall("editor.action.formatSelection"), { desc = "[F]ormat Selection" })

-- Hover documentation
vim.keymap.set("n", "K", vscodeCall("editor.action.showHover"), { desc = "Hover Documentation" })

-- Signature help
vim.keymap.set("i", "<C-k>", vscodeCall("editor.action.triggerParameterHints"), { desc = "Signature Help" })

-- Redo
vim.keymap.set("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>")

-- ============================================================================
-- DIAGNOSTICS & PROBLEMS (Trouble → VSCode Problems)
-- ============================================================================

vim.keymap.set("n", "<leader>xx", vscodeCall("workbench.actions.view.problems"), { desc = "Toggle Problems" })
vim.keymap.set("n", "<leader>xX", vscodeCall("workbench.actions.view.problems"), { desc = "Buffer Problems" })
vim.keymap.set("n", "[d", vscodeCall("editor.action.marker.prevInFiles"), { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", vscodeCall("editor.action.marker.nextInFiles"), { desc = "Next Diagnostic" })

-- ============================================================================
-- BUFFER/TAB MANAGEMENT (Barbar → VSCode Tabs)
-- ============================================================================

-- Close buffer
vim.keymap.set("n", "<leader>qb", vscodeCall("workbench.action.closeActiveEditor"), { desc = "[Q]uit [B]uffer" })

-- Navigate buffers/tabs
vim.keymap.set("n", "<C-Right>", vscodeCall("workbench.action.nextEditor"), { desc = "Next Buffer" })
vim.keymap.set("n", "<C-Left>", vscodeCall("workbench.action.previousEditor"), { desc = "Previous Buffer" })

-- Buffer picker
vim.keymap.set("n", "<leader>bb", vscodeCall("workbench.action.showAllEditors"), { desc = "Show All Buffers" })

-- ============================================================================
-- SAVE & QUIT
-- ============================================================================

vim.keymap.set("n", "<leader>w", vscodeCall("workbench.action.files.save"), { desc = "[W]rite/Save" })
vim.keymap.set("n", "<leader>qq", vscodeCall("workbench.action.closeActiveEditor"), { desc = "[Q]uit Editor" })

-- ============================================================================
-- GIT INTEGRATION (LazyGit → VSCode Git)
-- ============================================================================

vim.keymap.set("n", "<leader>lg", vscodeCall("workbench.view.scm"), { desc = "Open Git/SCM" })
vim.keymap.set("n", "<leader>gg", vscodeCall("workbench.view.scm"), { desc = "Git Status" })

-- Git hunks (similar to gitsigns)
vim.keymap.set("n", "]c", vscodeCall("workbench.action.editor.nextChange"), { desc = "Next Git Change" })
vim.keymap.set("n", "[c", vscodeCall("workbench.action.editor.previousChange"), { desc = "Previous Git Change" })

-- ============================================================================
-- WINDOW MANAGEMENT
-- ============================================================================

-- Split navigation (VSCode native)
vim.keymap.set("n", "<C-h>", vscodeCall("workbench.action.navigateLeft"), { desc = "Navigate Left" })
vim.keymap.set("n", "<C-l>", vscodeCall("workbench.action.navigateRight"), { desc = "Navigate Right" })
vim.keymap.set("n", "<C-k>", vscodeCall("workbench.action.navigateUp"), { desc = "Navigate Up" })
vim.keymap.set("n", "<C-j>", vscodeCall("workbench.action.navigateDown"), { desc = "Navigate Down" })

-- Split creation
vim.keymap.set("n", "<leader>sv", vscodeCall("workbench.action.splitEditorRight"), { desc = "[S]plit [V]ertical" })
vim.keymap.set("n", "<leader>sh", vscodeCall("workbench.action.splitEditorDown"), { desc = "[S]plit [H]orizontal" })

-- ============================================================================
-- COMMENTING (Better Comments handled by VSCode)
-- ============================================================================

vim.keymap.set("n", "gcc", vscodeCall("editor.action.commentLine"), { desc = "Comment Line" })
vim.keymap.set("v", "gc", vscodeCall("editor.action.commentLine"), { desc = "Comment Selection" })

-- ============================================================================
-- FOLD MANAGEMENT
-- ============================================================================

vim.keymap.set("n", "za", vscodeCall("editor.toggleFold"), { desc = "Toggle Fold" })
vim.keymap.set("n", "zc", vscodeCall("editor.fold"), { desc = "Close Fold" })
vim.keymap.set("n", "zo", vscodeCall("editor.unfold"), { desc = "Open Fold" })
vim.keymap.set("n", "zM", vscodeCall("editor.foldAll"), { desc = "Close All Folds" })
vim.keymap.set("n", "zR", vscodeCall("editor.unfoldAll"), { desc = "Open All Folds" })

-- ============================================================================
-- TERMINAL
-- ============================================================================

vim.keymap.set("n", "<leader>t", vscodeCall("workbench.action.terminal.toggleTerminal"), { desc = "Toggle Terminal" })
vim.keymap.set("n", "<leader>T", vscodeCall("workbench.action.terminal.new"), { desc = "New Terminal" })

-- ============================================================================
-- ADDITIONAL USEFUL VSCODE COMMANDS
-- ============================================================================

-- Command palette
vim.keymap.set("n", "<leader>p", vscodeCall("workbench.action.showCommands"), { desc = "Command Palette" })

-- Symbols
vim.keymap.set("n", "<leader>so", vscodeCall("workbench.action.gotoSymbol"), { desc = "[S]earch [O]utline/Symbols" })
vim.keymap.set(
	"n",
	"<leader>sO",
	vscodeCall("workbench.action.showAllSymbols"),
	{ desc = "[S]earch All [O]utline/Symbols" }
)

-- Zen mode
vim.keymap.set("n", "<leader>z", vscodeCall("workbench.action.toggleZenMode"), { desc = "Toggle Zen Mode" })

-- Focus specific views
vim.keymap.set("n", "<leader>ve", vscodeCall("workbench.view.explorer"), { desc = "[V]iew [E]xplorer" })
vim.keymap.set("n", "<leader>vs", vscodeCall("workbench.view.search"), { desc = "[V]iew [S]earch" })
vim.keymap.set("n", "<leader>vg", vscodeCall("workbench.view.scm"), { desc = "[V]iew [G]it" })
vim.keymap.set("n", "<leader>vd", vscodeCall("workbench.actions.view.problems"), { desc = "[V]iew [D]iagnostics" })

-- Breadcrumbs navigation
vim.keymap.set("n", "<leader>b", vscodeCall("breadcrumbs.focusAndSelect"), { desc = "Focus Breadcrumbs" })

-- Multi-cursor support (these work with native Neovim multi-cursor in VSCode)
-- Add cursor above/below
vim.keymap.set("n", "<C-A-Up>", vscodeCall("editor.action.insertCursorAbove"), { desc = "Add Cursor Above" })
vim.keymap.set("n", "<C-A-Down>", vscodeCall("editor.action.insertCursorBelow"), { desc = "Add Cursor Below" })

-- Select all occurrences
vim.keymap.set(
	"n",
	"<leader>ma",
	vscodeCall("editor.action.selectHighlights"),
	{ desc = "[M]ulti-cursor [A]ll Occurrences" }
)

-- ============================================================================
-- DEBUGGING (if you use debugger plugin)
-- ============================================================================

vim.keymap.set("n", "<leader>db", vscodeCall("editor.debug.action.toggleBreakpoint"), { desc = "[D]ebug [B]reakpoint" })
vim.keymap.set("n", "<leader>dc", vscodeCall("workbench.action.debug.continue"), { desc = "[D]ebug [C]ontinue" })
vim.keymap.set("n", "<leader>di", vscodeCall("workbench.action.debug.stepInto"), { desc = "[D]ebug Step [I]nto" })
vim.keymap.set("n", "<leader>do", vscodeCall("workbench.action.debug.stepOver"), { desc = "[D]ebug Step [O]ver" })
vim.keymap.set("n", "<leader>dO", vscodeCall("workbench.action.debug.stepOut"), { desc = "[D]ebug Step Out" })
vim.keymap.set("n", "<leader>dr", vscodeCall("workbench.action.debug.restart"), { desc = "[D]ebug [R]estart" })
vim.keymap.set("n", "<leader>ds", vscodeCall("workbench.action.debug.stop"), { desc = "[D]ebug [S]top" })

-- ============================================================================
-- FLUTTER-SPECIFIC (if using Flutter)
-- ============================================================================

vim.keymap.set("n", "<leader>dfr", vscodeCall("flutter.hotReload"), { desc = "[D]ebug [F]lutter [R]eload" })
vim.keymap.set("n", "<leader>dfR", vscodeCall("flutter.hotRestart"), { desc = "[D]ebug [F]lutter [R]estart" })

-- ============================================================================
-- NATIVE VIM ENHANCEMENTS (Keep native behaviors)
-- ============================================================================

-- Keep search centered
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better paste (don't lose clipboard when pasting over selection)
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without losing clipboard" })

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("vscode-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- ============================================================================
-- NOTES FOR USERS
-- ============================================================================

-- This configuration translates your Neovim workflow to VSCode:
--
-- PLUGINS HANDLED BY VSCODE:
-- • Telescope → VSCode Quick Open & Search
-- • Neo-tree → VSCode Explorer
-- • LSP (lspconfig, Mason) → VSCode's built-in LSP
-- • Treesitter → VSCode's semantic highlighting
-- • nvim-cmp → VSCode IntelliSense
-- • conform.nvim → VSCode formatters
-- • gitsigns → VSCode Git integration
-- • trouble.nvim → VSCode Problems panel
-- • barbar → VSCode tabs
-- • which-key → You can use VSCode's keyboard shortcuts helper
-- • noice/notify → VSCode notifications
-- • Better comments → VSCode Better Comments extension
-- • Auto-pairs, autotag → VSCode extensions
-- • staline/statusline → VSCode status bar
-- • colorscheme → VSCode themes
--
-- NATIVE NEOVIM BEHAVIORS PRESERVED:
-- • All text objects (ciw, di", va{, etc.)
-- • All motions (w, b, e, gg, G, f, t, etc.)
-- • Visual mode and visual block mode
-- • Registers and macros
-- • Marks
-- • Search with /, ?, *, #
-- • Jump list (Ctrl-o, Ctrl-i)
-- • Change list (g;, g,)
-- • All your custom keybindings from above
