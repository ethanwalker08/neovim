local p = {}

local prettier_filetypes = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"svelte",
	"html",
	"css",
	"scss",
	"json",
	"jsonc",
	"yaml",
	"markdown",
}

function p.setup()
	--- Plugins (pre-config) ---
	vim.pack.add({
		"https://www.github.com/echasnovski/mini.nvim",
		"https://www.github.com/nvim-tree/nvim-tree.lua",
		{
			src = "https://github.com/nvim-treesitter/nvim-treesitter",
			branch = "main",
			build = ":TSUpdate",
		},
		"https://github.com/nvim-lua/plenary.nvim",
		"https://github.com/nvim-telescope/telescope.nvim",
		-- Language Server Protocol stuff
		"https://www.github.com/neovim/nvim-lspconfig",
		"https://github.com/mason-org/mason.nvim",
		"https://github.com/mason-org/mason-lspconfig.nvim",
		"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
		{
			src = "https://github.com/saghen/blink.cmp",
			version = vim.version.range("1.*"),
		},

		"https://github.com/rafamadriz/friendly-snippets",

		-- Others
		"https://github.com/MunifTanjim/nui.nvim",
		"https://github.com/folke/lazydev.nvim",
		"https://github.com/olimorris/onedarkpro.nvim",
		"https://github.com/APZelos/blamer.nvim",
		"https://github.com/nvim-tree/nvim-web-devicons",
		"https://github.com/L3MON4D3/LuaSnip",
		"https://github.com/folke/snacks.nvim",
		"https://github.com/nvim-lualine/lualine.nvim",
		"https://github.com/zbirenbaum/copilot.lua",
		"https://github.com/stevearc/conform.nvim",
	})

	require("lazydev").setup()

	--- Mini.nvim plugins ---
	require("mini.clue").setup({
		-- Register `<Leader>` as trigger
		triggers = {
			{ mode = { "n", "x" }, keys = "<Leader>" },
			{ mode = "i", keys = "<C-x>" },
		},

		-- Add descriptions for mapping groups
		clues = {
			{ mode = "n", keys = "<Leader>b", desc = "+Buffers" },
			{ mode = "n", keys = "<Leader>l", desc = "+LSP" },
			{ mode = "n", keys = "<Leader>s", desc = "+Search" },
			{ mode = "n", keys = "<Leader>x", desc = "+Diagnostics" },
			{ mode = "n", keys = "<Leader>g", desc = "+Goto" },
			{ mode = "n", keys = "<Leader>c", desc = "+Code" },
		},

		window = {
			-- Delay before showing clue window
			delay = 0,
		},
	})

	-- Todo/other comment type highlights
	local hipatterns = require("mini.hipatterns")
	hipatterns.setup({
		highlighters = {
			-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
			fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
			hack = { pattern = "%f[%w]()WARN()%f[%W]", group = "MiniHipatternsHack" },
			todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
			note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

			-- Highlight hex color strings (`#rrggbb`) using that color
			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})

	require("mini.cursorword").setup({})
	require("mini.git").setup({})
	require("mini.tabline").setup({})
	require("mini.fuzzy").setup({})
	require("mini.ai").setup({})
	require("mini.comment").setup({})
	require("mini.move").setup({})
	require("mini.surround").setup({})
	require("mini.pairs").setup({})
	require("mini.bufremove").setup({})

	--- Plugin Configs ---
	--- More in depth plugins have dedicated files, simpler ones are included in this file
	require("custom.configs.treesitter-config").setup()

	require("custom.configs.telescope-config").setup()

	require("custom.configs.file-tree").setup()

	require("custom.configs.statusline").setup()

	require("custom.configs.copilot-setup").setup()

	require("snacks").setup({
		styles = {
			float = {
				backdrop = false,
				border = "rounded",
				wo = {
					winblend = 0,
					winhighlight = "NormalFloat:FloatingTermNormal,FloatBorder:FloatingTermBorder",
				},
			},
		},
		input = { enabled = true, win = { resize = true, border = "rounded" } },
		terminal = { enabled = true },
		lazygit = { enabled = true, configure = true, interactive = true },
		rename = { enabled = true },
		notifier = { enabled = true },
		dim = { enabled = false },
		indent = { enabled = true, animate = { enabled = false } },
	})

	local conform_util = require("conform.util")
	local prettier_root_files = {
		".prettierrc",
		".prettierrc.json",
		".prettierrc.yml",
		".prettierrc.yaml",
		".prettierrc.json5",
		".prettierrc.js",
		".prettierrc.cjs",
		".prettierrc.mjs",
		".prettierrc.toml",
		"prettier.config.js",
		"prettier.config.cjs",
		"prettier.config.mjs",
		"prettier.config.ts",
		"package.json",
	}
	local prettier_cwd = conform_util.root_file(prettier_root_files)
	local formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format" },
	}

	for _, filetype in ipairs(prettier_filetypes) do
		formatters_by_ft[filetype] = { "prettierd", "prettier", stop_after_first = true }
	end

	require("conform").setup({
		notify_on_error = false,
		format_on_save = function()
			return {
				timeout_ms = 750,
				lsp_format = "fallback",
			}
		end,
		formatters = {
			prettierd = {
				cwd = prettier_cwd,
				require_cwd = true,
				condition = function(ctx)
					return prettier_cwd(ctx) ~= nil
				end,
			},
			prettier = {
				cwd = prettier_cwd,
				require_cwd = true,
				condition = function(ctx)
					return prettier_cwd(ctx) ~= nil
				end,
			},
		},
		formatters_by_ft = formatters_by_ft,
	})
end
return p
