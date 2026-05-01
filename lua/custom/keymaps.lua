local conform = require("conform")
local terminal = require("custom.terminal")
-- ================================================
--- Most keymaps live here, some might be defined in plugin configs such as
--- some Lsp stuff, telescope(which is in the lsp config, not the telescope config), and
--- ================================================

local M = {}

local DEFAULT_OPTS = {
	silent = true,
	noremap = true,
}

-- Single source of truth for all keybindings and which-key groups.
local KEYMAPS = {
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>w",
		rhs = "<cmd>write<CR>",
		desc = "[W]rite buffer (save file)",
	},

	-- Two-step only mappings (i.e. can hit q and need to hit qq to actually quit or lg for lazygit not just l)
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>q",
		rhs = "<Nop>",
		desc = "[Q]uit",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>l",
		rhs = "<Nop>",
		desc = "[L]azyGit",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>qq",
		rhs = "<cmd>quit<CR>",
		desc = "[Q]uit window",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>qb",
		rhs = "<cmd>bd<CR>",
		desc = "[Q]uit (close) [B]uffer",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<C-Right>",
		rhs = "<Cmd>bn<CR>",
		desc = "Buffer next",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<C-Left>",
		rhs = "<Cmd>bp<CR>",
		desc = "Buffer previous",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<D-Right>",
		rhs = "<Cmd>bn<CR>",
		desc = "Buffer next",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<D-Left>",
		rhs = "<Cmd>bp<CR>",
		desc = "Buffer previous",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>e",
		rhs = function()
			require("nvim-tree.api").tree.toggle()
		end,
		desc = "[E]xplore File Tree",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>xx",
		rhs = "<cmd>Telescope diagnostics<CR>",
		desc = "Diagnostics And Issues(Current File)",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>lg",
		rhs = function()
			Snacks.lazygit.open()
		end,
		desc = "LazyGit",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>f",
		rhs = function()
			conform.format({
				async = true,
				lsp_format = "fallback",
			})
		end,
		desc = "[F]ormat buffer",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>t",
		rhs = terminal.toggle,
		desc = "Toggle floating terminal",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>cc",
		rhs = terminal.open_copilot,
		desc = "Open floating GitHub [C]opilot [C]LI",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>ds",
		rhs = function()
			require("custom.debugger").start_session()
		end,
		desc = "Debug: Launch config [S]elector",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>da",
		rhs = function()
			require("custom.debugger").pick_all_configurations()
		end,
		desc = "Debug: Show [A]ll configurations",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dc",
		rhs = function()
			require("custom.debugger").continue_session()
		end,
		desc = "Debug: [C]ontinue",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dr",
		rhs = function()
			require("custom.debugger").restart_last()
		end,
		desc = "Debug: [R]estart last session",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dt",
		rhs = function()
			require("custom.debugger").terminate()
		end,
		desc = "Debug: [T]erminate session",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dp",
		rhs = function()
			require("custom.debugger").pause()
		end,
		desc = "Debug: [P]ause session",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>do",
		rhs = function()
			require("custom.debugger").step_over()
		end,
		desc = "Debug: Step [O]ver",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>di",
		rhs = function()
			require("custom.debugger").step_into()
		end,
		desc = "Debug: Step [I]nto",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>du",
		rhs = function()
			require("custom.debugger").step_out()
		end,
		desc = "Debug: Step o[U]t",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dd",
		rhs = function()
			require("custom.debugger").toggle_ui()
		end,
		desc = "Debug: Toggle [D]ebug UI",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>db",
		rhs = function()
			require("custom.debugger").toggle_breakpoint()
		end,
		desc = "Debug: Toggle [B]reakpoint",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dB",
		rhs = function()
			require("custom.debugger").set_conditional_breakpoint()
		end,
		desc = "Debug: Conditional [B]reakpoint",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dL",
		rhs = function()
			require("custom.debugger").set_log_point()
		end,
		desc = "Debug: [L]og point",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dx",
		rhs = function()
			require("custom.debugger").clear_breakpoints()
		end,
		desc = "Debug: Clear breakpoints",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dC",
		rhs = function()
			require("custom.debugger").pick_configuration()
		end,
		desc = "Debug: Pick [C]onfiguration",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dR",
		rhs = function()
			require("custom.debugger").toggle_repl()
		end,
		desc = "Debug: Toggle [R]EPL",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>df",
		rhs = function()
			require("custom.debugger").show_frames()
		end,
		desc = "Debug: Show [F]rames",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dv",
		rhs = function()
			require("custom.debugger").show_scopes()
		end,
		desc = "Debug: Show [V]ariables",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dw",
		rhs = function()
			require("custom.debugger").show_watches()
		end,
		desc = "Debug: Show [W]atches",
	},
	{
		type = "map",
		scope = "global",
		mode = { "n", "v" },
		lhs = "<leader>de",
		rhs = function()
			require("custom.debugger").eval()
		end,
		desc = "Debug: [E]valuate expression",
	},

	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sh",
		rhs = function()
			require("telescope").help_tags()
		end,
		desc = "[S]earch [H]elp",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sk",
		rhs = "<cmd>Telescope keymaps<CR>",
		desc = "[S]earch [K]eymaps",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sf",
		rhs = "<cmd>Telescope find_files<CR>",
		desc = "[S]earch [F]iles",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>ss",
		rhs = "<cmd>Telescope lsp_document_symbols<CR>",
		desc = "[S]earch Telescope Pickers",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sw",
		rhs = "<cmd>Telescope grep_string",
		desc = "[S]earch current [W]ord",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sg",
		rhs = "<cmd>Telescope live_grep<CR>",
		desc = "[S]earch by [G]rep",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sd",
		rhs = "<cmd>Telescope diagnostics<CR>",
		desc = "[S]earch [D]iagnostics",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>s.",
		rhs = "<cmd>Telescope oldfiles<CR>",
		desc = '[S]earch Recent Files ("." for repeat)',
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>/",
		rhs = "<cmd>Telescope current_buffer_fuzzy_find<CR>",
		-- Fuzzy find in current buffer, but show full results when no query to allow browsing.
		-- This is a bit different than the default which requires at least one character to show results.
		desc = "[/] Search current file",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>s/",
		rhs = "<cmd>Telescope buffers<CR>",
		desc = "[S]how current buffers",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sn",
		rhs = "<cmd>Telescope find_files cwd=~/.config/nvim<CR>",
		desc = "[S]earch [N]eovim files",
	},

	{ type = "map", scope = "global", mode = { "n", "i", "v", "x", "s", "o", "c" }, lhs = "<Up>", rhs = "<Nop>" },
	{ type = "map", scope = "global", mode = { "n", "i", "v", "x", "s", "o", "c" }, lhs = "<Down>", rhs = "<Nop>" },
	{ type = "map", scope = "global", mode = { "n", "i", "v", "x", "s", "o", "c" }, lhs = "<Left>", rhs = "<Nop>" },
	{ type = "map", scope = "global", mode = { "n", "i", "v", "x", "s", "o", "c" }, lhs = "<Right>", rhs = "<Nop>" },
	{
		type = "map",
		scope = "global",
		mode = "t",
		lhs = "<Esc>",
		rhs = terminal.close,
		desc = "Close floating terminal",
	},
}

