local p = {}

local PLUGINS = {
	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-dap.nvim",
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/theHamsta/nvim-dap-virtual-text",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/jay-babu/mason-nvim-dap.nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},

	"https://github.com/rafamadriz/friendly-snippets",

	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/rcarriga/nvim-notify",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/olimorris/onedarkpro.nvim",
	"https://github.com/APZelos/blamer.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/folke/snacks.nvim",
	"https://github.com/folke/noice.nvim",
	"https://github.com/romgrk/barbar.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://github.com/zbirenbaum/copilot.lua",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mxsdev/nvim-dap-vscode-js",
}

function p.setup()
	--- Plugins (pre-config) ---
	vim.pack.add(PLUGINS)
	require("custom.pack").setup(PLUGINS)

	require("lazydev").setup()
	require("custom.configs.onedarkpro").setup()

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
			{ mode = "n", keys = "<Leader>d", desc = "+Debug" },
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
	require("mini.comment").setup({})
	require("mini.cursorword").setup({})
	require("mini.bufremove").setup({})

	require("mini.pairs").setup({})

	--- Plugin Configs ---
	--- More in depth plugins have dedicated files, simpler ones are included in this file
	require("custom.configs.treesitter-config").setup()

	require("custom.configs.telescope-config").setup()

	require("custom.configs.file-tree").setup()

	require("custom.configs.barbar").setup()
	require("custom.configs.gitsigns").setup()

	require("custom.configs.statusline").setup()

	require("custom.configs.copilot-setup").setup()

	require("custom.configs.conform").setup()

	require("custom.configs.noice").setup()

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
		picker = {
			enabled = true,
			ui_select = true,
		},
		terminal = { enabled = true },
		lazygit = { enabled = true, configure = true, interactive = true },
		rename = { enabled = true },
		dim = { enabled = false },
		indent = { enabled = true, animate = { enabled = false } },
	})
end
return p
