local M = {}

local DEFAULT_OPTS = {
	silent = true,
	noremap = true,
}

-- Single source of truth for all keybindings and which-key groups.
local KEYMAPS = {
	{ type = "group", lhs = "<leader>b", group = "[B]uffer" },
	{ type = "group", lhs = "<leader>r", group = "[R]ename" },
	{ type = "group", lhs = "<leader>s", group = "[S]earch" },
	{ type = "group", lhs = "<leader>w", group = "[W]rite" },
	{ type = "group", lhs = "<leader>g", group = "[G]oto" },
	{ type = "group", lhs = "<leader>l", group = "[L]azyGit" },
	{ type = "group", lhs = "<leader>x", group = "View Issues" },
	{ type = "group", lhs = "<leader>q", group = "[Q]uit" },
	{ type = "group", lhs = "<leader>c", group = "[C]ode [A]ctions" },
	{ type = "group", lhs = "<leader>d", group = "[D]ebugger" },
	{ type = "group", lhs = "<leader>dh", group = "[D]ebug [H]over variables" },
	{ type = "group", lhs = "<leader>df", group = "[D]ebug [F]lutter" },
	{ type = "group", lhs = "<leader>f", group = "[F]ormat" },
	{ type = "group", lhs = "<leader>e", group = "[E]xplorer" },

	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>w",
		rhs = "<cmd>write<CR>",
		desc = "[W]rite buffer (save file)",
	},
	-- Prefix hint maps keep top-level which-key labels visible for two-step mappings.
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
		lhs = "<leader>N",
		rhs = function()
			if type(_G.CreateSveltekitRoute) == "function" then
				_G.CreateSveltekitRoute()
			else
				vim.notify("CreateSveltekitRoute() is not available", vim.log.levels.WARN)
			end
		end,
		desc = "[N]ew SvelteKit Route",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>qb",
		rhs = "<Cmd>BufferClose<CR>",
		desc = "[Q]uit (close) [B]uffer",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>bn",
		rhs = "<Cmd>BufferNext<CR>",
		desc = "[B]uffer [N]ext",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>bp",
		rhs = "<Cmd>BufferPrevious<CR>",
		desc = "[B]uffer [P]revious",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<C-Right>",
		rhs = "<Cmd>BufferNext<CR>",
		desc = "Buffer next",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<C-Left>",
		rhs = "<Cmd>BufferPrevious<CR>",
		desc = "Buffer previous",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>e",
		rhs = "<cmd>NvimTreeToggle<cr>",
		desc = "Toggle file tree",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>x",
		rhs = "<cmd>Trouble diagnostics toggle<cr>",
		desc = "Diagnostics (Trouble)",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>lg",
		rhs = "<cmd>LazyGit<cr>",
		desc = "LazyGit",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>f",
		rhs = function()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end,
		desc = "[F]ormat buffer",
	},

	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sh",
		rhs = function()
			require("telescope.builtin").help_tags()
		end,
		desc = "[S]earch [H]elp",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sk",
		rhs = function()
			require("telescope.builtin").keymaps()
		end,
		desc = "[S]earch [K]eymaps",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sf",
		rhs = function()
			require("telescope.builtin").find_files()
		end,
		desc = "[S]earch [F]iles",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>ss",
		rhs = function()
			require("telescope.builtin").builtin()
		end,
		desc = "[S]earch [S]elect Telescope",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sw",
		rhs = function()
			require("telescope.builtin").grep_string()
		end,
		desc = "[S]earch current [W]ord",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sg",
		rhs = function()
			require("telescope.builtin").live_grep()
		end,
		desc = "[S]earch by [G]rep",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sd",
		rhs = function()
			require("telescope.builtin").diagnostics()
		end,
		desc = "[S]earch [D]iagnostics",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sr",
		rhs = function()
			require("telescope.builtin").resume()
		end,
		desc = "[S]earch [R]esume",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>s.",
		rhs = function()
			require("telescope.builtin").oldfiles()
		end,
		desc = '[S]earch Recent Files ("." for repeat)',
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader><leader>",
		rhs = function()
			require("telescope.builtin").buffers()
		end,
		desc = "[ ] Find existing buffers",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>/",
		rhs = function()
			require("telescope.builtin").current_buffer_fuzzy_find()
			-- Fuzzy find in current buffer, but show full results when no query to allow browsing.
			-- This is a bit different than the default which requires at least one character to show results.
		end,
		desc = "[/] Fuzzily search in current buffer",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>s/",
		rhs = function()
			require("telescope.builtin").live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end,
		desc = "[S]earch [/] in Open Files",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>sn",
		rhs = function()
			require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
		end,
		desc = "[S]earch [N]eovim files",
	},

	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<F9>",
		rhs = function()
			require("dap").continue()
		end,
		desc = "Continue",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<F10>",
		rhs = function()
			require("dap").step_over()
		end,
		desc = "Step Over",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<F11>",
		rhs = function()
			require("dap").step_into()
		end,
		desc = "Step Into",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<F12>",
		rhs = function()
			require("dap").step_out()
		end,
		desc = "Step Out",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>db",
		rhs = function()
			require("dap").toggle_breakpoint()
		end,
		desc = "Toggle Breakpoint",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dr",
		rhs = function()
			require("dap").repl.open()
		end,
		desc = "Debugger REPL Open",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dff",
		rhs = "<cmd>FlutterDebug<cr>",
		desc = "Flutter Debug",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dfr",
		rhs = "<cmd>FlutterReload<cr>",
		desc = "Flutter Reload",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dfR",
		rhs = "<cmd>FlutterRestart<cr>",
		desc = "Flutter Restart",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dfq",
		rhs = "<cmd>FlutterQuit<cr>",
		desc = "Stop Flutter Debug",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dhh",
		rhs = function()
			require("dap.ui.widgets").hover()
		end,
		desc = "DAP Hover",
	},
	{
		type = "map",
		scope = "global",
		mode = "n",
		lhs = "<leader>dhc",
		rhs = function()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local config = vim.api.nvim_win_get_config(win)
				if config.relative ~= "" then
					vim.api.nvim_win_close(win, true)
				end
			end
		end,
		desc = "Close all hover windows",
	},

	{ type = "map", scope = "global", mode = { "n", "i", "v", "x", "s", "o", "c" }, lhs = "<Up>", rhs = "<Nop>" },
	{ type = "map", scope = "global", mode = { "n", "i", "v", "x", "s", "o", "c" }, lhs = "<Down>", rhs = "<Nop>" },
	{ type = "map", scope = "global", mode = { "n", "i", "v", "x", "s", "o", "c" }, lhs = "<Left>", rhs = "<Nop>" },
	{ type = "map", scope = "global", mode = { "n", "i", "v", "x", "s", "o", "c" }, lhs = "<Right>", rhs = "<Nop>" },

	{
		type = "map",
		scope = "lsp",
		mode = "n",
		lhs = "<leader>gd",
		rhs = vim.lsp.buf.definition,
		desc = "LSP: [G]oto [D]efinition",
	},
	{
		type = "map",
		scope = "lsp",
		mode = "n",
		lhs = "<leader>cr",
		rhs = vim.lsp.buf.references,
		desc = "LSP: [C]ode [R]eferences",
	},
	{
		type = "map",
		scope = "lsp",
		mode = "n",
		lhs = "<leader>gI",
		rhs = vim.lsp.buf.implementation,
		desc = "LSP: View [I]mplementation",
	},
	{
		type = "map",
		scope = "lsp",
		mode = "n",
		lhs = "<leader>gt",
		rhs = vim.lsp.buf.type_definition,
		desc = "LSP: [G]oto [T]ype",
	},
	{
		type = "map",
		scope = "lsp",
		mode = "n",
		lhs = "<leader>gr",
		rhs = vim.lsp.buf.references,
		desc = "LSP: [G]oto [R]eferences",
	},
	{
		type = "map",
		scope = "lsp",
		mode = { "n", "x" },
		lhs = "<leader>ca",
		rhs = vim.lsp.buf.code_action,
		desc = "LSP: [C]ode [A]ction",
	},
	{
		type = "map",
		scope = "lsp",
		mode = { "n", "x" },
		lhs = "<leader>cd",
		rhs = vim.lsp.buf.hover,
		desc = "LSP: Show [C]ode [D]ocs",
	},
	{
		type = "map",
		scope = "lsp",
		mode = "n",
		lhs = "<leader>r",
		rhs = vim.lsp.buf.rename,
		desc = "LSP: [R]ename",
	},
}