-- Disable macros (pressing 'q' typically starts/stops recording macros but I use it to quit things alot).
-- Map plain 'q' in normal mode to <Nop> so accidental recordings are prevented.
table.insert(KEYMAPS, 1, {
	type = "map",
	scope = "global",
	mode = "n",
	lhs = "q",
	rhs = "<Nop>",
	desc = "Disable macro recording (prevent accidental 'q' presses)",
})

function M.apply_maps(scope, extra_opts, keymaps)
	for _, spec in ipairs(keymaps) do
		if spec.type == "map" and spec.scope == scope then
			local opts = vim.tbl_extend("force", DEFAULT_OPTS, extra_opts or {}, spec.opts or {})
			if spec.desc then
				opts.desc = spec.desc
			end
			vim.keymap.set(spec.mode or "n", spec.lhs, spec.rhs, opts)
		end
	end
end

function M.setup()
	M.apply_maps("global", nil, KEYMAPS)

	-- Global <Esc> that only toggles file tree away if its open, otherwise normal esc behavior
	vim.keymap.set("n", "<Esc>", function()
		local api = require("nvim-tree.api")
		if api.tree.is_visible() then
			api.tree.close()
		end
	end, { desc = "Close file tree if open, otherwise normal <Esc> behavior" })
end

return M