local function apply_maps(scope, extra_opts)
	for _, spec in ipairs(KEYMAPS) do
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
	apply_maps("global")

	-- Global <Esc> that only toggles file tree away if its open, otherwise normal esc behavior
	-- Otherwise fall back to normal <Esc> behavior.
	vim.keymap.set("n", "<Esc>", function()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			local ok, ft = pcall(vim.api.nvim_buf_get_option, buf, "filetype")
			if ok and ft == "nvim-tree" then
				vim.cmd("NvimTreeToggle")
				return
			end
		end

		-- Fallback: feed a normal <Esc> key
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	end, { silent = true, noremap = true })
end

function M.setup_which_key_navigation()
	local wk_state = require("which-key.state")

	-- which-key captures raw keys via getchar(), so normal keymaps are bypassed.
	-- Patch state.check once so <Esc> goes back one level when nested.
	if wk_state._custom_esc_back_patch then
		return
	end

	local original_check = wk_state.check
	wk_state.check = function(state, key)
		if key == "<Esc>" and state and state.node and state.node.parent and state.node.parent.parent then
			return state.node.parent
		end
		return original_check(state, key)
	end
	wk_state._custom_esc_back_patch = true
end

function M.which_key_groups()
	local groups = {}
	for _, spec in ipairs(KEYMAPS) do
		if spec.type == "group" then
			table.insert(groups, { spec.lhs, group = spec.group })
		end
	end
	return groups
end

function M.cmp_mappings(cmp)
	local is_mac = vim.fn.has("macunix") == 1
	local mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = false }),
		["<C-e>"] = cmp.mapping.abort(),
		["<Up>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<Down>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	})

	if is_mac then
		mapping["<D-Space>"] = cmp.mapping.complete()
	end

	return mapping
end

function M.better_escape_mappings()
	return {
		i = { j = { k = "<Esc>", j = "<Esc>" } },
	}
end

function M.on_lsp_attach(event)
	apply_maps("lsp", { buffer = event.buf })
end

return M
